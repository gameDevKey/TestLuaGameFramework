Passive = BaseClass("Passive",SECBBase)

function Passive:__Init()
    self.entity = nil
    self.skill = nil
    self.pasvId = 0
    self.conf = nil
    self.targetFilterNum = 0
    self.execNum = 0
    self.condAction = nil
    self.isActive = true 
end

function Passive:__Delete()
	if self.condAction then
        self.condAction:Delete()
    end
end

function Passive:Init(entity,skill,pasvId)
    self.entity = entity
    self.skill = skill
    self.pasvId = pasvId
    
    self.conf = self.world.BattleConfSystem:SkillData_data_pasv_info(pasvId)
    assert(self.conf,string.format("不存在的被动配置[技能Id:%s][被动Id:%s]",self.skill.skillId,pasvId))

    self:InitCond()

    if not self.condAction then
        self:Execute({fromEntityUid = self.entity.uid})
    end
end

function Passive:InitCond()
    local confCond = self.conf.condition["type"]
    if not confCond then
        return
    end

    local class  = nil
    if SkillDefine.PasvCondIndex[confCond] then
        class = _G[SkillDefine.PasvCondIndex[confCond]]
    end
	assert(class,string.format("被动触发条件，不存在映射[触发条件:%s]",tostring(confCond)))

	self.condAction = class.New()
    self.condAction:SetWorld(self.world)
	self.condAction:Init(self)
end


function Passive:Update()
	if self.condAction then 
        self.condAction:Update()
    end
end

function Passive:IsActive()
    return self.isActive
end

function Passive:SetActive(flag)
    self.isActive = flag
end

function Passive:Execute(param)
    if not self.isActive then
        return
    end

    if not self.skill:IsEnable() or not self.entity.SkillComponent:IsEnable() then
        return
    end

	if self:MaxExecNum() then
        return
    end

    if not self:PreComplete() then
        return
    end

	self.execNum = self.execNum + 1

    local execTargets = nil
    if self.conf.target == SkillDefine.PasvTargetType.binder then
        execTargets = {self.entity.uid}
    elseif self.conf.target == SkillDefine.PasvTargetType.from then
        execTargets = {param.fromEntityUid}
    elseif self.conf.target == SkillDefine.PasvTargetType.target then
        execTargets = param.targetEntityUids
    end

    if execTargets then
        for i,entityUid in ipairs(execTargets) do
            local targetEntity = self.world.EntitySystem:GetEntity(entityUid)
            if targetEntity and self.world.EntitySystem:HasEntity(entityUid) then
                local targetArgs = self.world.BattleMixedSystem:GetTargetArgs(self.conf.target_cond_id)
                local isTargetType = self.world.BattleSearchSystem:IsTargetType(self.entity,targetEntity,targetArgs)

                if isTargetType then
                    self.world.PluginSystem.PasvAction:ExecAction(self,targetEntity,self.conf.actions,param)
                end
            end
        end
    end
end

function Passive:MaxExecNum()
	if self.conf.max_num == 0 then 
        return false
    else
        return self.execNum >= self.conf.max_num
    end
end

function Passive:PreComplete()
    return self.world.PluginSystem.CheckCond:IsCond(self.entity.uid,self.conf.pre_condition)
end

function Passive:Destroy()
    if self.condAction then
        self.condAction:Destroy()
    end
end