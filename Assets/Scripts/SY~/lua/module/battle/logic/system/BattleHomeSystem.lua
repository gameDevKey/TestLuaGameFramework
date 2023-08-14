BattleHomeSystem = BaseClass("BattleHomeSystem",SECBEntitySystem)

function BattleHomeSystem:__Init()
    self.homeInfos = {}
    self.firstLowHp = true

    self.lastHpRate = {}
end

function BattleHomeSystem:__Delete()

end

function BattleHomeSystem:OnInitSystem()
end

function BattleHomeSystem:OnLateInitSystem()
    self.world.EventTriggerSystem:AddListener(BattleEvent.begin_battle,self:ToFunc("BeginBattle"))
    self.world.EventTriggerSystem:AddListener(BattleEvent.be_home_hit,self:ToFunc("BeHomeHit"))
end

function BattleHomeSystem:BeginBattle()
    for i,v in ipairs(self.world.BattleDataSystem.homeUids) do
        local data = {}
        data.hpIndex = 1
        self.homeInfos[v.uid] = data
    end
end

function BattleHomeSystem:BeHomeHit(homeUid,val)
    if self.world.BattleStateSystem:IsBattleState(BattleDefine.BattleState.solo_battle) then
        return
    end

    local homeInfo = self.homeInfos[homeUid]

    local homeEntity = self.world.EntitySystem:GetEntity(homeUid)
    local roleUid = homeEntity.ObjectDataComponent.roleUid
    local maxHp = homeEntity.AttrComponent:GetValue(GDefine.Attr.max_hp)
    local hp = homeEntity.AttrComponent:GetValue(BattleDefine.Attr.hp)
    local curRate = FPFloat.Div_ii(hp,maxHp)

    if self.firstLowHp and curRate <= 300 
        and roleUid == self.world.BattleDataSystem.roleUid then
        self.firstLowHp = false
        self.world.ClientIFacdeSystem:Call("SendEvent","BattleInfoView","PlayLowHpWarning")
    end
    if not self.firstLowHp 
        and roleUid == self.world.BattleDataSystem.roleUid then
        self.world.ClientIFacdeSystem:Call("SendEvent","BattleInfoView","PlayBeHitWarningWhenLowHp")
    end

    if not self.lastHpRate[homeUid] then
        self.lastHpRate[homeUid] = 1000
    end

    local lostRate = self.lastHpRate[homeUid] - curRate
    if lostRate >= 10 then
        lostRate = FPMath.Divide(lostRate, 10)
        self.lastHpRate[homeUid] = self.lastHpRate[homeUid] - lostRate*10
        local commanderEntity = self.world.EntitySystem:GetRoleCommander(roleUid)
        local convertRatio = self.world.BattleConfSystem:CommanderData_data_base_info(commanderEntity.entityId).hp_convert_rage
        local rage = lostRate * convertRatio
        self.world.BattleCommanderSystem:AddRage(roleUid,rage)
    end

    --
    -- if homeInfo.hpIndex > #self.world.BattleDataSystem.pvpConf.home_hp_action then
    --     return
    -- end

    -- local hpActionInfo = self.world.BattleDataSystem.pvpConf.home_hp_action[homeInfo.hpIndex]
    -- local rate = hpActionInfo[1]


    -- if curRate > rate then
    --     return
    -- end

    -- homeInfo.hpIndex = homeInfo.hpIndex + 1

    -- local addMoney = hpActionInfo[2]
    -- local isGenDefender = hpActionInfo[3] == 1

    -- for i,v in ipairs(self.world.BattleDataSystem.data.role_list) do
    --     self.world.BattleDataSystem:AddRoleMoney(v.role_base.role_uid,addMoney)
    -- end

    -- if isGenDefender then
    --     local derenderEntity = self:CreateDefender(homeEntity.CampComponent:GetCamp())
    --     self.world.BattleEntityCreateSystem:BindAttackAI(derenderEntity)
    -- end

    -- self:BeHomeHit(homeUid,0)
end

function BattleHomeSystem:CreateDefender(camp)
    local roleUid = self.world.BattleDataSystem:GetCampBattleRoleUid(camp)

    local roleData = self.world.BattleDataSystem:GetRoleData(roleUid)--.camp

    local defenderData = roleData.guardian[1]

    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()
    entity:Init(defenderData.unit_id,uid)

    entity:SetWorld(self.world)
    self.world.BattleEntityCreateSystem:CreateComponents(entity,BattleEntityDefine.EntityCreateType.defender)

    entity.ObjectDataComponent:SetObjectData(defenderData)
    entity.CampComponent:SetCamp(camp)

    local unitConf = self.world.BattleConfSystem:UnitData_data_unit_info(defenderData.unit_id)
    entity.ObjectDataComponent:SetBaseConf(self.world.BattleConfSystem:DefenderData_data_defender_info(unitConf.base_id))
    entity.ObjectDataComponent:SetUnitConf(unitConf)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.defender)

    --TODO:正式化主堡技能
    -- defenderData.skill_list = {}
    -- local skillInfo = {}
    -- skillInfo.id = 2001
    -- skillInfo.lev = 1
    -- table.insert(defenderData.skill_list,skillInfo)
    --end


    local pos = self.world.BattleMixedSystem:GetStancePos(camp,-2)
    entity.TransformComponent:SetPos(pos.x,pos.y,pos.z)
    local dirQuat = self.world.BattleMixedSystem:GetStanceDir(camp)
    entity.TransformComponent:SetRotation(dirQuat)


    entity:InitComponent()
    entity:AfterInitComponent()
    

    entity.StateComponent:SetState(BattleDefine.EntityState.idle)
    self.world.EntitySystem:AddEntity(entity)

    if entity.clientEntity then
        entity.clientEntity.ClientTransformComponent:SetName(string.format("防御者[uid:%s][unit_id:%s]",uid,defenderData.unit_id))
        entity.clientEntity:InitComponent()
        entity.clientEntity:AfterInitComponent()
    
        entity.clientEntity.UIComponent.entityTop:RefreshPos()

        self.world.ClientEntitySystem:AddEntity(entity.clientEntity)
    end

    entity.SkillComponent:InitSkill(defenderData.skill_list)
    
    return entity
end