TemplateExtendView1 = Class("TemplateExtendView1",ViewUI)

function TemplateExtendView1:OnEnter(data)
    PrintLog(self,"入场了，数据是",data)
end
function TemplateExtendView1:OnEnterComplete()end
function TemplateExtendView1:OnExit()
    PrintLog(self,"退场了")
end
function TemplateExtendView1:OnExitComplete()end
function TemplateExtendView1:OnRefresh()
    PrintLog(self,"重新显示了")
end
function TemplateExtendView1:OnHide()
    PrintLog(self,"暂时隐藏了")
end
function TemplateExtendView1:OnAssetLoaded(assets)end

return TemplateExtendView1