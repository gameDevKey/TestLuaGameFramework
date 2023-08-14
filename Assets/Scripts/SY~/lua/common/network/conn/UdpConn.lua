UdpConn = BaseClass("UdpConn",BaseConn)

function UdpConn:__Init()
    self.recvFunc = self:ToFunc("OnRecv")
    self.sendFailFunc = self:ToFunc("OnSendFail")
    self.recvFailFunc = self:ToFunc("OnRecvFail")
    self.sessionId = 0
    self.connectFlag = false
    self.handshakeProtoId = 10060
    self.headshakeUid = 0


    self.kcpMode = KcpMode.fast
end

function UdpConn:SetKcpMode()
    --配置窗口大小：平均延迟200ms，每20ms发送一个包，
    --而考虑到丢包重发，设置最大收发窗口为128
    self.socket:SetWndSize(128, 128)

    if self.kcpMode == KcpMode.default then
        --默认模式
        self.socket:SetNoDelay(0, 10, 0, 0)
    elseif self.kcpMode == KcpMode.common then
        --普通模式，关闭流控等
        self.socket:SetNoDelay(0, 10, 0, 1)
    else
        --启动快速模式
        --第二个参数 nodelay-启用以后若干常规加速将启动
        --第三个参数 interval为内部处理时钟，默认设置为 10ms
        --第四个参数 resend为快速重传指标，设置为2
        --第五个参数 为是否禁用常规流控，这里禁止
        self.socket:SetNoDelay(1, 10, 2, 1)
    end
end

function UdpConn:OnConnect(sessionId)
    self.try = 0
    self.sessionId = sessionId

    self:CreateSocket()
    self.connTimer = TimerManager.Instance:AddTimer(self.maxTry, 0.5, self:ToFunc("LoopConnect"))
end


function UdpConn:LoopConnect()
    if self.state ~= ConnState.connecting then 
        return
    end

    self.try = self.try + 1
    if self.try >= self.maxTry then
        self.connTimer = nil
    end
    Log("尝试连接",self.try)

    if self.connectFlag then
        self:RemoveConnTimer()
        self:ConnectSucceed()
    elseif self:IsMaxTry() then
        self:RemoveConnTimer()
        self:ConnectFail()
    else
        self:Close()
        self:CreateSocket()
    end
end

function UdpConn:SetSessionId(sessionId)
    self.sessionId = sessionId
end

function UdpConn:CreateSocket()
    self.socket = UDPSocket()
    self.socket:SetRecv(self,"recvFunc")
    self.socket:SetSendFail(self,"sendFailFunc")
    self.socket:SetRecvFail(self,"recvFailFunc")
    self.socket:Started()
    self.socket:Connect(self.host,self.port,self.sessionId)
    self:SetKcpMode()
    self:Handshake()
end

function UdpConn:Handshake()
    self.headshakeUid = self.headshakeUid + 1
    local data = GpbParser.Instance:Pack(self.handshakeProtoId,{headshakeUid = self.headshakeUid})
    self.socket:ImmedSend(data,0,#data)
end

function UdpConn:OnSend(bytes)
    if not self.socket or not self:IsConnect() then
        return false
    end
   
    self.socket:SendData(bytes)
    return true
end

function UdpConn:OnRecv(bytes)
    if self.state == ConnState.connecting then
        local protoId,data = GpbParser.Instance:UnPack(bytes)
        if protoId == self.handshakeProtoId and data.headshakeUid == self.headshakeUid then
            self.connectFlag = true
        end
    else
        self:Dispatcher(bytes)
    end
end

function UdpConn:OnSendFail()
    self:Disconnect(NetworkDefine.DisconnectType.send_fail)
end

function UdpConn:OnRecvFail()
    self:Disconnect(NetworkDefine.DisconnectType.recv_fail)
end

function UdpConn:ConnectFail()
    Log("连接失败")
    self:Close()
    self:SetState(ConnState.none)
    self:NoticeEvent(ConnEvent.connect_fail)
end

function UdpConn:ConnectSucceed()
    Log("连接成功")
    self:SetState(ConnState.connected)
    self:NoticeEvent(ConnEvent.connected)
end


function UdpConn:OnDisconnect()
    if self.socket then
        self.socket:Disconnect()
        self.socket = nil
    end

    self.sessionId = 0
    self.connectFlag = false
end