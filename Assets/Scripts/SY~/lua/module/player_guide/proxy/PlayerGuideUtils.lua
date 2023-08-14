PlayerGuideUtils = BaseClass("PlayerGuideUtils")

---获取场景UI
---@param tag string 标签
---@param args table|nil 参数
---@return table
function PlayerGuideUtils.GetSceneUI(tag,args)
    args = args or {}
    local targetTrans,targetObj,worldPos,rootObj
    if tag == "random_unit" then
        targetTrans = BattleDefine.nodeObjs["mixed"]:Find("operate/random_handler")
        targetObj = targetTrans.gameObject
        rootObj = BattleDefine.nodeObjs["mixed"]:Find("operate/dice").gameObject
    elseif tag == "money" then
        targetTrans = BattleDefine.nodeObjs["mixed"]:Find("node_pos/money")
        targetObj = targetTrans.gameObject
        rootObj = BattleDefine.nodeObjs["mixed"]:Find("operate/asset_info").gameObject
    elseif tag == "grid" then
        if RunWorld then
            assert(args.grid, "请配置字段[grid]")
            do
                return {}
            end
            local pos = RunWorld.BattleMixedSystem:GetPlaceSlotPos(args.grid)  -- TODO 场景化UI修改为2dUI
            worldPos = Vector3(pos.x,pos.y,pos.z)
            local findOutArgs = {}
            -- mod.BattleFacade:SendEvent(BattleHeroOperateView.Event.GetPlaceGridObj,args.grid,findOutArgs) --TODO 场景化UI修改为2dUI
            targetObj = findOutArgs.targetObj
            targetTrans = targetObj.transform
            rootObj = BattleDefine.nodeObjs["mixed/operate/place_slot"]:Find(tostring(args.grid)).gameObject  -- TODO 场景化UI修改为2dUI
        end
    elseif tag == "road" then
        local roadIndex = args.roadIndex
        assert(args.roadIndex, "请配置字段[roadIndex]")
        if roadIndex == 1 then
            targetTrans = BattleDefine.nodeObjs["mixed"]:Find("node_pos/road_1")
            rootObj = targetTrans.gameObject
        elseif roadIndex == 2 then
            targetTrans = BattleDefine.nodeObjs["mixed"]:Find("node_pos/road_2")
            rootObj = targetTrans.gameObject
        end
    elseif tag == "rage_skill" then
        assert(args.skillId, "请配置字段[skillId]")
        local findOutArgs = {}
        mod.BattleFacade:SendEvent(BattleCommanderDragSkillView.Event.GetRageSkillObj,args.skillId,findOutArgs)
        targetTrans = findOutArgs.targetObj.transform
        targetObj = targetTrans.gameObject
        rootObj = targetObj
    elseif tag == "rage_skill_value" then
        assert(args.skillId, "请配置字段[skillId]")
        local findOutArgs = {}
        mod.BattleFacade:SendEvent(BattleCommanderDragSkillView.Event.GetRageSkillObj,args.skillId,findOutArgs)
        targetTrans = findOutArgs.consumeObj.transform
        rootObj = targetTrans.gameObject
    elseif tag == "operate_top" then
        targetTrans = BattleDefine.nodeObjs["mixed"]:Find("operate/next_group_info")
        --TODO next_group_info Object更改
        rootObj = targetTrans.gameObject
    elseif tag == "grid_root" then
        rootObj = BattleDefine.nodeObjs["mixed/operate/place_slot"].gameObject  -- TODO 场景化UI修改为2dUI
        targetTrans = rootObj.transform
    end
    return {targetTrans=targetTrans,targetObj=targetObj,worldPos=worldPos,rootObj=rootObj}
end

---获取场景实体
---@param tag string 标签
---@param args table|nil 参数
---@return table
function PlayerGuideUtils.GetSceneEntity(tag,args)
    args = args or {}
    local entitys = {}
    if RunWorld then
        if tag == "hero" then
            local roleUid
            if args.isEnermy then
                local enermyData = RunWorld.BattleDataSystem:GetEnemyRoleData()
                roleUid = enermyData.role_base.role_uid
            else
                roleUid = RunWorld.BattleDataSystem.roleUid
            end
            local ids = RunWorld.EntitySystem:GetRoleEntitys(roleUid, args.id)
            for _, id in ipairs(ids or {}) do
                local entity = RunWorld.EntitySystem:GetEntity(id)
                if entity then
                    table.insert(entitys, entity)
                end
            end
        end
    end
    return entitys
end

---获取场景物体
---@param tag string 标签
---@param args table|nil 参数
---@return table
function PlayerGuideUtils.GetSceneObject(tag,args)
    local objs = {}
    local entitys = PlayerGuideUtils.GetSceneEntity(tag,args)
    for _, entity in ipairs(entitys or {}) do
        if entity.clientEntity.ClientTransformComponent then
            local obj = entity.clientEntity.ClientTransformComponent.gameObject
            table.insert(objs, obj)
        end
    end
    return objs
end