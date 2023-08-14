SingleSkillComponent = BaseClass("SingleSkillComponent",SECBComponent)
SingleSkillComponent.NAME = "SkillComponent"

function SingleSkillComponent:__Init()
    self.skills = SECBList.New()
end

function SingleSkillComponent:__Delete()
end

function SingleSkillComponent:OnInit()

end

function SingleSkillComponent:OnUpdate()
    for iter in self.skills:Items() do
        local skill = iter.value
        skill:Update()
    end
end

function SingleSkillComponent:AddSkill(skillId,skillLev)
	local baseConf = self.world.BattleConfSystem:SkillData_data_skill_base(skillId)
    assert(baseConf,string.format("不存在技能配置[技能Id:%s][技能等级:%s]",skillId,skillLev))

	local skill = ActSkill.New()

	local uid = self.world:GetUid(BattleDefine.UidType.skill)
	skill:SetWorld(self.world)
	skill:Init(uid,self.entity,skillId,skillLev)

    self.skills:Push(skill,skill.uid)

    return skill
end

function SingleSkillComponent:RelSkill(skillId,skillLev,targets,transInfo)
	local skill = self:AddSkill(skillId,skillLev)
	if not skill then
		assert(false,string.format("单位不存在技能[技能ID:%s]",skillId))
	end

    skill:Rel(targets,transInfo,self:ToFunc("OnSkillComplete"))

	self.world.EventTriggerSystem:Trigger(BattleEvent.rel_skill,self.entity,skill.skillId,skill.skillLev,skill.relUid)
end

function SingleSkillComponent:OnSkillComplete(skill)
    local iter = self.skills:GetIterByIndex(skill.uid)
    local skill = iter.value
    self.skills:RemoveByIndex(skill.uid)
    skill:AddRefNum(-1)
end