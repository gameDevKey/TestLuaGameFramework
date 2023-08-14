SearchEntityAIAction = BaseClass("SearchEntityAIAction",BTAction)

function SearchEntityAIAction:__Init()
    self.range = {}
    self.fromRange = {}
end

function SearchEntityAIAction:__Delete()

end

function SearchEntityAIAction:OnStart()

end

function SearchEntityAIAction:OnCreate()
    local rangeConf = self.owner.entity.ObjectDataComponent.unitConf.atk_range

    self.range.type = rangeConf.type
    self.range.radius = rangeConf.radius
    self.range.width = rangeConf.width
    self.range.height = rangeConf.height
    self.range.uid = 0
    self.range.appendModel = true

    self.fromRange.type = rangeConf.type
    self.fromRange.radius = rangeConf.radius
    self.fromRange.width = rangeConf.width
    self.fromRange.height = rangeConf.height
end

function SearchEntityAIAction:OnUpdate(deltaTime)
    local castArgs = self.owner:GetCacheData("skill_cast_args")
    local lastTargetUid = self.owner:GetCacheData("last_search_entity")
    --Log("上次目标",lastTargetUid)

    local range = self:GetRange()

    local findParam = {}
    findParam.entity = self.owner.entity
    findParam.targetNum = 1
    findParam.priorityType1 = BattleDefine.SearchPriority.min_to_self_dis
    findParam.camp = self.owner.entity.CampComponent:GetCamp()
    findParam.priorityEntityUid = lastTargetUid
    findParam.isLock = true
    
    findParam.targetArgs = {}
    findParam.targetArgs.targetCamp = BattleDefine.TargetCampType.enemy


    local followWalkType = self.owner.entity.ObjectDataComponent.unitConf.follow_walk_type
    if followWalkType == BattleDefine.FollowWalkType.floor then
        findParam.targetArgs.walkType = BattleDefine.WalkType.floor
    elseif followWalkType == BattleDefine.FollowWalkType.fly then
        findParam.targetArgs.walkType = BattleDefine.WalkType.fly
    else
        if castArgs.canAtkFly and castArgs.canAtkFloor then
            findParam.targetArgs.walkType = BattleDefine.WalkType.all
        elseif castArgs.canAtkFly then
            findParam.targetArgs.walkType = BattleDefine.WalkType.fly
        elseif castArgs.canAtkFloor then
            findParam.targetArgs.walkType = BattleDefine.WalkType.floor
        end
    end

    if followWalkType == BattleDefine.FollowWalkType.home then
        findParam.targetArgs.targetTypes = BattleDefine.HomeUnitTypes
    else
        findParam.targetArgs.targetTypes = BattleDefine.NotHomeUnitTypes
    end

    local pos = self.owner.entity.TransformComponent:GetPos()
    findParam.transInfo = {posX = pos.x,posZ = pos.z}

    local entitys,_ = self.owner.world.BattleSearchSystem:SearchByRange(findParam,range)
    if #entitys > 0 then
    --    Log("搜寻到实体了")
    end

    self.owner:SetCacheData("search_entitys",entitys)

    if #entitys > 0 then
        self.owner:SetCacheData("last_search_entity",entitys[1])
    else
        self.owner:SetCacheData("last_search_entity",nil)
    end

    return BTTaskStatus.Success
end

function SearchEntityAIAction:GetRange()
    local changeInfo = self.owner.entity.KvDataComponent:GetData(BattleDefine.EntityKvType.change_range)
    if changeInfo and self.range.uid ~= changeInfo.uid then
        self.range.uid = changeInfo.uid
        self.owner.world.BattleMixedSystem:ChangeRange(self.fromRange,self.range,changeInfo.changes)
    end
    return self.range
end