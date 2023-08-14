BattleGroupSystem = BaseClass("BattleGroupSystem",SECBEntitySystem)

function BattleGroupSystem:__Init()
    self.nextRoundTime = 1000
    self.debug = true

    self.maxGroup = 0

    self.groupConf = nil
    self.group = 0
    self.groupTime = 0
    self.groupMaxTime = 0
    self.groupStep = 0
    self.groupProgress = 0
    self.roundTime = 0
    self.lastGroupProgress = 0

    self.skipStep = -1
end

function BattleGroupSystem:OnLateInitSystem()
    self.world.EventTriggerSystem:AddListener(BattleEvent.unit_die,self:ToFunc("SkipGroupTime"))
end

function BattleGroupSystem:__Delete()

end

function BattleGroupSystem:InitGroup()
    --self.groupConf
    self:SetGroupInfo(self.group)

    local pvpId = self.world.BattleDataSystem.pvpConf.id
    local maxGroup = 1
    while true do
        local groupConf = self.world.BattleConfSystem:PvpData_data_pvp_group(pvpId,maxGroup + 1)
        if not groupConf then
            break
        else
            maxGroup = maxGroup + 1
        end
    end
    self.maxGroup = maxGroup - 1
end

function BattleGroupSystem:SetGroupInfo(group)
    self.group = group

    local pvpId = self.world.BattleDataSystem.pvpConf.id
    self.groupConf = self.world.BattleConfSystem:PvpData_data_pvp_group(pvpId,self.group + 1)
    assert(self.groupConf,string.format("不存在的波数配置[PvpId:%s][当前波数:%s][下一波数:%s]",pvpId,self.group,self.group + 1))

    self.groupTime = 0
    self.groupMaxTime = self.groupConf.max_time

    self.groupStep = 1

    self.lastGroupProgress = 0
    self.groupProgress = 0
    self.roundTime = 0

    self.world.BattleDataSystem:SwitchCampGenIndex()

    if self.group > 0 then
        self.world.EventTriggerSystem:Trigger(BattleEvent.enter_round,self.group)
    end

    self.world.ClientIFacdeSystem:Call("SendEvent","BattleInfoView","RefreshGroupNum",self.group)

    self.world.ClientIFacdeSystem:Call("SendGuideEvent","PlayerGuideDefine","begin_group",self.group)
end

function BattleGroupSystem:SetNextRoundTime()

end

function BattleGroupSystem:OnUpdate()
    if self.world.BattleStateSystem:IsBattleState(BattleDefine.BattleState.solo_battle) then
        return
    end

    self.groupTime = self.groupTime + self.world.opts.frameDeltaTime
    self.roundTime = self.roundTime + self.world.opts.frameDeltaTime

    local stepInfo = self.groupConf.step_award[self.groupStep]

    self.lastGroupProgress = self.groupProgress
    self.groupProgress = self.groupTime / self.groupMaxTime

    if self.groupProgress >= 0.5 then
        self.world.ClientIFacdeSystem:Call("SendEvent","BattleSituationView","HalfBattleGroup")
    end

    if self.groupTime >= stepInfo[1] then
        self:UpdateGroupStepAward()

        local nextGroupStep = self.groupStep + 1
        local isGroupOver = nextGroupStep > #self.groupConf.step_award
        local remainGroupNum = self.world.BattleDataSystem.pvpConf.max_group - self.group
        
        if isGroupOver and remainGroupNum > 0  then
            --Log("创建")
            if remainGroupNum <= 3 then
                self.world.ClientIFacdeSystem:Call("SendEvent","BattleInfoView","ShowLastGroupTips",remainGroupNum)
            end
            self:GenGroupEntitys()
            self:SetGroupInfo(self.group + 1)
            self.world.ClientIFacdeSystem:Call("SendEvent","BattleSituationView","BeginBattleGroup")
        elseif isGroupOver and remainGroupNum <= 0 then
            self.world.BattleStateSystem:SetBattleState(BattleDefine.BattleState.solo_battle)
            self.world.BattleCommanderSystem:DisabledCommanderSkill()
            self:CleanGroupEntitys()
            self:GenSoloEntitys()
            self.world.ClientIFacdeSystem:Call("SendEvent","BattleInfoView","ShowSoloTips")
            --清理全场单位
        else
            --Log("获取资源")
            self.groupStep = nextGroupStep
        end
    end

    self.world.ClientIFacdeSystem:Call("RefreshGroupTime")
    self.world.ClientIFacdeSystem:Call("SendGuideEvent","PlayerGuideDefine","on_round_begin", self.group, self.roundTime)
end

function BattleGroupSystem:GetNextStepMoney()
    local stepInfo = self.groupConf.step_award[self.groupStep]
    return stepInfo[2]
end

function BattleGroupSystem:NextRound()

end

function BattleGroupSystem:GenGroupEntitys()
    local attackRoleUid = self.world.BattleDataSystem:GetCampGenRoleUid(BattleDefine.Camp.attack)
    self.world.BattleDataSystem:SetCampBattleRoleUid(BattleDefine.Camp.attack,attackRoleUid)
    self:GenCampEntitys(BattleDefine.Camp.attack,attackRoleUid)


    local defenceRoleUid = self.world.BattleDataSystem:GetCampGenRoleUid(BattleDefine.Camp.defence)
    self.world.BattleDataSystem:SetCampBattleRoleUid(BattleDefine.Camp.defence,defenceRoleUid)
    self:GenCampEntitys(BattleDefine.Camp.defence,defenceRoleUid)

    do return end

    local roleUid = self.world.BattleDataSystem:GetCampGenRoleUid(BattleDefine.Camp.attack)

    local heroData = nil
    for i=1,BattleDefine.GridNum do
        local heroInfo = self.world.BattleDataSystem:GetUnitDataByGrid(roleUid,i)
        if heroInfo then
            heroData = heroInfo
            break
        end
    end

    if not heroData then
        return
    end

    --第1个调试单位
    for i,v in ipairs(heroData.attr_list) do
        if v.attr_id == 104 then
            v.attr_val = 1500
        end
    end

    --TODO:先将技能强制设置为2001
    heroData.skill_list = {}
    local skillInfo = {}
    skillInfo.id = 2001
    skillInfo.lev = 1
    table.insert(heroData.skill_list,skillInfo)
    --end

    local entity = self.world.BattleEntityCreateSystem:CreateHeroEntity(heroData,2,BattleDefine.Camp.attack)

    local initTargetPos = self.world.BattleMixedSystem:GetInitTargetPos(BattleDefine.Camp.attack)
    local pos = entity.TransformComponent:GetPos()
    --entity.MoveComponent:MoveToPos(pos.x,pos.y,initTargetPos.z,{})



    --第2个调试单位
    for i,v in ipairs(heroData.attr_list) do
        if v.attr_id == 104 then
            v.attr_val = 3000
        end
    end

    --TODO:先将技能强制设置为2001
    heroData.skill_list = {}
    local skillInfo = {}
    skillInfo.id = 2001
    skillInfo.lev = 1
    table.insert(heroData.skill_list,skillInfo)
    --end

    local entity = self.world.BattleEntityCreateSystem:CreateHeroEntity(heroData,6,BattleDefine.Camp.attack)

    local initTargetPos = self.world.BattleMixedSystem:GetInitTargetPos(BattleDefine.Camp.attack)
    local pos = entity.TransformComponent:GetPos()
    entity.MoveComponent:MoveToPos(pos.x + 200,pos.y,initTargetPos.z,{})
end

function BattleGroupSystem:CleanGroupEntitys()
    for v in self.world.EntitySystem.entityList:Items() do
        local uid = v.value
        local entity = self.world.EntitySystem:GetEntity(uid)
        if entity and not (entity.TagComponent:IsTag(BattleDefine.EntityTag.home) or entity.TagComponent:IsTag(BattleDefine.EntityTag.commander))
            and (not entity.StateComponent or not entity.StateComponent:IsState(BattleDefine.EntityState.die)) then
            self.world.PluginSystem.EntityFunc:RemoveEntityDisableComponent(entity)
            self.world.EntitySystem:RemoveEntity(uid)
        end
    end
end

function BattleGroupSystem:GenSoloEntitys()
    --TODO:2v2的话是创建4个玩家的英雄
    local attackRoleUid = self.world.BattleDataSystem:GetCampGenRoleUid(BattleDefine.Camp.attack)
    self.world.BattleDataSystem:SetCampBattleRoleUid(BattleDefine.Camp.attack,attackRoleUid)
    self:GenCampEntitys(BattleDefine.Camp.attack,attackRoleUid)


    local defenceRoleUid = self.world.BattleDataSystem:GetCampGenRoleUid(BattleDefine.Camp.defence)
    self.world.BattleDataSystem:SetCampBattleRoleUid(BattleDefine.Camp.defence,defenceRoleUid)
    self:GenCampEntitys(BattleDefine.Camp.defence,defenceRoleUid)
    --end
end

function BattleGroupSystem:GenCampEntitys(camp,roleUid)
    for i=1,BattleDefine.GridNum do
        local heroInfo = self.world.BattleDataSystem:GetUnitDataByGrid(roleUid,i)
        if heroInfo then
            --TODO:先将技能强制设置为2001
            -- heroInfo.skill_list = {}
            -- local skillInfo = {}
            -- skillInfo.id = 2001
            -- skillInfo.lev = 1
            -- table.insert(heroInfo.skill_list,skillInfo)
            --end
            local unitConf = self.world.BattleConfSystem:UnitData_data_unit_info(heroInfo.unit_id)
            local genNum = unitConf.unit_num
            --TODO:调试代码，将敌方直接设置成6个单位
            -- if camp == 2 then
            --     genNum = 6
            -- end
            --end
            if genNum <= 0 then
                genNum = 1
            elseif genNum > 6 then
                genNum = 6
            end
            --genNum = 6
            for index=1,genNum do
                local entity = self.world.BattleEntityCreateSystem:CreateHeroEntity(roleUid,heroInfo,i,camp,genNum,index,self.group)

                self.world.BattleEntityCreateSystem:BindAttackAI(entity)

                --local initTargetPos = self.world.BattleMixedSystem:GetInitTargetPos(camp)
                local pos = entity.TransformComponent:GetPos()
                --entity.MoveComponent:MoveToPos(pos.x,pos.y,initTargetPos.z,{})

                self.world.ClientIFacdeSystem:Call("SendEvent","BattleMixedEffectView","PlayUnitBornEffect",pos)
            end
        end
    end
end

function BattleGroupSystem:UpdateGroupStepAward()
    if self.skipStep ~= -1 then
        for i = self.skipStep, #self.groupConf.step_award do
            local stepInfo = self.groupConf.step_award[i]
            for _,v in ipairs(self.world.BattleDataSystem.data.role_list) do
                self.world.BattleDataSystem:AddRoleMoney(v.role_base.role_uid,stepInfo[2])
            end
        end
        self.skipStep = -1
    else
        local stepInfo = self.groupConf.step_award[self.groupStep]
        for i,v in ipairs(self.world.BattleDataSystem.data.role_list) do
            self.world.BattleDataSystem:AddRoleMoney(v.role_base.role_uid,stepInfo[2])
        end
    end
    
    self.world.ClientIFacdeSystem:Call("SendEvent","BattleInfoView","RefreshMoney")
    self.world.ClientIFacdeSystem:Call("SendEvent","BattleHeroGridView","RefreshExtGrid")
end

function BattleGroupSystem:SkipGroupTime()
    if self.world.BattleDataSystem.pvpConf.is_skip_group ~= 1 then
        return
    end
    if not self.world.BattleStateSystem:IsBattleResult(BattleDefine.BattleResult.none) then
        return
    end

    if self.world.BattleStateSystem:IsBattleState(BattleDefine.BattleState.solo_battle) then
        return
    end

    local attackCampNum = self.world.EntitySystem:GetEntityNumByCamp(BattleDefine.Camp.attack)
    local defenceCampNum = self.world.EntitySystem:GetEntityNumByCamp(BattleDefine.Camp.defence)

    if attackCampNum == 0 and defenceCampNum == 0 then
        self.groupTime = self.groupMaxTime
        self.roundTime = self.groupMaxTime
        self.skipStep = self.groupStep
        self.groupStep = #self.groupConf.step_award
    end
end