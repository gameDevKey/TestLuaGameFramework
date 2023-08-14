ResetPvpBattleStateGuideNode = BaseClass("ResetPvpBattleStateGuideNode",BaseGuideNode)
--不要在各个System里面写重置逻辑，重置这种操作，只会在新手引导里面发生，在System里面写重置逻辑，会污染代码

function ResetPvpBattleStateGuideNode:__Init()

end

function ResetPvpBattleStateGuideNode:OnStart()
    for v in RunWorld.EntitySystem.entityList:Items() do
        local uid = v.value
        local entity = RunWorld.EntitySystem:GetEntity(uid)
        if entity and not (entity.TagComponent:IsTag(BattleDefine.EntityTag.home) or entity.TagComponent:IsTag(BattleDefine.EntityTag.commander)) then
            if entity.clientEntity and entity.clientEntity.ClientTransformComponent then
                entity.clientEntity.ClientTransformComponent.gameObject:SetActive(false)
                if entity.clientEntity.UIComponent then
                    RunWorld.ClientIFacdeSystem:Call("ForceActiveEntityTop",uid,false)
                end
            end

            if not entity.StateComponent or not entity.StateComponent:IsState(BattleDefine.EntityState.die) then
                RunWorld.PluginSystem.EntityFunc:RemoveEntityDisableComponent(entity)
                RunWorld.EntitySystem:RemoveEntity(uid)
            end
            
        end
        if entity and not entity.TagComponent:IsTag(BattleDefine.EntityTag.home) then
            self:PlayEffect(entity)
        end
    end

    self:ResetCampData(BattleDefine.Camp.attack)
    self:ResetCampData(BattleDefine.Camp.defence)
    RunWorld.BattleDataSystem:InitRolePkData()

    self:TryUnlockGrids()

    RunWorld.BattleCommanderSystem:InitData()

    RunWorld.BattleGroupSystem.group = 0
    RunWorld.BattleGroupSystem:InitGroup()

    RunWorld.BattleReserveUnitSystem.reserveIndex = RunWorld.BattleReserveUnitSystem.reserveIndex + 1


    local defenceRoleUid = RunWorld.BattleDataSystem:GetRoleUidByIndex(BattleDefine.Camp.defence,1)


    RunWorld.BattleAssetsSystem.effectManager:ClearEffects({[EffectDefine.EffectType.action] = true})

    -- mod.BattleFacade:SendEvent(BattleHeroOperateView.Event.RefreshPlaceSlot) --TODO 场景化UI改为2dUI
    -- mod.BattleFacade:SendEvent(BattleHeroOperateView.Event.RefreshPlaceSlotExt)
    mod.BattleFacade:SendEvent(BattleCommanderDragSkillView.Event.RefreshView)
    mod.BattleFacade:SendEvent(BattleInfoView.Event.RefreshMoney)
    mod.BattleFacade:SendEvent(BattleInfoView.Event.RefreshGroupNum,RunWorld.BattleGroupSystem.group)
    mod.BattleFacade:SendEvent(BattleEnemyGridView.Event.RefreshEnemyHeroGrid,defenceRoleUid)
end

--播放重置特效，暂时用升星特效代替
function ResetPvpBattleStateGuideNode:PlayEffect(entity)
    if not entity then
        return
    end
    local pos = entity.TransformComponent:GetPos()
    local effectId = 100001
    RunWorld.BattleAssetsSystem:PlaySceneEffect(effectId,pos.x,pos.y,pos.z,EffectDefine.EffectType.action)
end

function ResetPvpBattleStateGuideNode:TryUnlockGrids()
    if not TableUtils.IsEmpty(self.actionParam.grids) then
        for uid, _ in pairs(RunWorld.BattleDataSystem.rolePkDatas) do
            RunWorld.BattleDataSystem:ResetGridUnlockData(uid)
        end
        RunWorld.BattleDataSystem:ClearCustomExtList()
        for _, gridId in ipairs(self.actionParam.grids) do
            for uid, _ in pairs(RunWorld.BattleDataSystem.rolePkDatas) do
                RunWorld.BattleDataSystem:UnlockGrid(uid, gridId)
            end
            RunWorld.BattleDataSystem:AddCustomExtGrid(gridId)
        end
    end
end

function ResetPvpBattleStateGuideNode:OnDestroy()

end

function ResetPvpBattleStateGuideNode:ResetCampData(camp)
    local curCommanderEntity = RunWorld.EntitySystem:GetCommanderByCamp(camp)
    RunWorld.PluginSystem.EntityFunc:RemoveEntityDisableComponent(curCommanderEntity)
    RunWorld.EntitySystem:RemoveEntity(curCommanderEntity.uid)
    if curCommanderEntity.clientEntity and curCommanderEntity.clientEntity.ClientTransformComponent then
        curCommanderEntity.clientEntity.ClientTransformComponent.gameObject:SetActive(false)
    end

    --
    local roleUid = RunWorld.BattleDataSystem:GetRoleUidByIndex(camp,1)
    local homeUid = RunWorld.BattleMixedSystem:GetEnemyHomeUid(camp)
    local homeEntity = RunWorld.EntitySystem:GetEntity(homeUid)
    local homeMaxHp = homeEntity.AttrComponent:GetValue(GDefine.Attr.max_hp)
    homeEntity.AttrComponent:AddValue(BattleDefine.Attr.hp,homeMaxHp - homeEntity.AttrComponent:GetValue(BattleDefine.Attr.hp))

    local commanderInfo = RunWorld.BattleDataSystem:GetCampCommanderInfo(roleUid)
    local commanderEntity = RunWorld.BattleEntityCreateSystem:CreateCommander(roleUid,commanderInfo,camp)
    commanderEntity.CollistionComponent:SetRadius(homeEntity.CollistionComponent:GetRadius())
    commanderEntity.AIComponent:AddAI(1001)

    local attackMagicCards = RunWorld.BattleDataSystem:GetMagicCards(roleUid)
    for i,v in ipairs(attackMagicCards) do
        RunWorld.BattleEntityCreateSystem:CreateMagicCard(roleUid,v,camp)
    end

    RunWorld.BattleHaloSystem:InitCommanderHalo(roleUid,camp,commanderInfo.unit_id)


    local conf = RunWorld.BattleConfSystem:CommanderData_data_base_info(commanderInfo.unit_id)
    homeEntity.clientEntity.UIComponent.entityTop:RefreshRage(0,conf.max_rage)


    -- local rolePkData = RunWorld.BattleDataSystem.rolePkDatas[roleUid]
    -- rolePkData.unitDatas = {}
    -- rolePkData.gridToUnits = {}
    -- rolePkData.unitStars = {}
    -- rolePkData.randomUnits = {}
    -- rolePkData.randomMoney = 0
    -- rolePkData.randomNum = 0
end
