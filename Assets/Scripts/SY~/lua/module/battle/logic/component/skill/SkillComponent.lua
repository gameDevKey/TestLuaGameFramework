SkillComponent = BaseClass("SkillComponent",SECBComponent)

function SkillComponent:__Init()
	self.runActSkill = nil
	self.targetEntitys = nil
    self.actSkills = nil
	self.pasvSkills = nil
	self.singleSkills = SECBList.New()
	self.skillDict = {}
    self.onComplete = nil
end

function SkillComponent:__Delete()
	self:Abort()

	for _,skill in ipairs(self.actSkills) do
		skill:SetEnable(false)
		skill:AddRefNum(-1)
	end

	for _,skill in ipairs(self.pasvSkills) do
		skill:SetEnable(false)
		skill:AddRefNum(-1)
	end

	for iter in self.singleSkills:Items() do
		local skill = iter.value
		skill:SetEnable(false)
		skill:AddRefNum(-1)
	end
	self.singleSkills:Delete()

	-- self:Clear()
end

function SkillComponent:OnInit()
end

function SkillComponent:InitSkill(skills)
	self.actSkills = {}
	self.pasvSkills = {}
	for i,v in ipairs(skills) do
		self:AddSkill(v.skill_id,v.skill_level)
	end
	self:SortSkill()
end

function SkillComponent:RepSkill(skillId,skillLev,notSort)
	local skill = self:GetSkill(skillId)
	if skill and skill.skillLev == skillLev then
		return
	end

	if skill then
		self:RemoveSkill(skill)
	end

	self:AddSkill(skillId,skillLev)

	skill = self:GetSkill(skillId)
	
	if not notSort and skill.baseConf.rel_type ~= SkillDefine.RelType.pasv then
		self:SortSkill()
	end
end

function SkillComponent:SortSkill()
	table.sort(self.actSkills, self:ToFunc("SortActSkills"))
end

function SkillComponent:RemoveSKillById(skillId)
	local skill = self:GetSkill(skillId)
	if skill then
		self:RemoveSkill(skill)
	end
end

function SkillComponent:RemoveSkill(skill)
	--skill:SetEnable(false)
	skill:SetRemove(true)
	if skill.baseConf.rel_type == SkillDefine.RelType.pasv then
		local index = nil
		for i,v in ipairs(self.pasvSkills) do
			if v.skillId == skill.skillId then
				index = i
				break
			end
		end
		if index then
			table.remove(self.pasvSkills,index)
		end
	else
		if not self.runActSkill or self.runActSkill.uid ~= skill.uid then
			local index = nil
			for i,v in ipairs(self.actSkills) do
				if v.skillId == skill.skillId then
					index = i
					break
				end
			end
			if index then
				table.remove(self.actSkills,index)
			end
		end
	end
	self.skillDict[skill.skillId] = nil
	skill:SetEnable(false)
	skill:AddRefNum(-1)
end

function SkillComponent:AddSkill(skillId,skillLev)
	local baseConf = self.world.BattleConfSystem:SkillData_data_skill_base(skillId)
    assert(baseConf,string.format("不存在技能配置[技能Id:%s][技能等级:%s]",skillId,skillLev))

	if self.skillDict[skillId] then
		return
	end

	local skill = nil
	if baseConf.rel_type == SkillDefine.RelType.pasv then
		skill = PasvSkill.New()
		table.insert(self.pasvSkills,skill)
	else
		skill = ActSkill.New()
		table.insert(self.actSkills,skill)
	end

	local uid = self.world:GetUid(BattleDefine.UidType.skill)
	skill:SetWorld(self.world)
	skill:Init(uid,self.entity,skillId,skillLev)
	
	self.skillDict[skillId] = skill
end

function SkillComponent:SortActSkills(a,b)
	if a.baseConf.priority > b.baseConf.priority then
		return true
	elseif a.baseConf.priority < b.baseConf.priority then
		return false
	end
	return a.uid < b.uid
end

function SkillComponent:GetSkillLev(skillId)
	return self.skillDict[skillId].lev
end

function SkillComponent:GetSkill(skillId)
	return self.skillDict[skillId]
end

function SkillComponent:GetCurSkill()
	return self.runSkill
end

function SkillComponent:ExistSkill(skillId)
	return self.skillDict[skillId] ~= nil
end

function SkillComponent:OnUpdate()
	for i,v in ipairs(self.actSkills) do
		v:Update()
	end

	for i,v in ipairs(self.pasvSkills) do
		v:Update()
	end

	for iter in self.singleSkills:Items() do
		local skill = iter.value
		skill:Update()
	end

	if not self.runActSkill then
		return
	end

	if self:CanFinish() then
		self:Finish()
	end
end

function SkillComponent:Finish()
	self.entity.StateComponent:SetState(BattleDefine.EntityState.idle)
	self:Clear()
end

function SkillComponent:Break()
	self.entity.StateComponent:SetState(BattleDefine.EntityState.idle)
	self:Clear()
end

function SkillComponent:CanFinish()
	return self.runActSkill:IsFinish()
end

function SkillComponent:SetComplete(onComplete)
    self.onComplete = onComplete
end

function SkillComponent:RelSkill(skillId,targets,transInfo)
	local skill = self:GetSkill(skillId)
	if not skill then
		assert(false,string.format("单位不存在技能[技能ID:%s]",skillId))
	end

	self.entity.KvDataComponent:SetData(BattleDefine.EntityKvType.last_select_target,targets[1])

	if not transInfo then
		transInfo = {}
		self:SetTargetTransInfo(skill,transInfo,targets[1])
	end

	if skill.baseConf.rel_type == SkillDefine.RelType.pasv then
		self:RelPasvSkill(skill,targets,transInfo)
	else
		self:RelActionSkill(skill,targets,transInfo)
	end

	if skill.levConf.add_energy_rate ~= 0 then
		local maxEnergy = self.entity.AttrComponent:GetValue(GDefine.Attr.max_energy)
		local addEnergy = FPMath.Divide(maxEnergy * skill.levConf.add_energy_rate,BattleDefine.AttrRatio)
		self.entity.AttrComponent:AddValue(BattleDefine.Attr.energy,addEnergy)
		self.world.ClientIFacdeSystem:Call("SendEvent","FlyingTextView","ShowFlyingText",BattleDefine.FlyingText.energy,
            {value = addEnergy,uid = self.entity.uid})
	end

	self.world.EventTriggerSystem:Trigger(BattleEvent.rel_skill,self.entity,skill.uid,skill.skillId,skill.skillLev,skill.relUid)

	self:ShowSkillName(skill)

	if skill.levConf.atk_range.debug then
		self.entity:CallClientComponentFunc("ClientRangeComponent","AddSkillAtkRange",skill,transInfo)
	end
end

function SkillComponent:RelPasvSkill(skill,targets,transInfo)
	skill:Rel(targets,transInfo,self:ToFunc("OnSkillComplete"))
end

function SkillComponent:RelActionSkill(skill,targets,transInfo)
	self.runActSkill = skill

	self.targetEntitys = targets

	self.entity.StateComponent:SetState(BattleDefine.EntityState.skill)

	if self.entity.MoveComponent then
		self.entity.MoveComponent:StopMove()
	end

	self:SetRelDir(transInfo,targets[1])

	local relPos = self.entity.TransformComponent:GetPos()
	skill:SetData(SkillDefine.DataKey.rel_pos,relPos)

	self.runActSkill:Rel(targets,transInfo,self:ToFunc("OnSkillComplete"))
end

function SkillComponent:HasRunSkill()
	return self.runActSkill ~= nil
end

function SkillComponent:GetRunSkill()
	return self.runActSkill
end

function SkillComponent:AddSingleSkill(skillId,skillLev)
	local baseConf = self.world.BattleConfSystem:SkillData_data_skill_base(skillId)
    assert(baseConf,string.format("不存在技能配置[技能Id:%s][技能等级:%s]",skillId,skillLev))

	local skill = ActSkill.New()

	local uid = self.world:GetUid(BattleDefine.UidType.skill)
	skill:SetWorld(self.world)
	skill:Init(uid,self.entity,skillId,skillLev)

    self.singleSkills:Push(skill,skill.uid)

    return skill
end

function SkillComponent:RelSingleSkill(skillId,skillLev,targets,transInfo)
	local skill = self:AddSingleSkill(skillId,skillLev)
	if not skill then
		assert(false,string.format("单位不存在技能[技能ID:%s]",skillId))
	end
	if not transInfo then
		transInfo = {}
		self:SetTargetTransInfo(skill,transInfo,targets[1])
	end
	skill:Rel(targets,transInfo,self:ToFunc("OnSingleSkillComplete"))

	self.world.EventTriggerSystem:Trigger(BattleEvent.rel_skill,self.entity,skill.uid,skill.skillId,skill.skillLev,skill.relUid)
end

function SkillComponent:OnSingleSkillComplete(skill)
    local iter = self.singleSkills:GetIterByIndex(skill.uid)
    local skill = iter.value
    self.singleSkills:RemoveByIndex(skill.uid)
    skill:AddRefNum(-1)
end

function SkillComponent:OnSkillComplete(skill)
	self.world.EventTriggerSystem:Trigger(BattleEvent.skill_complete,self.entity.uid,skill.skillId,skill.skillLev,skill.relUid)
end

function SkillComponent:SetRelDir(transInfo,firstEntityUid)
	if not self.entity.RotateComponent then
		return
	end

	if self.runActSkill.baseConf.rel_dir == SkillDefine.RelDir.target and firstEntityUid then
		local firstEntity = self.world.EntitySystem:GetEntity(firstEntityUid)
		self.entity.RotateComponent:LookAtTarget(firstEntity)
	end
end

local fpVec3_1 = FPVector3(0,0,0)
function SkillComponent:SetTargetTransInfo(skill,transInfo,firstEntityUid)
	if skill.baseConf.rel_center == SkillDefine.RelCenter.self then
		local pos = self.entity.TransformComponent:GetPos()
		local forward = self.entity.TransformComponent:GetForward()
		transInfo.posX = pos.x
		transInfo.posZ = pos.z
	elseif skill.baseConf.rel_center == SkillDefine.RelCenter.target then
		if not firstEntityUid then
			assert(false,string.format("技能释放异常，以目标为释放中心点，但是又可以空放，导致技能释放时没有目标[技能Id:%s]",skill.skillId))
		end
		local firstEntity = self.world.EntitySystem:GetEntity(firstEntityUid)
		local targetPos = firstEntity.TransformComponent:GetPos()
		transInfo.posX = targetPos.x
		transInfo.posZ = targetPos.z
	elseif skill.baseConf.rel_center == SkillDefine.RelCenter.random_self_camp_area then
		local x,z = self.world.BattleTerrainSystem:GetCampAreaRandomPos(self.entity.CampComponent.camp)
		local forward = self.entity.TransformComponent:GetForward()
		transInfo.posX = x
		transInfo.posZ = z
		transInfo.dirX = forward.x
		transInfo.dirZ = forward.z
	elseif skill.baseConf.rel_center == SkillDefine.RelCenter.random_enemy_camp_area then
		local x,z = self.world.BattleTerrainSystem:GetCampAreaRandomPos(self.entity.CampComponent:GetEnemyCamp())
		local forward = self.entity.TransformComponent:GetForward()
		transInfo.posX = x
		transInfo.posZ = z
		transInfo.dirX = forward.x
		transInfo.dirZ = forward.z
	end

	if skill.baseConf.rel_dir == SkillDefine.RelDir.keep then
		local forward = self.entity.TransformComponent:GetForward()
		transInfo.dirX = forward.x
		transInfo.dirZ = forward.z
	elseif skill.baseConf.rel_dir == SkillDefine.RelDir.forward then
		transInfo.dirX = 0
		transInfo.dirZ = self.entity.CampComponent:IsCamp(BattleDefine.Camp.attack) and FPFloat.Precision or -FPFloat.Precision
	else
		if not firstEntityUid then
			assert(false,string.format("技能释放异常，释放朝向是目标，但是又可以空放，导致技能释放时无法获取方向[技能Id:%s]",skill.skillId))
		end
		local firstEntity = self.world.EntitySystem:GetEntity(firstEntityUid)
		local targetPos = firstEntity.TransformComponent:GetPos()

		local selfPos = self.entity.TransformComponent:GetPos()

		fpVec3_1:Set(selfPos.x,targetPos.y,selfPos.z)
		selfPos = fpVec3_1

		if targetPos == selfPos then
			local forward = self.entity.TransformComponent:GetForward()
			transInfo.dirX = forward.x
			transInfo.dirZ = forward.z
		else
			local dir = targetPos - selfPos
			dir:Normalize()
			transInfo.dirX = dir.x
			transInfo.dirZ = dir.z
		end
	end
end

function SkillComponent:ShowSkillName(skill)
	if not self.world.opts.isClient then
        return
    end

	if skill.baseConf.skill_name_type == SkillDefine.SkillNameType.head_top or
		skill.baseConf.skill_name_type == SkillDefine.SkillNameType.head_top_and_banner then
		local textType = BattleDefine.FlyingText.skill
		local args = {}
		args.uid = self.entity.uid
		args.skillName = skill.baseConf.name
		args.offsetY = 30
		args.isTopPos = true
		mod.BattleFacade:SendEvent(FlyingTextView.Event.ShowFlyingText,textType,args)
	end

	if skill.baseConf.skill_name_type == SkillDefine.SkillNameType.banner or
		skill.baseConf.skill_name_type == SkillDefine.SkillNameType.head_top_and_banner then
		local unitId = self.entity.ObjectDataComponent.unitConf.id
		local skillId = skill.baseConf.id
		local textType = BattleDefine.FlyingText.skill_banner
		local args = {}
		args.unitId = unitId
		args.skillId = skillId
		mod.BattleFacade:SendEvent(FlyingTextView.Event.ShowFlyingText,textType,args)
		-- mod.BattleFacade:SendEvent(BattleSkillBannerView.Event.ShowBanner,unitId,skillId)
	end
end

function SkillComponent:Abort()
	self:Clear()
	for _,skill in ipairs(self.actSkills) do
		skill:Clear()
	end

	for _,skill in ipairs(self.pasvSkills) do
		skill:Clear()
	end
end

function SkillComponent:Clear()
	if not self.runActSkill then
		return
	end

	if self.runActSkill.isRemove then
		local index = nil
		for i,v in ipairs(self.actSkills) do
			if v.uid == self.runActSkill.uid then
				index = i
				break
			end
		end
		if index then
			table.remove(self.actSkills,index)
		end
	end

	self.runActSkill:Clear()

	self.runActSkill = nil
	self.targetEntitys = nil
end