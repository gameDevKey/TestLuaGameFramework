BattleCastSkillSystem = BaseClass("BattleCastSkillSystem",SECBEntitySystem)

function BattleCastSkillSystem:__Init()
    self.skillSearchParams = {transInfo = {}}
    self.rangeSearchParams = {transInfo = {}}
	self.castSkillArgs = {canAtkFly = false,canAtkFloor = false}
end

function BattleCastSkillSystem:__Delete()

end

function BattleCastSkillSystem:OnInitSystem()

end

function BattleCastSkillSystem:OnLateInitSystem()
    
end

function BattleCastSkillSystem:GetCastSkill(entity,params)
    if not params then params = {} end
    local selectSkills = {}

	self.castSkillArgs.canAtkFly = false
	self.castSkillArgs.canAtkFloor = false
	
	self.skillSearchParams.entity = entity
	self.skillSearchParams.checkCampSort = params.checkCampSort

    for i,skill in ipairs(entity.SkillComponent.actSkills) do
        if skill:CanRel() and skill:CheckPreCond() then
			if not self.castSkillArgs.canAtkFly and skill.canAtkFly then
				self.castSkillArgs.canAtkFly = true
			end
			if not self.castSkillArgs.canAtkFloor and skill.canAtkFloor then
				self.castSkillArgs.canAtkFloor = true
			end

            local atkRange = skill:GetAtkRange()
            self.skillSearchParams.range = atkRange
			self.skillSearchParams.priorityEntityUid = params.priorityEntityUid
			self.skillSearchParams.isLock = true
			
			local skillInfo = nil
			if skill.levConf.target_num == -1 then
				skillInfo = {skill = skill,entitys = {},isPriority = false}
			else
				local entitys,entityDict = self:SkillSearchEntity(skill,self.skillSearchParams)
				if skill.baseConf.no_target_rel == 1 or #entitys > 0  then
					skillInfo = {skill = skill,entitys = entitys,isPriority = false}
					if self.skillSearchParams.priorityEntityUid then 
						skillInfo.isPriority = entityDict[self.skillSearchParams.priorityEntityUid] ~= nil
					end
				end
			end

			if skillInfo then
				if not params.priorityEntityUid or skillInfo.isPriority then
					return skillInfo.skill,skillInfo.entitys,self.castSkillArgs
				else
					table.insert(selectSkills,skillInfo)
				end
			end
        end
	end

    local selectSkill = nil
	for i,v in ipairs(selectSkills) do
		if not selectSkill then
			selectSkill = v
		elseif v.isPriority and not selectSkill.isPriority then
			selectSkill = v
		elseif v.skill.baseConf.priority > selectSkill.skill.baseConf.priority then
			selectSkill = v
		end
	end

	if selectSkill then
		return selectSkill.skill,selectSkill.entitys,self.castSkillArgs
	else
		return nil,nil,self.castSkillArgs
	end
end

function BattleCastSkillSystem:CanCastSkill(entity,skill,transInfo,passEntitys,args)
	local atkRange = skill:GetAtkRange()
	self.skillSearchParams.entity = entity
    self.skillSearchParams.range = atkRange
	if transInfo then
		self.skillSearchParams.transInfo.posX = transInfo.posX
		self.skillSearchParams.transInfo.posZ = transInfo.posZ
	end

	self.skillSearchParams.passEntitys = passEntitys

	if skill.levConf.target_num == -1 then
		return true,{}
	else
		local entitys,_ = self:SkillSearchEntity(skill,self.skillSearchParams)
		return skill.baseConf.no_target_rel == 1 or #entitys > 0,entitys
	end
end

function BattleCastSkillSystem:GetOptimalSkill(entity)
    local selectSkills = {}

    for i,skill in ipairs(entity.SkillComponent.skills) do
        if skill:CanRelState() then
            table.insert(selectSkills,skill)
        end
	end

    local optimalSkill = nil
	for i,skill in ipairs(selectSkills) do
		if not optimalSkill then
			optimalSkill = skill
        elseif skill.baseConf.priority > optimalSkill.baseConf.priority then
			optimalSkill = skill
		end
	end

    return optimalSkill
end


function BattleCastSkillSystem:SkillSearchEntity(skill,params)
    local baseConf = skill.baseConf
	local levConf = skill.levConf
    return self:SkillConfSearchEntity(baseConf,levConf,params)
end

function BattleCastSkillSystem:RenderSkillConfSearchEntity(baseConf,levConf,params)
	self.world.BattleRandomSystem:SetRenderRandom(true)
	local entitys,entityDict = self:SkillConfSearchEntity(baseConf,levConf,params)
	self.world.BattleRandomSystem:SetRenderRandom(false)
	return entitys,entityDict
end


function BattleCastSkillSystem:SkillConfSearchEntity(baseConf,levConf,params)
	local entity = params.entity

	local targetCondConf = self.world.BattleConfSystem:SkillData_data_target_cond(baseConf.target_cond_id)

    self.rangeSearchParams.entity = entity

	self.rangeSearchParams.targetArgs = self.world.BattleMixedSystem:GetTargetArgs(baseConf.target_cond_id,params)

	-- self.rangeSearchParams.targetCamp = baseConf.target_camp
	-- self.rangeSearchParams.targetTypes = params.targetTypes or targetCondConf.unit_type
	-- self.rangeSearchParams.walkType = params.walkType or targetCondConf.walk_type
	-- self.rangeSearchParams.targetLifeTypes = params.targetLifeTypes or targetCondConf.target_life_type
	-- self.rangeSearchParams.raceTypes = params.raceType or targetCondConf.race_type
	-- self.rangeSearchParams.targetCond = params.targetCond or targetCondConf.target_cond

    --self.rangeSearchParams.targetType = baseConf.target_type
	--self.rangeSearchParams.targetLifeType = baseConf.target_life_type
    self.rangeSearchParams.targetNum = params.targetNum or levConf.target_num
    --self.rangeSearchParams.targetCond = params.targetCond or baseConf.target_cond

    self.rangeSearchParams.priorityType1 = params.priorityType1 or baseConf.priority_type1
	self.rangeSearchParams.priorityType2 = params.priorityType2 or baseConf.priority_type2
	self.rangeSearchParams.priorityEntityUid = params.priorityEntityUid
	
	self.rangeSearchParams.camp = entity.CampComponent:GetCamp()
	self.rangeSearchParams.passEntitys = params.passEntitys

	self.rangeSearchParams.isLock = params.isLock or false
	self.rangeSearchParams.checkCampSort = params.checkCampSort or false

    --------------------------------------------------------------------------------------------------
    if params.transInfo and params.transInfo.posX then
        self.rangeSearchParams.transInfo.posX = params.transInfo.posX
        self.rangeSearchParams.transInfo.posZ = params.transInfo.posZ
        self.rangeSearchParams.transInfo.dirX = params.transInfo.dirX
        self.rangeSearchParams.transInfo.dirZ = params.transInfo.dirZ
    else
        self.rangeSearchParams.transInfo.posX = nil
        self.rangeSearchParams.transInfo.dirX = nil
    end

    if self.rangeSearchParams.transInfo.posX == nil then
        local pos = entity.TransformComponent.pos
        self.rangeSearchParams.transInfo.posX = pos.x
		self.rangeSearchParams.transInfo.posZ = pos.z
	end
	
	if self.rangeSearchParams.transInfo.dirX == nil and entity.TransformComponent then
		local forward = entity.TransformComponent:GetForward()
		self.rangeSearchParams.transInfo.dirX = forward.x
		self.rangeSearchParams.transInfo.dirZ = forward.z
	end

	if params == self.skillSearchParams then
		--TODO:清空skillSearchParams的所有数据
		self.skillSearchParams.transInfo.posX = nil
		self.skillSearchParams.targetNum = nil
		self.skillSearchParams.targetCond = nil
		self.skillSearchParams.priorityType1 = nil
		self.skillSearchParams.priorityType2 = nil
		self.skillSearchParams.priorityEntityUid = nil
		self.skillSearchParams.passEntitys = nil
		self.skillSearchParams.isLock = false
		self.skillSearchParams.checkCampSort = false
	end

    local entitys,entityDict = self.world.BattleSearchSystem:SearchByRange(self.rangeSearchParams,params.range)

	return entitys,entityDict
end