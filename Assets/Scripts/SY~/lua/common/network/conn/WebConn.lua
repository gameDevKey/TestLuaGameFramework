WebConn = BaseClass("WebConn",BaseConn)

function WebConn:__Init()
    self.maxTry = 10
    self.recvFunc = self:ToFunc("OnRecv")
    self.sendFailFunc = self:ToFunc("OnSendFail")
    self.recvFailFunc = self:ToFunc("OnRecvFail")
end

function WebConn:OnConnect()
    self.try = 0
    self.socket = WebSocketClient()
    self.socket:SetRecv(self,"recvFunc")
    self.socket:SetSendFail(self,"sendFailFunc")
    self.socket:SetRecvFail(self,"recvFailFunc")

    self.socket:Connect(self.host)
    self.connTimer = TimerManager.Instance:AddTimer(0, 0.3, self:ToFunc("LoopConnect"))
    self.connTimeoutTimer = TimerManager.Instance:AddTimer(1,10, self:ToFunc("ConnectTimeout"))
end

function WebConn:LoopConnect()
    if self.state ~= ConnState.connecting then 
        return
    end

    --Log("尝试连接",self.try)

    if self.socket:CheckConnectFail() then
        self:RemoveTimeoutTimer()
        self:RemoveConnTimer()
        self:ConnectFail()
    elseif self.socket:CheckConnectResult() then
        self:Handshake()
        self:RemoveTimeoutTimer()
        self:RemoveConnTimer()
        self:ConnectSucceed()
    end
end

function WebConn:ConnectTimeout()
    self.connTimeoutTimer = nil
    self:RemoveConnTimer()
    self:ConnectFail()
end


function WebConn:RemoveTimeoutTimer()
    if self.connTimeoutTimer then
        TimerManager.Instance:RemoveTimer(self.connTimeoutTimer)
        self.connTimeoutTimer = nil
    end
end

function WebConn:Handshake()
    local byteArry = ByteArray.New()
    byteArry:writeString("web_socket-------------")
    local byteLen = byteArry:getAvailable()
    self.socket:ImmedSend(byteArry:getPack(),0,byteLen)
end

function WebConn:OnSend(bytes)
    if not self.socket or not self:IsConnect() then
        return false
    end
   
    self.socket:SendData(bytes)
    return true
end

function WebConn:OnRecv(bytes)
    --Log("接收到包了")
    self:Dispatcher(bytes)
end

function WebConn:OnSendFail()
    self:Disconnect(NetworkDefine.DisconnectType.send_fail)
end

function WebConn:OnRecvFail()
    self:Disconnect(NetworkDefine.DisconnectType.recv_fail)
end

function WebConn:ConnectFail()
    Log("连接失败")
    self:SetState(ConnState.none)
    self:NoticeEvent(ConnEvent.connect_fail)
end

function WebConn:ConnectSucceed()
    Log("连接成功")
    self.socket:Started()
    self:SetState(ConnState.connected)
    self:NoticeEvent(ConnEvent.connected)
end

function WebConn:OnDisconnect()
    if self.socket then
        self.socket:Disconnect()
        self.socket = nil
    end
end
