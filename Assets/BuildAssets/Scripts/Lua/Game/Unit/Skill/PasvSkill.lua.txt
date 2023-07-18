--被动技能，注册事件触发后，立即释放一次，若有CD，则在CD结束后检查一次事件是否满足
PasvSkill = Class("PasvSkill",SkillBase)

function PasvSkill:OnInit()
end

function PasvSkill:OnDelete()
end

function PasvSkill:OnUpdate()
end

return PasvSkill