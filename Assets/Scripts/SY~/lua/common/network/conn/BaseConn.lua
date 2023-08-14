BaseConn = BaseClass("BaseConn")

function BaseConn:__Init()
    self.host = nil
    self.port = nil
    self.state = ConnState.none
    self.onDispatcher = nil
    self.eventListens = {}
    self.try = 0
    self.maxTry = 5
end

function BaseConn:Connect(host,port)
    if self.state ~= ConnState.none then return end
    self.host = host
    self.port = port
    self:SetState(ConnState.connecting)
    self:OnConnect()
end

function BaseConn:Update()
    self:OnUpdate()
end

function BaseConn:Send(bytes)
    return self:OnSend(bytes)
end

function BaseConn:Recv()
    self:OnRecv()
end

function BaseConn:SetDispatcher(onDispatcher)
    self.onDispatcher = onDispatcher
end

function BaseConn:Dispatcher(bytes)
    if self.onDispatcher then
        self.onDispatcher(bytes)
    end
end

function BaseConn:SetEvent(event,callBack)
    if not self.eventListens[event] then self.eventListens[event] = {} end
    table.insert(self.eventListens[event],callBack)
end

function BaseConn:RemoveEvent(event,callBack)
    local listens = self.eventListens[event]
    if not listens then return end

    local index = nil
    for i,cb in ipairs(listens) do
        if cb == callBack then 
            index = i
            break
        end
    end

    if not index then return end
    table.remove(self.eventListens[event],index)
end

function BaseConn:NoticeEvent(event,param)
    if not self.eventListens[event] then return end
    local listens = self.eventListens[event]
    for _,cb in ipairs(listens) do cb(param) end
end

function BaseConn:SetState(state)
    self.state = state
end

function BaseConn:IsState(state)
    return self.state == state
end

function BaseConn:IsConnect()
    return self.state == ConnState.connected
end

function BaseConn:Disconnect(err)
    if err == NetworkDefine.DisconnectType.return_login and self.state == ConnState.connecting then
        self.state = ConnState.none
        self:RemoveConnTimer()
        self:NoticeEvent(ConnEvent.cancel_connect,err)
        return
    end

    if self.state == ConnState.connected then 
        self.state = ConnState.none
        self:OnDisconnect()
        self:NoticeEvent(ConnEvent.disconnect,err)
    end
end

function BaseConn:RemoveConnTimer()
    if self.connTimer then
        TimerManager.Instance:RemoveTimer(self.connTimer)
        self.connTimer = nil
    end
end

function BaseConn:IsMaxTry()
    return self.try >= self.maxTry
end

function BaseConn:Close()
    self:RemoveConnTimer()
    self:OnDisconnect()
end

function BaseConn:OnUpdate() end
function BaseConn:OnConnect() end
function BaseConn:OnSend(bytes) end
function BaseConn:OnRecv() end
-- function BaseConn:OnPopPack() end
function BaseConn:OnDisconnect() end


function BaseConn.Create(connType)
    local conn = nil
    if connType == NetworkDefine.ConnType.lua_tcp then
        conn = LTcpConn
    elseif connType == NetworkDefine.ConnType.tcp then
        conn = TcpConn
    elseif connType == NetworkDefine.ConnType.udp then
        conn = UdpConn
    elseif connType == NetworkDefine.ConnType.web then
        conn = WebConn
    end
    return conn.New()
end

