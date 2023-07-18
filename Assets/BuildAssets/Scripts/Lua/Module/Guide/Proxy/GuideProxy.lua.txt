GuideProxy = SingletonClass("GuideProxy", ProxyBase)

function GuideProxy:OnInitComplete()
end

function GuideProxy:OnDelete()
end

function GuideProxy:GetBeginGuideId()
    return "Guide001"
end

function GuideProxy:NeedGuide()
    return false
end

return GuideProxy
