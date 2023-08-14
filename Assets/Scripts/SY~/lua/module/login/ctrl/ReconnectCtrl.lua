ReconnectCtrl = BaseClass("ReconnectCtrl",Controller)

function ReconnectCtrl:__Init()
    self.reconnetFlag = false
end

function ReconnectCtrl:__Delete()

end

function ReconnectCtrl:__InitComplete()
    NetworkReconnect.Instance:InitReconnect()
    NetworkReconnect.Instance:SetTimeout(5) --设置10秒超时
    NetworkReconnect.Instance:SetCheckReconnet(self:ToFunc("CheckReconnet"))
    NetworkReconnect.Instance:SetStartReconnect(self:ToFunc("StartReconnect"))
    NetworkReconnect.Instance:SetFinishReconnect(self:ToFunc("FinishReconnect"))
    NetworkReconnect.Instance:SetStepReconnect(self:ToFunc("StepReconnect"))
    EventManager.Instance:AddEvent(EventDefine.reconnet_init_data_complete,self:ToFunc("ReconnetInitDataComplete"))
end

function ReconnectCtrl:CheckReconnet()
    --其它设备登录
    if mod.LoginProxy.remotelogin then
        return false
    end

    --还未登录
    if not mod.LoginProxy:IsLogin() then
        return false
    end

    return true
end

function ReconnectCtrl:StartReconnect()
    --启动重连时的一些操作（关闭对话框等）
    self.reconnetFlag = true
    Log("启动重连")
end

function ReconnectCtrl:FinishReconnect()
    SystemMessage.Show("重连成功")
    Log("重连成功")
end

function ReconnectCtrl:StepReconnect(step)
    if step == NetworkDefine.ReconnectStep.lasting then
        Log("显示重连动画")
        --显示重连动画
        --锁屏
    elseif step == NetworkDefine.ReconnectStep.timeout then
        Log("显示重连失败对话框")
        --显示失败弹框
    end
end


function ReconnectCtrl:DoRelogin()
    NetworkReconnect.Instance:CancelConnect()
    mod.LoginCtrl:ReturnLogin()
    --隐藏重连面板
end

function ReconnectCtrl:DoRetryConnect()
    NetworkReconnect.Instance:RetryConnect()
    --显示重连动画，关闭重连失败对话框
end

function ReconnectCtrl:ReconnetInitDataComplete()
    Network.Instance:ResendData()
end