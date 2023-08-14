SkillBase = BaseClass("SkillBase",SECBBase)

--TODO:缓存清理
function SkillBase:__Init()
    self.uid = 0
    self.entity = nil
    self.skillId = 0
    self.skillLev = 0

    self.baseConf = nil
    self.levConf = nil

    self.cdTime = 0

    self.kvData = {}

    self.atkRange = {}

    self.actConf = nil
    self.skillTimeline = nil

    self.lastPasvs = {}
    self.relPasvs = {}

    self.hitResults = {}

    self.preCondNum = 0

    --引用次数
    self.refNum = 1

    --释放次数
    self.relNum = 0
    self.relUid = 0

    self.enable = true

    self.canAtkFloor = false
    self.canAtkFloor = false

    self.onComplete = nil

    self.isRemove = false
end

function SkillBase:__Delete()
    self:RemoveLastPasv()
    self:RemoveRelPasv()

    if self.skillTimeline then
        self.skillTimeline:Delete()
    end
end

function SkillBase:Init(uid,entity,skillId,skillLev)
    self.uid = uid
    self.entity = entity
    self.skillId = skillId
    self.skillLev = skillLev

    self.baseConf = self.world.BattleConfSystem:SkillData_data_skill_base(self.skillId)
    self.levConf = self.world.BattleConfSystem:SkillData_data_skill_lev(self.skillId,self.skillLev)
    assert(self.baseConf and self.levConf,string.format("不存在技能配置[技能Id:%s][技能等级:%s]",skillId,skillLev))

    self.preCondNum = #self.levConf.pre_cond

    self.cdTime = self.levConf.start_cd

    self.world.PluginSystem.SkillPlugin:AddSkillCache(self.uid,self)

    self:InitCanAtk()
    self:InitRange()
    self:InitHitResult()
    self:InitSkillTimeline()
    self:AddLastPasv()

    self:OnInit()
end

function SkillBase:SetRemove(flag)
    self.isRemove = flag
end

function SkillBase:SetEnable(flag)
    self.enable = flag
end

function SkillBase:IsEnable()
    return self.enable
    --TODO:取消缓存后开启
    --return self.entity.SkillComponent:IsEnable() and self.enable
end

function SkillBase:InitSkillTimeline()
    if self.levConf.act_id == 0 then
        return
    end

    self.actConf = self.world.BattleConfSystem:SkillTimeline(self.levConf.act_id) --Config["Skill"..tostring()]
    if not self.actConf then
        assert(false,string.format("找不到技能行为配置[技能ID:%s][技能等级:%s]",self.skillId,self.skillLev))
    end

    self.skillTimeline = SkillTimeline.New()
    self.skillTimeline:SetWorld(self.world)
    self.skillTimeline:Init(self.actConf,self.entity,self)
    self.skillTimeline:SetComplete(self:ToFunc("TimelineComplete"))
end

function SkillBase:InitRange()
    self.atkRange = {}
    for k,v in pairs(self.levConf.atk_range) do
        self.atkRange[k] = v
    end
    self.atkRange.uid = 0
    self.atkRange.appendModel = true
end

function SkillBase:InitHitResult()
    for i,v in ipairs(self.levConf.hit_results) do
        local id = v[1]
        local hitResultId = v[2]
        self.hitResults[id] = hitResultId
    end
end

function SkillBase:InitCanAtk()
    self.canAtkFly = false
    self.canAtkFloor = false

    local targetCondConf = self.world.BattleConfSystem:SkillData_data_target_cond(self.baseConf.target_cond_id)

    local targetType = self.baseConf.target_type
    if targetCondConf.walk_type == BattleDefine.WalkType.all then
        self.canAtkFly = true
        self.canAtkFloor = true
    elseif targetCondConf.walk_type == BattleDefine.WalkType.floor then
        self.canAtkFloor = true
    elseif targetCondConf.walk_type == BattleDefine.WalkType.fly then
        self.canAtkFly = true
    end
end

function SkillBase:GetHitResultId(id)
    if not self.hitResults[id] then
        assert(false,string.format("未知的技能命中结算配置[技能Id:%s][技能等级:%s][命中Id:%s]",self.skillId,self.skillLev,tostring(id)))
    end
    return self.hitResults[id]
end

function SkillBase:AddLastPasv()
    for _,pasvId in ipairs(self.levConf.last_pasv) do
        local pasv = Passive.New()
        pasv:SetWorld(self.world)
        pasv:Init(self.entity,self,pasvId)
		table.insert(self.lastPasvs,pasv)
	end
end

function SkillBase:AddRelPasv()
    for i,pasvId in ipairs(self.levConf.rel_pasv) do
        local pasv = Passive.New()
        pasv:SetWorld(self.world)
        pasv:Init(self.entity,self,pasvId)
		table.insert(self.relPasvs,pasv)
	end
end

function SkillBase:RemoveLastPasv()
    for i,v in ipairs(self.lastPasvs) do
        v:Destroy()
        v:Delete()
    end
    self.lastPasvs = {}
end

function SkillBase:RemoveRelPasv()
    for i,v in ipairs(self.relPasvs) do
        v:Destroy()
        v:Delete()
    end
    self.relPasvs = {}
end

function SkillBase:UpdatePasv()
    for i,v in ipairs(self.lastPasvs) do
        v:Update()
    end

    for i,v in ipairs(self.relPasvs) do
        v:Update()
    end
end

function SkillBase:Rel(targets,transInfo,onComplete)
    self.relNum = self.relNum + 1
    self.relUid = self.relUid + 1

    self.onComplete = onComplete

    if self.levConf.cost_energy ~= 0 then
        local curEnergy = self.entity.AttrComponent:GetValue(BattleDefine.Attr.energy)
        if self.levConf.cost_energy == -1 then
            self.entity.AttrComponent:AddValue(BattleDefine.Attr.energy,-curEnergy)
        else
            self.entity.AttrComponent:AddValue(BattleDefine.Attr.energy,-self.levConf.cost_energy)
        end
    end

    if self.skillTimeline then
        self:AddRefNum(1)
        self.skillTimeline:Start(targets,transInfo)
        self:SetAtkSpeed(true)
    end

    self:SetCd()
    self:AddRelPasv()
    self:OnRel()
end

function SkillBase:SetAtkSpeed(flag)
    if self.baseConf.type ~= SkillDefine.SkillType.normal_atk then
        return
    end

    if flag then
        local atkSpeed = self.entity.AttrComponent:GetValue(GDefine.Attr.atk_speed)
        self.skillTimeline:SetRate(atkSpeed)
        self.world.ClientIFacdeSystem:Call("SetAnimTimeScale",self.entity.uid,atkSpeed * 0.0001)
    else
        self.world.ClientIFacdeSystem:Call("SetAnimTimeScale",self.entity.uid,1)
    end
end

function SkillBase:TimelineComplete()
    self:RemoveRelPasv()
    self:SetAtkSpeed(false)

    if self.onComplete then
        self.onComplete(self)
    end

    self:AddRefNum(-1)
end

function SkillBase:AbortTimeline()
    if not self:IsTimelineFinish() then
        self:AddRefNum(-1)
    end
end

function SkillBase:GetAtkRange()
    local changeInfo = self.entity.KvDataComponent:GetData(BattleDefine.EntityKvType.change_range)
    if changeInfo and self.atkRange.uid ~= changeInfo.uid then
        self.atkRange.uid = changeInfo.uid
        self.world.BattleMixedSystem:ChangeRange(self.levConf.atk_range,self.atkRange,changeInfo.changes)
        return self.atkRange
    else
        return self.atkRange
    end
end

function SkillBase:GetHitRange()
    return self.levConf.hit_range
end

function SkillBase:GetGridAtkRange()
    return self.levConf.grid_atk_range
end

function SkillBase:GetGridHitRange()
    return self.levConf.grid_hit_range
end


function SkillBase:GetHitNum()
    return self.levConf.hit_num
end

function SkillBase:Update()
    if self.skillTimeline and not self.skillTimeline:IsFinish() then
        self.skillTimeline:Update(self.world.opts.frameDeltaTime)
    end

    self:UpdateCdTime()
    self:OnUpdate()
    self:UpdatePasv()
end

function SkillBase:IsFinish()
    if self.skillTimeline then
        return self.skillTimeline:IsFinish()
    else
        return true
    end 
end

function SkillBase:MaxRelNum()
    if self.levConf.max_rel_num == 0 then
        return false
    else
        return self.relNum >= self.levConf.max_rel_num
    end
end

function SkillBase:SetCd()
    if self.levConf.cd ~= 0 then
        self.cdTime = self.levConf.cd
    end
end

function SkillBase:ResetCd()
    self.cdTime = 0
end

function SkillBase:IsCd()
    return self.cdTime <= 0
end

function SkillBase:IsEnergy()
    if self.levConf.cost_energy ~= 0 then
        local maxEnergy = self.entity.AttrComponent:GetValue(GDefine.Attr.max_energy)
        local curEnergy = self.entity.AttrComponent:GetValue(BattleDefine.Attr.energy)
        if self.levConf.cost_energy == -1 and curEnergy < maxEnergy then
            return false
        elseif curEnergy < self.levConf.cost_energy then
            return false
        end
    end
    return true
end

function SkillBase:IsTimelineFinish()
    if self.skillTimeline then
        return self.skillTimeline:IsFinish()
    else
        return true
    end
end

function SkillBase:UpdateCdTime()
    if self.cdTime > 0 and not self.entity.BuffComponent:HasBuffState(BattleDefine.BuffState.palsy) then
        self.cdTime = self.cdTime - self.world.opts.frameDeltaTime
        if self.cdTime < 0 then self.cdTime = 0 end
    end
end

function SkillBase:SetData(key,val)
    self.kvData[key] = val
end

function SkillBase:GetData(key)
    return self.kvData[key]
end

function SkillBase:AddRefNum(num)
    self.refNum = self.refNum + num
    if self.refNum >= 0 then
        self:CheckRemove()
    end
end

function SkillBase:CheckRemove()
    if self.refNum <= 0 then
        self.world.PluginSystem.SkillPlugin:RemoveSkillCache(self.uid)
        self:Delete()
    end
end

function SkillBase:CheckPreCond()
    if self.preCondNum <= 0 then
        return true
    else
        return self.world.PluginSystem.CheckCond:IsCond(self.entity.uid,self.levConf.pre_cond)
    end
end

function SkillBase:Clear()
    self:RemoveRelPasv()

    if not self:IsTimelineFinish() then
        self.skillTimeline:Abort()
        self:AddRefNum(-1)
        self:SetAtkSpeed(false)
    end
end
--
function SkillBase:OnInit()
end

function SkillBase:OnUpdate()
end

function SkillBase:OnRel()
end

function SkillBase:OnCanRel()
    return false
end

function SkillBase:CanRel()
    local flag = self:OnCanRel()
    if flag then
        flag = not self.world.EventTriggerSystem:Trigger(BattleEvent.try_to_rel_skill,self.entity.uid,self)
    end
    return flag
end