BattleTerrainSystem = BaseClass("BattleTerrainSystem",SECBEntitySystem)

function BattleTerrainSystem:__Init()
    self.terrainInfos = {}

    self.previewGridNode = nil
    self.gridMeshFilter = nil
    self.gridMaterial = nil

    self.enableRoadArea = true

    self.stancePos = {}

    self.terrainY = 0
    self.commanderTerrainY = self.terrainY + 670


    self.angleDir = 0
end

function BattleTerrainSystem:__Delete()

end

function BattleTerrainSystem:OnInitSystem()

end

function BattleTerrainSystem:OnLateInitSystem()

end

function BattleTerrainSystem:InitTerrain()
    local roadNodePos = {}
    -- roadNodePos[1] = {x = -4000,z = 1500}
    -- roadNodePos[2] = {x = -2700,z = 1500}
    -- roadNodePos[3] = {x = -4000,z = -1500}
    -- roadNodePos[4] = {x = -2700,z = -1500}

    -- roadNodePos[5] = {x = 2700,z = 1500}
    -- roadNodePos[6] = {x = 4000,z = 1500}
    -- roadNodePos[7] = {x = 2700,z = -1500}
    -- roadNodePos[8] = {x = 4000,z = -1500}

    -- roadNodePos[9] = {x = -650,z = 1500}
    -- roadNodePos[10] = {x = 650,z = 1500}
    -- roadNodePos[11] = {x = -650,z = -1500}
    -- roadNodePos[12] = {x = 650,z = -1500}

    roadNodePos[1] = {x = -3876,z = 3219}
    roadNodePos[2] = {x = -3076,z = 3219}
    roadNodePos[3] = {x = -2276,z = 3219}
    roadNodePos[4] = {x = -800,z = 3219}
    roadNodePos[5] = {x = 0,z = 3219}
    roadNodePos[6] = {x = 800,z = 3219}
    roadNodePos[7] = {x = 2276,z = 3219}
    roadNodePos[8] = {x = 3076,z = 3219}
    roadNodePos[9] = {x = 3876,z = 3219}

    roadNodePos[10] = {x = -3876,z = -3219}
    roadNodePos[11] = {x = -3076,z = -3219}
    roadNodePos[12] = {x = -2276,z = -3219}
    roadNodePos[13] = {x = -800,z = -3219}
    roadNodePos[14] = {x = 0,z = -3219}
    roadNodePos[15] = {x = 800,z = -3219}
    roadNodePos[16] = {x = 2276,z = -3219}
    roadNodePos[17] = {x = 3076,z = -3219}
    roadNodePos[18] = {x = 3876,z = -3219}

    self.terrainInfos["roadNodePos"] = roadNodePos


    local roadRectPos = {}
    roadRectPos[1] = {x = -4425,z = 3219}
    roadRectPos[2] = {x = -1760,z = 3219}
    roadRectPos[3] = {x = -4425,z = -3219}
    roadRectPos[4] = {x = -1760,z = -3219}

    roadRectPos[5] = {x = -1240,z = 3219}
    roadRectPos[6] = {x = 1240,z = 3219}
    roadRectPos[7] = {x = -1240,z = -3219}
    roadRectPos[8] = {x = 1240,z = -3219}

    roadRectPos[9] = {x = 1760,z = 3219}
    roadRectPos[10] = {x = 4425,z = 3219}
    roadRectPos[11] = {x = 1760,z = -3219}
    roadRectPos[12] = {x = 4425,z = -3219}
    self.terrainInfos["roadRectPos"] = roadRectPos





    local baseInfo = {}
    baseInfo.beginPosX = -4425
    baseInfo.beginPosZ = 8235
    baseInfo.endPosX = baseInfo.beginPosX + 8850
    baseInfo.endPosZ = baseInfo.beginPosZ - 16470
    


    --中心阻隔区域
    baseInfo.centerBlockBeginX = -4425
    baseInfo.centerBlockBeginZ = 3219
    baseInfo.centerBlockEndX = 4425
    baseInfo.centerBlockEndZ = -3219
    

    self.terrainInfos["baseInfo"] = baseInfo
    

    -- local centerBlock = {}
    -- centerBlock.beginPosX = -2200
    -- centerBlock.beginPosZ = 1350
    -- centerBlock.endPosX = 2200
    -- centerBlock.endPosZ = -1350
    -- self.terrainInfos["centerBlock"] = centerBlock


    local attackInfos = {}
    attackInfos.areaBeginX = -4425
    attackInfos.areaBeginZ = -742
    attackInfos.areaEndX = 4425
    attackInfos.areaEndZ = -8235

    attackInfos.roadPos = {}
    -- attackInfos.roadPos[1] = {index = 3,reverseIndex = 1}
    -- attackInfos.roadPos[2] = {index = 4,reverseIndex = 2}
    -- attackInfos.roadPos[3] = {index = 7,reverseIndex = 5}
    -- attackInfos.roadPos[4] = {index = 8,reverseIndex = 6}
    -- attackInfos.roadPos[5] = {index = 11,reverseIndex = 9}
    -- attackInfos.roadPos[6] = {index = 12,reverseIndex = 10}

    attackInfos.roadPos[1] = {index = 10,reverseIndex = 1}
    attackInfos.roadPos[2] = {index = 11,reverseIndex = 2}
    attackInfos.roadPos[3] = {index = 12,reverseIndex = 3}
    attackInfos.roadPos[4] = {index = 13,reverseIndex = 4}
    attackInfos.roadPos[5] = {index = 14,reverseIndex = 5}
    attackInfos.roadPos[6] = {index = 15,reverseIndex = 6}
    attackInfos.roadPos[7] = {index = 16,reverseIndex = 7}
    attackInfos.roadPos[8] = {index = 17,reverseIndex = 8}
    attackInfos.roadPos[9] = {index = 18,reverseIndex = 9}

    self.terrainInfos[BattleDefine.Camp.attack] = attackInfos


    local defenceInfos = {}
    defenceInfos.areaBeginX = -4425
    defenceInfos.areaBeginZ = 8235
    defenceInfos.areaEndX = 4425
    defenceInfos.areaEndZ = 742

    defenceInfos.roadPos = {}
    -- defenceInfos.roadPos[1] = {index = 6,reverseIndex = 8}
    -- defenceInfos.roadPos[2] = {index = 5,reverseIndex = 7}
    -- defenceInfos.roadPos[3] = {index = 2,reverseIndex = 4}
    -- defenceInfos.roadPos[4] = {index = 1,reverseIndex = 3}
    -- defenceInfos.roadPos[5] = {index = 9,reverseIndex = 11}
    -- defenceInfos.roadPos[6] = {index = 10,reverseIndex = 12}

    defenceInfos.roadPos[1] = {index = 1,reverseIndex = 10}
    defenceInfos.roadPos[2] = {index = 2,reverseIndex = 11}
    defenceInfos.roadPos[3] = {index = 3,reverseIndex = 12}
    defenceInfos.roadPos[4] = {index = 4,reverseIndex = 13}
    defenceInfos.roadPos[5] = {index = 5,reverseIndex = 14}
    defenceInfos.roadPos[6] = {index = 6,reverseIndex = 15}
    defenceInfos.roadPos[7] = {index = 7,reverseIndex = 16}
    defenceInfos.roadPos[8] = {index = 8,reverseIndex = 17}
    defenceInfos.roadPos[9] = {index = 9,reverseIndex = 18}

    self.terrainInfos[BattleDefine.Camp.defence] = defenceInfos
end

function BattleTerrainSystem:SetEnableRoadArea(flag)
    self.enableRoadArea = flag
end

function BattleTerrainSystem:InitPreviewGrid()
    if self.previewGridNode then
        return
    end
    
    self.previewGridNode = BattleDefine.rootNode.transform:Find("grid/preview_grid").gameObject
    self.gridMeshFilter = self.previewGridNode:GetComponent(MeshFilter)
    self.gridMaterial = self.previewGridNode:GetComponent(MeshRenderer).material
end

function BattleTerrainSystem:GetAreaCamp(selfCamp,z)
    local attackInfos = self.terrainInfos[BattleDefine.Camp.attack]
    if z <= attackInfos.areaBeginZ and z >= attackInfos.areaEndZ then
        return BattleDefine.Camp.attack
    end

    local defenceInfos = self.terrainInfos[BattleDefine.Camp.defence]
    if z <= defenceInfos.areaBeginZ and z >= defenceInfos.areaEndZ then
        return BattleDefine.Camp.defence
    end

    return nil

    -- if selfCamp == BattleDefine.Camp.attack then
    --     return BattleDefine.Camp.defence
    -- elseif selfCamp == BattleDefine.Camp.defence then
    --     return BattleDefine.Camp.attack
    -- end
end

function BattleTerrainSystem:InCenterBlock(z)
    local baseInfo = self.terrainInfos["baseInfo"]
    if z >= baseInfo.centerBlockBeginZ then
        return false
    end

    if z <= baseInfo.centerBlockEndZ then
        return false
    end

    return true
end

--是否在道路x范围内
function BattleTerrainSystem:InRoadX(x)
    local roadRectPos = self.terrainInfos.roadRectPos
    if x >= roadRectPos[1].x and x <= roadRectPos[2].x then
        return true,1
    elseif x >= roadRectPos[5].x and x <= roadRectPos[6].x then
        return true,2
    elseif x >= roadRectPos[9].x and x <= roadRectPos[10].x then
        return true,3
    else
        return false,nil
    end
end

function BattleTerrainSystem:GetRoadIndex(x)
    local roadRectPos = self.terrainInfos.roadRectPos
    if x >= roadRectPos[1].x and x <= roadRectPos[2].x then
        return BattleDefine.RoadIndex.left
    elseif x >= roadRectPos[5].x and x <= roadRectPos[6].x then
        return BattleDefine.RoadIndex.middle
    elseif x >= roadRectPos[9].x and x <= roadRectPos[10].x then
        return BattleDefine.RoadIndex.right
    else
        return BattleDefine.RoadIndex.none
    end
end

function BattleTerrainSystem:InRoadArea(x,z)
    if not self.enableRoadArea then
        return false,nil
    end

    local roadRectPos = self.terrainInfos.roadRectPos
    if x >= roadRectPos[1].x and x <= roadRectPos[4].x and z >= roadRectPos[3].z and z <= roadRectPos[2].z then
        return true,1
    elseif x >= roadRectPos[5].x and x <= roadRectPos[8].x and z >= roadRectPos[7].z and z <= roadRectPos[6].z then
        return true,2
    elseif x >= roadRectPos[9].x and x <= roadRectPos[12].x and z >= roadRectPos[11].z and z <= roadRectPos[10].z then
        return true,3
    else
        return false,nil
    end
end

function BattleTerrainSystem:GetCampRoadZ(camp)
    local terrainInfo = self.terrainInfos[camp]
    local roadIndex = terrainInfo.roadPos[1].index
    local pos = self.terrainInfos.roadNodePos[roadIndex]
    return pos.z
end

function BattleTerrainSystem:GetMinRoadPos(camp,x,z,lastIndex)
    local terrainInfo = self.terrainInfos[camp]
    
    local minDis = nil
    local roadIndex = nil
    for i,v in ipairs(terrainInfo.roadPos) do
        local pos = self.terrainInfos.roadNodePos[v.index]
        local dis = BattleUtils.CalMagnitude(x,z,pos.x,pos.z)
        if not minDis or dis < minDis or (lastIndex and minDis == dis and lastIndex == i) then
            minDis = dis
            roadIndex = i
        end
    end

    local index = terrainInfo.roadPos[roadIndex].index
    return self.terrainInfos.roadNodePos[index].x,self.terrainInfos.roadNodePos[index].z,roadIndex
end

function BattleTerrainSystem:PosToCamp(x,z,selfCamp)
    local attackInfos = self.terrainInfos[BattleDefine.Camp.attack]
    if x >= attackInfos.areaBeginX and x <= attackInfos.areaEndX 
        and z <= attackInfos.areaBeginZ and z >= attackInfos.areaEndZ then
        return BattleDefine.Camp.attack
    end

    local defenceInfos = self.terrainInfos[BattleDefine.Camp.defence]
    if x >= defenceInfos.areaBeginX and x <= defenceInfos.areaEndX 
        and z <= defenceInfos.areaBeginZ and z >= defenceInfos.areaEndZ then
        return BattleDefine.Camp.defence
    end

    --在中间区域
    if selfCamp == BattleDefine.Camp.attack then
        return BattleDefine.Camp.defence
    elseif selfCamp == BattleDefine.Camp.defence then
        return BattleDefine.Camp.attack
    end
end

function BattleTerrainSystem:PosToCampByZ(z,selfCamp)
    local attackInfos = self.terrainInfos[BattleDefine.Camp.attack]
    local defenceInfos = self.terrainInfos[BattleDefine.Camp.defence]

    if selfCamp == BattleDefine.Camp.attack and z <= attackInfos.areaBeginZ then
        return BattleDefine.Camp.attack
    elseif selfCamp == BattleDefine.Camp.defence and z >= defenceInfos.areaEndZ then
        return BattleDefine.Camp.defence
    end

    --在中间区域
    if selfCamp == BattleDefine.Camp.attack then
        return BattleDefine.Camp.defence
    elseif selfCamp == BattleDefine.Camp.defence then
        return BattleDefine.Camp.attack
    end
end

function BattleTerrainSystem:GetCampCutZ(camp)
    local infos = self.terrainInfos[camp]
    if camp == BattleDefine.Camp.attack then
        return infos.areaBeginZ
    elseif camp == BattleDefine.Camp.defence then
        return infos.areaEndZ
    end
end

function BattleTerrainSystem:GetCampAreaRandomPos(camp)
    local infos = self.terrainInfos[camp]
    local x = self.world.BattleRandomSystem:Random(infos.areaBeginX,infos.areaEndX)
    local z = self.world.BattleRandomSystem:Random(infos.areaEndZ,infos.areaBeginZ)
    return x,z
end


function BattleTerrainSystem:ActivePreviewGrid(flag,gridNum,maxRow,maxCol,width,height,beginX,beginZ,onRowCol)
    self:InitPreviewGrid()

    self.previewGridNode:SetActive(flag)
    if not flag then
        return
    end

    local args = {}
    args.meshFilter = self.gridMeshFilter
    args.material = self.gridMaterial
    args.vertices = {}
    args.gridNum = gridNum
    args.onRowCol = onRowCol
    args.maxRow = maxRow
    args.maxCol = maxCol
    args.width = width
    args.height = height
    args.beginX = beginX
    args.beginZ = beginZ
    args.posY = 0.01

    BattleUtils.CreateVerticeGrid(args)
end

function BattleTerrainSystem:InitTerrainCollider()
    local x = self.world.BattleCollistionSystem.mapCenterX
    local z = self.world.BattleCollistionSystem.mapCenterZ
    local width = self.world.BattleCollistionSystem.mapWidth
    local height = self.world.BattleCollistionSystem.mapHeight
    width = width * 2
    height = height * 2
    local colliderPos = {}
    colliderPos.x = x * 0.001
    colliderPos.y = 0
    colliderPos.z = z * 0.001
    BattleDefine.nodeObjs["terrain_collider"].transform.localPosition = colliderPos
    BattleDefine.nodeObjs["terrain_collider"].transform.localScale = Vector3(width*0.001,0.5,height*0.001)
end


function BattleTerrainSystem:PosFix(entity,x,z)
    local newX,newZ = 0,0
    local terrainBaseInfo = self.terrainInfos["baseInfo"]
    if x <= terrainBaseInfo.beginPosX then
        newX = terrainBaseInfo.beginPosX
    elseif x >= terrainBaseInfo.endPosX then
        newX = terrainBaseInfo.endPosX
    elseif z >= terrainBaseInfo.beginPosZ then
        newZ = terrainBaseInfo.beginPosZ
    elseif z <= terrainBaseInfo.endPosZ then
        newZ = terrainBaseInfo.endPosZ
    end

    if newX ~= 0 or newZ ~= 0 then
        return newX,newZ
    end

    do
        return x,z
    end

    newX = x
    newZ = z

    if not entity.ObjectDataComponent:IsSameWalkType(BattleDefine.WalkType.floor) then
        return newX,newZ
    end

    local flag = self:InCenterBlock(x,z)
    if not flag then
        return newX,newZ
    end

    local centerBlock = self.terrainInfos["centerBlock"]

    local upDis = FPMath.Abs(centerBlock.beginPosZ - z)
    local downDis = FPMath.Abs(centerBlock.endPosZ - z)
    local leftDis = FPMath.Abs(centerBlock.beginPosX - x)
    local rightDis = FPMath.Abs(centerBlock.endPosX - x)

    local minDis = upDis
    local index = 1
    if downDis < minDis then
        index = 2
    end
    if leftDis < minDis then
        index = 3
    end
    if rightDis < minDis then
        index = 4
    end

    if index == 1 then
        newZ = centerBlock.beginPosZ
    elseif index == 2 then
        newZ = centerBlock.endPosZ
    elseif index == 3 then
        newX = centerBlock.beginPosX
    elseif index == 4 then
        newX = centerBlock.endPosX
    end

    return newX,newZ
end


function BattleTerrainSystem:GetStancePos(camp,index)
    local dir = self.world.BattleMixedSystem:GetCampIndex(camp)
    if not self.stancePos[dir] or not self.stancePos[dir][index] then
        local pos = self.world.BattleDataSystem.pvpConf.stance_pos[index]
        if not self.stancePos[dir] then
            self.stancePos[dir] = {}
        end
        self.stancePos[dir][index] = {x = pos[1] * dir,z = pos[2] * dir}
    end
    return self.stancePos[dir][index]
end

function BattleTerrainSystem:GetHomeStancePos(camp)
    local dir = self.world.BattleMixedSystem:GetCampIndex(camp)
    local index = 0
    if not self.stancePos[dir] or not self.stancePos[dir][index] then
        local pos = self.world.BattleDataSystem.pvpConf.commander_pos
        if not self.stancePos[dir] then
            self.stancePos[dir] = {}
        end
        self.stancePos[dir][index] = {x = pos[1] * dir,z = pos[2] * dir}
    end
    return self.stancePos[dir][index]
end