TemplateFacade = SingletonClass("TemplateFacade",FacadeBase)

function TemplateFacade:OnInit()
end

function TemplateFacade:OnInitComplete()
    -- PrintLog("TemplateFacade:OnInitComplete")
    self:AddGolbalListenerWithSelfFunc(EGlobalEvent.TemplateModule, "TemplateFunc", "start TemplateFacade")
end

function TemplateFacade:TemplateFunc(...)
    PrintLog("执行TemplateFacade:TemplateFunc",...)
    self:Broadcast(ETemplateModule.LogicEvent.DoSomething,"DoSomething Success!")
end

return TemplateFacade