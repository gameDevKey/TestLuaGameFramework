BattleFunCtrl = BaseClass("BattleFunCtrl",Controller)

function BattleFunCtrl:__Init()

end


function BattleFunCtrl:UnitToStar(args)
    if not RunWorld then
        return
    end

    local unitId = tonumber(args[1])
    local star = tonumber(args[2])

    local unitConf = Config.UnitData.data_unit_info[unitId]
    if not unitConf then
        SystemMessage.Show(string.format("gm单位设置星级异常,不存在的单位Id[单位Id:%s]",tostring(unitId)))
        return
    end

    if not star then
        SystemMessage.Show(string.format("gm单位设置星级异常,错误的星级[星级:%s]",tostring(star)))
        return
    end

    local key = unitId .."_" .. star
    local starConf = Config.UnitData.data_unit_star_info[key]
    if not starConf then
        SystemMessage.Show(string.format("gm单位设置星级异常,unit_data中不存在对应星级配置[单位Id:%s][星级:%s]",tostring(unitId),tostring(star)))
        return
    end

    local roleUid = RunWorld.BattleDataSystem.roleUid

    local unitData = RunWorld.BattleDataSystem:GetUnitData(roleUid,unitId)
    local grid = unitData and unitData.grid_id or RunWorld.BattleDataSystem:GetEnemyUnlockGird(roleUid)
    RunWorld.BattleMixedSystem:UpdateUnit(roleUid,unitId,grid,star)

    RunWorld.ClientIFacdeSystem:Call("RefreshHeroGrid",roleUid)
    RunWorld.ClientIFacdeSystem:Call("SendEvent","BattleInfoView","RefreshMoney")
    RunWorld.ClientIFacdeSystem:Call("SendEvent","BattleHeroGridView","RefreshExtGrid")
end


function BattleFunCtrl:UnitMaxEnergy(args)
    if not RunWorld then
        return
    end

    local unitId = tonumber(args[1])

    local unitConf = Config.UnitData.data_unit_info[unitId]
    if not unitConf then
        SystemMessage.Show(string.format("gm单位设置满怒异常,不存在的单位Id[单位Id:%s]",tostring(unitId)))
        return
    end

    for v in RunWorld.EntitySystem.entityList:Items() do
        local entityUid = v.value
        local entity = RunWorld.EntitySystem:GetEntity(entityUid)
        if entity and entity.CampComponent.camp == BattleDefine.Camp.attack 
            and entity.TagComponent.mainTag == BattleDefine.EntityTag.hero
            and entity.ObjectDataComponent.unitConf.id == unitId then
            local maxEnergy = entity.AttrComponent:GetValue(GDefine.Attr.max_energy)
            local curEnergy = entity.AttrComponent:GetValue(BattleDefine.Attr.energy)
            entity.HitComponent:HitEnergy(9999999)
        end
    end
end