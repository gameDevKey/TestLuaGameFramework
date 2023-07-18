TemplateProxy = SingletonClass("TemplateProxy",ProxyBase)

function TemplateProxy:OnInitComplete()
    -- PrintLog("绑定Template协议")
    self:ListenData("Template.data","TemplateDataChange")
    self:ListenData("Template.a.c","TemplateDataChange1")
    self:ListenProto(ProtoDefine.Template, "HandleTemplateProto")
end

function TemplateProxy:OnDelete()
end

function TemplateProxy:HandleTemplateProto(data)
    -- PrintLog("处理Template协议",data)
end

function TemplateProxy:TemplateDataChange(new,old)
    PrintLog("TemplateProxy:Template.data 新值",new,'旧值',old)
end

function TemplateProxy:TemplateDataChange1(new,old)
    PrintLog("TemplateProxy:Template.a.c 新值",new,'旧值',old)
end

return TemplateProxy