NetworkReconnect = SingleClass("NetworkReconnect")


function NetworkReconnect:__Init(network)
    self.network = network
    self.reconneting = false
    self.reconnectStep = NetworkDefine.ReconnectStep.none
    self.reconnetTime = 0
    self.timer = nil

    self.onCheckReconnet = nil
    self.onStartReconnect = nil
    self.onFinishReconnect = nil
    self.onStepReconnect = nil

    self.timeout = 0

    self.canReconnect = true
end

function NetworkReconnect:InitReconnect()
    self.network:SetEvent(ConnEvent.disconnect,self:ToFunc("Disconnect"))
    self.network:SetEvent(ConnEvent.connect_fail,self:ToFunc("ConnectFail"))
    self.network:SetEvent(ConnEvent.connected,self:ToFunc("Connected"))
    self.network:SetEvent(ConnEvent.cancel_connect,self:ToFunc("CancelConnect"))
end

function NetworkReconnect:SetCheckReconnet(onCheckReconnet)
    self.onCheckReconnet = onCheckReconnet
end

function NetworkReconnect:SetStartReconnect(onStartReconnect)
    self.onStartReconnect = onStartReconnect
end

function NetworkReconnect:SetFinishReconnect(onFinishReconnect)
    self.onFinishReconnect = onFinishReconnect
end

function NetworkReconnect:SetStepReconnect(onStepReconnect)
    self.onStepReconnect = onStepReconnect
end

function NetworkReconnect:SetTimeout(timeout)
    self.timeout = timeout
end

function NetworkReconnect:SetCanReconnect(flag)
    self.canReconnect = false
end

function NetworkReconnect:IsReconneting()
    return self.reconneting
end

function NetworkReconnect:Disconnect(err)
    LogInfo(string.format("断线了[err:%s]", tostring(err)))
    self:StartReconnect()
end

function NetworkReconnect:StartReconnect()
    if not self.canReconnect then
        return
    end

    if not self.onCheckReconnet or not self.onCheckReconnet() then
        return
    end

    self.reconneting = true

    if self.onStartReconnect then
        self.onStartReconnect()
    end

    self:SetStep(NetworkDefine.ReconnectStep.begin)
    self:DelayReconnect(1)
end

function NetworkReconnect:Connected()
    if self.reconneting then
        if self.onFinishReconnect then
            self.onFinishReconnect()
        end
        self.reconneting = false
        self.reconnectStep = NetworkDefine.ReconnectStep.none
    end
end

function NetworkReconnect:ConnectFail()
    if not self.reconneting then 
        return 
    end

    if self.reconnectStep == NetworkDefine.ReconnectStep.begin then
        self:SetStep(NetworkDefine.ReconnectStep.lasting)
        self:DelayReconnect(1)
    elseif self.reconnectStep == NetworkDefine.ReconnectStep.lasting then
        if self.timeout > 0 and Time.time - self.reconnetTime >= self.timeout then
            self:SetStep(NetworkDefine.ReconnectStep.timeout)
        end
        self:DelayReconnect(1)
    elseif self.reconnectStep == NetworkDefine.ReconnectStep.timeout then
        self:DelayReconnect(1)
    end
end

function NetworkReconnect:SetStep(step)
    self.reconnectStep = step
    self.reconnetTime = Time.time
    if self.onStepReconnect then
        self.onStepReconnect(step)
    end
end

function NetworkReconnect:DelayReconnect(delayTime)
    self:RemoveTimer()

    if not delayTime or delayTime <= 0 then
        self:Reconnect()
    else
        self.timer = TimerManager.Instance:AddTimerByNextFrame(1,delayTime,self:ToFunc("Reconnect"))
    end
end

function NetworkReconnect:Reconnect()
    self.timer = nil
    if self.reconneting then
        Network.Instance:Connect(Network.Instance.host, Network.Instance.port)
    end
end

function NetworkReconnect:RemoveTimer()
    if self.timer then
        TimerManager.Instance:RemoveTimer(self.timer)
        self.timer = nil
    end
end

function NetworkReconnect:RetryConnect()
    self:SetStep(NetworkDefine.ReconnectStep.begin)
end

function NetworkReconnect:CancelConnect()
    self.reconneting = false
    self.reconnectStep = NetworkDefine.ReconnectStep.none
    self:RemoveTimer()
end