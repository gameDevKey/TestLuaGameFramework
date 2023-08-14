DragUsePveSkillGuideNode = BaseClass("DragUsePveSkillGuideNode",DragUseSkillGuideNodeBase)

function DragUsePveSkillGuideNode:OnInit()
    self:SetEvent(PlayerGuideDefine.Event.use_pve_skill)
end