--处理一些纯业务逻辑（不涉及界面的逻辑）
GenericLogicCtrl = SingletonClass("GenericLogicCtrl",CtrlBase)

function GenericLogicCtrl:OnInitComplete()
    self:AddGolbalListenerWithSelfFunc(EGlobalEvent.ViewEnter,"OnViewEnter",false)
    self:AddGolbalListenerWithSelfFunc(EGlobalEvent.ViewExit,"OnViewExit",false)
end

function GenericLogicCtrl:OnViewEnter(type,view)
    PrintLog("界面进入了",view)
end

function GenericLogicCtrl:OnViewExit(type,view)
    PrintLog("界面退出了",view)
end

return GenericLogicCtrl