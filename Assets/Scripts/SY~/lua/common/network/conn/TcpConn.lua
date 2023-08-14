TcpConn = BaseClass("TcpConn",BaseConn)

function TcpConn:__Init()
    self.recvFunc = self:ToFunc("OnRecv")
    self.sendFailFunc = self:ToFunc("OnSendFail")
    self.recvFailFunc = self:ToFunc("OnRecvFail")
end

function TcpConn:OnConnect()
    self.try = 0
    self.socket = TCPSocket()
    self.socket:SetRecv(self,"recvFunc")
    self.socket:SetSendFail(self,"sendFailFunc")
    self.socket:SetRecvFail(self,"recvFailFunc")

    self.socket:Connect(self.host,self.port)
    self.connTimer = TimerManager.Instance:AddTimer(self.maxTry, 0.5, self:ToFunc("LoopConnect"))
end

function TcpConn:LoopConnect()
    if self.state ~= ConnState.connecting then 
        return
    end

    self.try = self.try + 1
    if self.try >= self.maxTry then
        self.connTimer = nil
    end
    Log("尝试连接",self.try)

    local succeed,fail = false,false

    local connectFlag = self.socket:CheckConnectResult()
    if connectFlag then
        local flag = self:Handshake()
        if flag then
            succeed = true
        else
            fail = true
        end
    end

    if succeed then
        self:RemoveConnTimer()
        self:ConnectSucceed()
    elseif fail or self:IsMaxTry() then
        self:RemoveConnTimer()
        self:ConnectFail()
    else
        self.socket:Connect(self.host,self.port)
    end
end

function TcpConn:Handshake()
    local byteArry = ByteArray.New()
    byteArry:writeString(NetworkDefine.handshake)
    local byteLen = byteArry:getAvailable()
    local sendLen = self.socket:ImmedSend(byteArry:getPack(),0,byteLen)
    return sendLen == byteLen
end

function TcpConn:OnSend(bytes)
    if not self.socket or not self:IsConnect() then
        return false
    end
   
    self.socket:SendData(bytes)
    return true
end

function TcpConn:OnRecv(bytes)
    --Log("接收到包了")
    self:Dispatcher(bytes)
end

function TcpConn:OnSendFail()
    self:Disconnect(NetworkDefine.DisconnectType.send_fail)
end

function TcpConn:OnRecvFail()
    self:Disconnect(NetworkDefine.DisconnectType.recv_fail)
end

function TcpConn:ConnectFail()
    Log("连接失败")
    self:SetState(ConnState.none)
    self:NoticeEvent(ConnEvent.connect_fail)
end

function TcpConn:ConnectSucceed()
    Log("连接成功")
    self.socket:SetKeepAliveValues(1,30000,10000)
    self.socket:Started()
    self:SetState(ConnState.connected)
    self:NoticeEvent(ConnEvent.connected)
end


function TcpConn:OnDisconnect()
    if self.socket then
        self.socket:Disconnect()
        self.socket = nil
    end
end
