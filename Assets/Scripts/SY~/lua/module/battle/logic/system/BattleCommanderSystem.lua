BattleCommanderSystem = BaseClass("BattleCommanderSystem",SECBClientEntitySystem)

function BattleCommanderSystem:__Init()
    self.commanderInfos = {}
    self.expTime = 0
    self.rageTime = 0
    self.lastGroup = nil
    self.toShowUnlockSkill = {}
end

function BattleCommanderSystem:__Delete()

end

function BattleCommanderSystem:OnInitSystem()
    
end

function BattleCommanderSystem:OnLateInitSystem()
    self.world.EventTriggerSystem:AddListener(BattleEvent.begin_battle,self:ToFunc("BeginBattle"))
end

function BattleCommanderSystem:InitData()
    for i,v in ipairs(self.world.BattleDataSystem.data.role_list) do
        local unitInfo = nil
        for _,info in ipairs(v.object_list) do
            local unitConf = self.world.BattleConfSystem:UnitData_data_unit_info(info.unit_id)
            if unitConf.type == BattleDefine.UnitType.commander then
                unitInfo = info
            end
        end

        local baseConf = self.world.BattleConfSystem:CommanderData_data_base_info(unitInfo.unit_id)
        if baseConf then
            local info = {}
            info.unitId = unitInfo.unit_id
            info.baseConf = baseConf
            info.star = 1
            info.exp = 0
            info.rage = 0
            info.convertRatio = 0
            info.lockSkills = {}
            info.unlockSkills = {}
            info.isMax = false
            info.dragSkills = {}

            for _,skillInfo in ipairs(info.baseConf.lock_skills) do
                table.insert(info.lockSkills,{skillId = skillInfo[1],star = skillInfo[2]})
            end

            local skillList = self.world.BattleDataSystem:GetCampCommanderInfo(v.role_base.role_uid).skill_list
            for i2,v2 in ipairs(skillList) do -- 技能列表中有而且不在lockSkills列表中的技能 添加到统帅实体的skillComponent
                local unlocked = true
                for i3, v3 in ipairs(info.lockSkills) do
                    if v2.skill_id == v3.skillId then
                        unlocked = false
                        v3.skillLevel = v2.skill_level
                        break
                    end
                end
                if unlocked then
                    table.insert(info.unlockSkills,{skillId = v2.skill_id, skillLevel = v2.skill_level})
                end
            end

            local dragSkillList = info.baseConf.drag_rel_skill
            for i3, v3 in ipairs(dragSkillList) do
                local dragSkill = {}
                dragSkill.skillId = v3[1]
                dragSkill.skillLev = v3[2]
                dragSkill.consume = v3[3]
                if dragSkill.skillId == 0 then
                    dragSkill.lock = true
                else
                    dragSkill.lock = false
                    local skillLevConf = self.world.BattleConfSystem:SkillData_data_skill_lev(dragSkill.skillId,dragSkill.skillLev)
                    dragSkill.maxRelNum = skillLevConf.max_rel_num
                    dragSkill.relNum = 0
                    dragSkill.startCd = skillLevConf.start_cd
                    dragSkill.cd = skillLevConf.cd
                    local skillBaseConf = self.world.BattleConfSystem:SkillData_data_skill_base(dragSkill.skillId)
                    dragSkill.name = skillBaseConf.name
                    dragSkill.relRangeType = skillBaseConf.rel_range_type
                end
                table.insert(info.dragSkills,dragSkill)
            end

            self.commanderInfos[v.role_base.role_uid] = info
        end
    end
end

function BattleCommanderSystem:BeginBattle()
    if self.world.BattleDataSystem.pvpConf.open_commander_up == 0 then
        return
    end

    for i,v in ipairs(self.world.BattleDataSystem.data.role_list) do
        local info = self.commanderInfos[v.role_base.role_uid]
        if info then
            self:CheckUnlockSkill(v.role_base.role_uid)
        end
    end
end

function BattleCommanderSystem:IsLockSkill(roleUid,skillId)
    -- local info = self.commanderInfos[v.role_uid]
    local info = self.commanderInfos[roleUid]
    for i,v in ipairs(info.lockSkills) do
        if v.skillId == skillId then
            return true
        end
    end
    return false
end

function BattleCommanderSystem:DisabledCommanderSkill()
    for i,v in ipairs(self.world.BattleDataSystem.data.role_list) do
        local entity = self.world.EntitySystem:GetRoleCommander(v.role_base.role_uid)
        entity.SkillComponent:SetEnable(false)
    end
end

function BattleCommanderSystem:OnUpdate()
    if not self.world.BattleStateSystem:IsBattleResult(BattleDefine.BattleResult.none) then
        return
    end
    if self.world.BattleDataSystem.pvpConf.open_commander_rage == 0 or self.world.BattleDataSystem.pvpConf.open_commander_rage_up_with_time == 0 then
        return
    end

    local groupConf = self.world.BattleGroupSystem.groupConf
    if groupConf.commander_add_rage[2] <= 0 then
        return
    end

    if not self.lastGroup or self.lastGroup ~= groupConf.group then
        self.lastGroup = groupConf.group
        self.rageTime = 0
        self.addTime = groupConf.commander_add_rage[1] --多少毫秒添加一次怒气
    end

    self.rageTime = self.rageTime + self.world.opts.frameDeltaTime
    if self.rageTime < self.addTime then
        return
    end

    local addNum = FPMath.Divide(self.rageTime - (self.rageTime % self.addTime),self.addTime)
    local addRage = addNum * groupConf.commander_add_rage[2] -- 一次增加多少点怒气

    self.rageTime = self.rageTime - addNum * self.addTime
    for i,v in ipairs(self.world.BattleDataSystem.data.role_list) do
        self:AddRage(v.role_base.role_uid,addRage)
    end

    -- TODO----以下为统帅经验升星逻辑----
    do return end
    if self.world.BattleDataSystem.pvpConf.open_commander_up == 0 then
        return
    end

    local groupConf = self.world.BattleGroupSystem.groupConf
    if groupConf.commander_add_exp[2] <= 0 then
        return
    end

    if not self.lastGroup or self.lastGroup ~= groupConf.group then
        self.lastGroup = groupConf.group
        self.expTime = 0
        self.addTime = groupConf.commander_add_exp[1] --多少毫秒添加一次经验
    end

    self.expTime = self.expTime + self.world.opts.frameDeltaTime
    if self.expTime < self.addTime then
        return
    end

    local addNum = FPMath.Divide(self.expTime - (self.expTime % self.addTime),self.addTime)
    local addExp = addNum * groupConf.commander_add_exp[2] -- 一次增加多少点经验

    self.expTime = self.expTime - addNum * self.addTime
    
    for i,v in ipairs(self.world.BattleDataSystem.data.role_list) do
        self:AddExp(v.role_base.role_uid,addExp,{from = 1})
    end
end

function BattleCommanderSystem:AddRage(roleUid,rage)
    local info = self.commanderInfos[roleUid]
    if not info then
        return
    end

    local conf = self.world.BattleConfSystem:CommanderData_data_base_info(info.unitId)

    -- LogError("AddRage",roleUid,rage)
    info.rage = info.rage + rage
    if info.rage >= conf.max_rage then
        info.rage = conf.max_rage
    elseif info.rage < 0 then
        info.rage = 0
    end
    --TODO 发送刷新怒气值条UI事件
    local camp = self.world.BattleDataSystem.enterExtraData.roleUidToCamp[roleUid]
    local homeUid = self.world.BattleDataSystem:GetHomeUid(camp)
    local homeEntity = self.world.EntitySystem:GetEntity(homeUid)
    if homeEntity.clientEntity then
        homeEntity.clientEntity.UIComponent.entityTop:RefreshRage(info.rage,conf.max_rage) --TODO 修改怒气值进度条
    end

    if roleUid == self.world.BattleDataSystem.roleUid then
        self.world.ClientIFacdeSystem:Call("SendEvent","BattleCommanderDragSkillView","RefreshView")
    end
end

function BattleCommanderSystem:GetRage(roleUid)
    local info = self.commanderInfos[roleUid]
    return info.rage
end

-- args = {from:统帅经验来源,1：随时间增加 2：占桥增加 3:技能修改; index:桥index}
function BattleCommanderSystem:AddExp(roleUid,exp,args)
    do return end
    local info = self.commanderInfos[roleUid]
    if not info then
        return
    end

    if info.isMax then
        if exp <= 0 then
            return
        end

        local curValue = exp * info.baseConf.money_convert_ratio + info.convertRatio
        info.convertRatio = curValue % BattleDefine.AttrRatio
        local addMoney = FPMath.Divide(curValue - info.convertRatio,BattleDefine.AttrRatio)
        if addMoney > 0 then
            self.world.BattleDataSystem:AddRoleMoney(roleUid,addMoney)
            if args.from == 2 then
                self.world.ClientIFacdeSystem:Call("SendEvent",BattleBridgeView.Event.BridgeAddCommanderSp,args.index,roleUid,addMoney)
            end
        end
    else
        local conf = self.world.BattleConfSystem:CommanderData_data_star_info(info.unitId,info.star)
        info.exp = info.exp + exp
        if args.from == 2 then
            self.world.ClientIFacdeSystem:Call("SendEvent",BattleBridgeView.Event.BridgeAddCommanderExp,args.index,roleUid,exp)
        end
        if info.exp < 0 then 
            info.exp = 0
        elseif info.exp >= conf.max_exp then
            while info.exp >= conf.max_exp do
                info.star = info.star + 1
                if info.star >= info.baseConf.max_star then
                    info.isMax = true
                    info.exp = 0
                    break
                else
                    info.exp = info.exp - conf.max_exp
                end
                conf = self.world.BattleConfSystem:CommanderData_data_star_info(info.unitId,info.star)
                self.world.ClientIFacdeSystem:Call("SendGuideEvent",PlayerGuideDefine.Event.commander_up_star,roleUid)
            end
            self:CheckUnlockSkill(roleUid)
            self:PlayCommanderUpStarEffect(roleUid,info.isMax)
        end
        local camp = self.world.BattleDataSystem.enterExtraData.roleUidToCamp[roleUid]
        local homeUid = self.world.BattleDataSystem:GetHomeUid(camp)
        local homeEntity = self.world.EntitySystem:GetEntity(homeUid)
        if homeEntity.clientEntity then
            homeEntity.clientEntity.UIComponent.entityTop:RefreshExp(info.star,info.exp,conf.max_exp,info.isMax)
        end
    end
end

function BattleCommanderSystem:PlayCommanderUpStarEffect(roleUid,isMax)
    local entity = self.world.EntitySystem:GetRoleCommander(roleUid)
    local pos = entity.TransformComponent:GetPos()
    local effectId = 100001
    if isMax then
        effectId = 100011
    end
    self.world.BattleAssetsSystem:PlaySceneEffect(effectId,pos.x,pos.y,pos.z)
end

function BattleCommanderSystem:CheckUnlockSkill(roleUid)
    local info = self.commanderInfos[roleUid]
    local entity = self.world.EntitySystem:GetRoleCommander(roleUid)

    local newUnlock = false
    local index = 1
    for i=1,#info.lockSkills do 
        local skillInfo = info.lockSkills[index]
        if info.star >= skillInfo.star then
            table.remove(info.lockSkills,index)
            table.insert(info.unlockSkills,skillInfo)
            --TODO 有新技能解锁
            if not self.toShowUnlockSkill[roleUid] then
                self.toShowUnlockSkill[roleUid] = {}
            end
            table.insert(self.toShowUnlockSkill[roleUid],skillInfo.skillId)
            -- self.world.ClientIFacdeSystem:Call("SendEvent",BattleInfoView.Event.CommanderSkillUnlock,roleUid,skillInfo.skillId) --统帅头顶展示
            newUnlock = true
        else
            index = index + 1
        end
    end
    for i, v in ipairs(info.unlockSkills) do
        local skill = entity.SkillComponent:GetSkill(v.skillId)
        if not skill then
            entity.SkillComponent:AddSkill(v.skillId,v.skillLevel)

            local levConf = self.world.BattleConfSystem:SkillData_data_skill_lev(v.skillId,v.skillLevel)
            if next(levConf.halo) ~= nil then
                local camp = self.world.BattleDataSystem.enterExtraData.roleUidToCamp[roleUid]
                local unitId = info.unitId
                self.world.BattleHaloSystem:InitHalo(roleUid,camp,unitId,levConf.halo)
            end
        end
    end
    -- if newUnlock then
        
    -- end
end


function BattleCommanderSystem:GetCommanderInfo(roleUid)
    local info = self.commanderInfos[roleUid]
    return info
end

function BattleCommanderSystem:GetCurRage(roleUid)
    return self.commanderInfos[roleUid].rage
end

function BattleCommanderSystem:GetDragSkillInfo(roleUid,skillId)
    local skillInfos = self.commanderInfos[roleUid].dragSkills
    local skillInfo = nil
    for k, v in pairs(skillInfos) do
        if v.skillId == skillId then
            skillInfo = v
        end
    end
    return skillInfo
end