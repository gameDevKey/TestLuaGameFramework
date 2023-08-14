DragUseRageSkillGuideNode = BaseClass("DragUseRageSkillGuideNode",DragUseSkillGuideNodeBase)

function DragUseRageSkillGuideNode:OnInit()
    self:SetEvent(PlayerGuideDefine.Event.use_rage_skill)
end