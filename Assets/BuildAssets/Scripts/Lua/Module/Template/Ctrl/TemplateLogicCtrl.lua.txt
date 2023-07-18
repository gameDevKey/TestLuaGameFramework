--处理一些纯业务逻辑（不涉及界面的逻辑）
TemplateLogicCtrl = SingletonClass("TemplateLogicCtrl",CtrlBase)

function TemplateLogicCtrl:OnInitComplete()
    self:AddListenerWithSelfFunc(ETemplateModule.LogicEvent.DoSomething, "TemplateFunc", false)
end

function TemplateLogicCtrl:TemplateFunc(result)
    for i = 1, 3 do
        self:Broadcast(ETemplateModule.ViewEvent.ActiveTemplateView,{msg="数据"..i})
        UIManager.Instance:Log()
    end

    for i = 1, 2 do
        UIManager.Instance:ExitTop()
        UIManager.Instance:Log()
    end
end

return TemplateLogicCtrl