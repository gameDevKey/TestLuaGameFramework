AreaFixComponent = BaseClass("AreaFixComponent",SECBComponent)
AreaFixComponent.UPDATE_PRIORITY = 100

function AreaFixComponent:__Init()

end

function AreaFixComponent:__Delete()

end

function AreaFixComponent:OnInit()

end

function AreaFixComponent:OnLateUpdate()
    local fromPos = self.entity.TransformComponent:GetPos()

    local toPos = fromPos + self.entity.TransformComponent.velocity + self.entity.TransformComponent.steeringForce

    local x,z = 0,0
    local terrainBaseInfo = self.world.BattleTerrainSystem.terrainInfos["baseInfo"]
    if fromPos.x <= terrainBaseInfo.beginPosX then
        x = terrainBaseInfo.beginPosX - toPos.x + 1
    elseif fromPos.x >= terrainBaseInfo.endPosX then
        x = terrainBaseInfo.endPosX - toPos.x - 1
    end
    
    if fromPos.z >= terrainBaseInfo.beginPosZ then
        z = terrainBaseInfo.beginPosZ - toPos.z - 1
    elseif fromPos.z <= terrainBaseInfo.endPosZ then
        z = terrainBaseInfo.endPosZ - toPos.z + 1
    end

    if x ~= 0 or z ~= 0 then
        self.entity.TransformComponent:AddVelocity(x,0,z)
        return
    end

    --TODO:临时战斗代码
    if self.world.BattleDataSystem.pvpConf.id ~= 8 then
        do return end
    end

    

    if not self.entity.ObjectDataComponent:IsSameWalkType(BattleDefine.WalkType.floor) then
        return
    end

    local flag,index = self.world.BattleTerrainSystem:InRoadArea(fromPos.x,fromPos.z)
    if not flag then
        return
    end

    local roadRectPos = self.world.BattleTerrainSystem.terrainInfos.roadRectPos

    if index == 1 and toPos.x >= roadRectPos[4].x then
        x =  roadRectPos[4].x - toPos.x - 1
    elseif index == 2 and toPos.x <= roadRectPos[5].x then
        x = roadRectPos[5].x - toPos.x + 1
    elseif index == 2 and toPos.x >= roadRectPos[8].x then
        x =  roadRectPos[8].x - toPos.x - 1
    elseif index == 3 and toPos.x <= roadRectPos[9].x then
        x = roadRectPos[9].x - toPos.x + 1
    end

    if x ~= 0 or z ~= 0 then
        self.entity.TransformComponent:AddVelocity(x,0,z)
    end

    do return end

    local flag = self.world.BattleTerrainSystem:InCenterBlock(toPos.x,toPos.z)
    if not flag then
        return
    end

    


    local x,z = 0,0
    local centerBlock = self.world.BattleTerrainSystem.terrainInfos["centerBlock"]

    if fromPos.x <= centerBlock.beginPosX then
        x = centerBlock.beginPosX - toPos.x
    elseif fromPos.x >= centerBlock.endPosX then
        x = centerBlock.endPosX - toPos.x
    elseif fromPos.z >= centerBlock.beginPosZ then
        z = centerBlock.beginPosZ - toPos.z
    elseif fromPos.z <= centerBlock.endPosZ then
        z = centerBlock.endPosZ - toPos.z
    end

    self.entity.TransformComponent:AddVelocity(x,0,z)

    --Log("在中心区域了",self.entity.uid,x,z,fromPos.x,fromPos.z,toPos.x,toPos.z)
    --CS.UnityEditor.EditorApplication.isPaused = true
end