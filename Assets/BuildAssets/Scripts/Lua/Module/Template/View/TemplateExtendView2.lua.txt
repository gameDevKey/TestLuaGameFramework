TemplateExtendView2 = Class("TemplateExtendView2",ViewUI)

function TemplateExtendView2:OnEnter(data)
    PrintLog(self,"入场了，数据是",data)
end
function TemplateExtendView2:OnEnterComplete()end
function TemplateExtendView2:OnExit()
    PrintLog(self,"退场了")
end
function TemplateExtendView2:OnExitComplete()end
function TemplateExtendView2:OnRefresh()
    PrintLog(self,"重新显示了")
end
function TemplateExtendView2:OnHide()
    PrintLog(self,"暂时隐藏了")
end
function TemplateExtendView2:OnAssetLoaded(assets)end

return TemplateExtendView2