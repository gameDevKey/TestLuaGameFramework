TemplateViewUI = Class("TemplateViewUI",ViewUI)

function TemplateViewUI:OnInit()
    self:SetupExtendView()
end

function TemplateViewUI:SetupExtendView()
    self:AddExtendView(TemplateExtendView1)
    self:AddExtendView(TemplateExtendView2)
end

function TemplateViewUI:OnEnter(data)
    PrintLog(self,"入场了，数据是",data)
end
function TemplateViewUI:OnEnterComplete()end
function TemplateViewUI:OnExit()
    PrintLog(self,"退场了")
end
function TemplateViewUI:OnExitComplete()end
function TemplateViewUI:OnRefresh()
    PrintLog(self,"重新显示了")
end
function TemplateViewUI:OnHide()
    PrintLog(self,"暂时隐藏了")
end
function TemplateViewUI:OnAssetLoaded(assets)end

return TemplateViewUI