Network = BaseClass("Network")

local curProtoId = nil

NET_DEBUG = true

function Network:__Init(connType)
    local define = NetworkDefine
    self.conn = BaseConn.Create(connType)

    self.onHookRecv = nil
    self.handlers = {}

    self.remoteTime = 0
    self.remoteSyncTime = 0

    self.tickTimer = nil
    self.lastTickTime = 0

    self.host = nil
    self.port = nil

    self.tickProtoId = nil
    self.tickTimeout = 0
    self.tickSendInterval = 0
    
    self.conn:SetEvent(ConnEvent.disconnect,self:ToFunc("ConnDisconnect"))

    self.reconnect = NetworkReconnect.New(self)

    self.conn:SetDispatcher(self:ToFunc("Dispatcher"))

    self.resendIds = {}
    self.resendDatas = List.New()
end

function Network.InitGpbParser()
    GpbParser.New()
    GpbParser.Instance:InitGpb()
end

function Network:SetHookRecv(onHookRecv)
    self.onHookRecv = onHookRecv
end

function Network:SetTick(tickProtoId,tickTimeout,tickSendInterval)
    self.tickProtoId = tickProtoId
    self.tickTimeout = tickTimeout
    self.tickSendInterval = tickSendInterval
end

function Network:Connect(host,port)
    print(string.format("Network:Connect(%s, %s)", host, port))
    self.host = host
    self.port = port
    self.conn:Connect(host,port)
end

function Network:AddHandler(id,func,isResend)
    if not self.handlers[id] then
        self.handlers[id] = List.New()
    end
    self.handlers[id]:Push(func,func)

    if isResend then
        self.resendIds[id] = true
    end
end

function Network:RemoveHandler(id,func)
    if self.handlers[id] then
        self.handlers[id]:RemoveByIndex(func)
    end
end

function Network:CleanHandler()
    self.handlers = {}
end

function Network:Dispatcher(bytes)
    local protoId,data = GpbParser.Instance:UnPack(bytes)

    if protoId == self.tickProtoId then
        self:ResetTickTime()
    end

    if self.resendIds[protoId] and self.resendDatas:ExistIndex(protoId) then
        self.resendDatas:RemoveByIndex(protoId)
    end

    if self.handlers[protoId] then
        for iter in self.handlers[protoId]:Items() do
            xpcall(iter.value,Network.PackError, data, protoId)
        end
    end

    if self.onHookRecv then
        self.onHookRecv(protoId,data)
    end
end

-- function Network:RecvPack()
--     self.conn:Recv()
-- end

function Network.PackError(err)
    LogErrorf("处理协议报错[%s]%s",curProtoId,err)
end

function Network:Send(id,data)
    if not self.conn:IsConnect() then
        return
    end

    local byteArray = GpbParser.Instance:Pack(id,data)
    self.conn:Send(byteArray)

    if self.resendIds[id] then
        if self.resendDatas:ExistIndex(id) then
            assert(false,string.format("发送协议异常,需要重发的协议不允许未回包之前多次发送[协议id:%s]",id))
        else
            self.resendDatas:Push(byteArray,id)
        end
    end
end

function Network:ResendData()
    for v in self.resendDatas:Items() do
        self.conn:Send(v.value)
    end
end

function Network:RemoveResendData(protoId)
    if self.resendDatas:ExistIndex(protoId) then
        self.resendDatas:RemoveByIndex(protoId)
    end
end

function Network:CleanResend()
    self.resendDatas:Clear()
end

function Network:Update()
    if self.conn:IsConnect() then
        self.conn:Update()
    end
end

--心跳包相关
function Network:StartTick()
    self.lastTickTime = 0
    self:SendTick()
    self:RemoveTickTimer()
    self.tickTimer = TimerManager.Instance:AddTimer(0,self.tickSendInterval,self:ToFunc("SendTick")) 
end

function Network:RestartTick()
    if not self.tickTimer then 
        self.tickTimer = TimerManager.Instance:AddTimer(0,self.tickSendInterval,self:ToFunc("SendTick")) 
    end
end

function Network:StopTick()
    self.lastTickTime = 0
    self:RemoveTickTimer()
end

function Network:SendTick(ignoreTimeout)
    --Log("发送心跳包")
    local time = os.time()
    if not ignoreTimeout and self:IsTimeout(time) then return end
    self:Send(self.tickProtoId,{ time = time })
end

function Network:IsTimeout(time)
    if self.lastTickTime == 0 then 
        return false 
    end

    if time - self.lastTickTime <= self.tickTimeout then 
        return false
    else
        LogError("心跳包超时导致网络断开")
        self.conn:Disconnect(NetworkDefine.DisconnectType.tick_timeout)
        return true
    end
end

function Network:RemoveTickTimer()
    if self.tickTimer then 
        TimerManager.Instance:RemoveTimer(self.tickTimer)
        self.tickTimer = nil
    end
end

function Network:ResetTickTime()
    --LogColor("心跳包重置")
    self.lastTickTime = os.time()
    self:RestartTick()
end

function Network:ConnDisconnect()
    self:StopTick()
end

function Network:Disconnect(err)
    if not err then err = NetworkDefine.DisconnectType.initiative end
    self.conn:Disconnect(err)
end

function Network:Close()
    self.conn:Close()
end

function Network:SetEvent(event,callBack)
    self.conn:SetEvent(event,callBack)
end

function Network:QueryState()
    Log("网络连接状态",self.conn:GetState())
end

function Network:IsConnect()
    return self.conn:IsConnect()
end

function Network:GetTickTime()
    return self.lastTickTime
end

function Network:SetRemoteTime(time)
    --Log("同步时间",time)
    self.remoteTime = time
    self.remoteSyncTime = Time.realtimeSinceStartup
end

function Network:GetRemoteRemainTime(targetTime)
    local offsetTime = math.ceil(Time.realtimeSinceStartup - self.remoteSyncTime)
	local curTime = self.remoteTime + offsetTime
    local remainTime = targetTime - curTime
    return remainTime > 0 and remainTime or 0
end

function Network:GetRemoteRemainTimeByMs(targetTime)
    local offsetTime = Time.realtimeSinceStartup - self.remoteSyncTime
	local curTime = self.remoteTime + offsetTime
    local remainTime = targetTime - curTime
    return remainTime > 0 and remainTime or 0
end

function Network:GetRemoteTimeByMS()
    local offsetTime = Time.realtimeSinceStartup - self.remoteSyncTime
	return self.remoteTime + offsetTime
end