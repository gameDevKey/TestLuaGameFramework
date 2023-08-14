BattleEntityCreateSystem = BaseClass("BattleEntityCreateSystem",SECBSystem)

function BattleEntityCreateSystem:__Init()
end

function BattleEntityCreateSystem:__Delete()

end

function BattleEntityCreateSystem:OnInitSystem()

end

function BattleEntityCreateSystem:OnLateInitSystem()
    
end

function BattleEntityCreateSystem:CreatePveUnitEntity(roleUid,data,pos,group)
    --实体创建步骤
    --1.基础
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()
    entity:Init(data.unit_id,uid)
    entity:SetWorld(self.world)
    self:CreateComponents(entity,BattleEntityDefine.EntityCreateType.hero)

    --2.初始化组件基础数据（无关组件顺序）
    entity.ObjectDataComponent:SetObjectData(data)
    entity.ObjectDataComponent:SetRoleUid(roleUid)
    entity.ObjectDataComponent:SetGroup(group)
    entity.CampComponent:SetCamp(BattleDefine.Camp.attack)

    local unitConf = self.world.BattleConfSystem:UnitData_data_unit_info(data.unit_id)
    entity.ObjectDataComponent:SetBaseConf(self.world.BattleConfSystem:HeroData_data_hero_info(unitConf.base_id))
    entity.ObjectDataComponent:SetUnitConf(unitConf)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.hero)

    entity.CollistionComponent:InitRadius()

    entity.TransformComponent:SetPos(pos.x,pos.y,pos.z)
    local dirQuat = self.world.BattleMixedSystem:GetStanceDir(BattleDefine.Camp.attack)
    entity.TransformComponent:SetRotation(dirQuat)

    --3.调用组件初始化接口（组件执行OnInit、OnLateInit方法）
    entity:InitComponent()
    entity:AfterInitComponent()

    --4.调用组件逻辑（组件必须初始化后才能调用的逻辑，非必须）
    entity.StateComponent:SetState(BattleDefine.EntityState.born)

    --5.初始化客户端相组件
    if entity.clientEntity then
        entity.clientEntity.ClientTransformComponent:SetName(string.format("英雄[uid:%s][unitId:%s]",uid,data.unit_id))
        entity.clientEntity:InitComponent()
        entity.clientEntity:AfterInitComponent()
        entity.clientEntity.UIComponent.entityTop:RefreshPos()
        self.world.ClientEntitySystem:AddEntity(entity.clientEntity)
    end

    --6.添加进实体系统
    self.world.EntitySystem:AddEntity(entity)
    entity.SkillComponent:InitSkill(data.skill_list)

    return entity
end

function BattleEntityCreateSystem:CreateHeroEntity(roleUid,data,slot,camp,genNum,index,group)
    --实体创建步骤
    --1.基础
    --data.unit_id = 11
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()
    entity:Init(data.unit_id,uid)
    entity:SetWorld(self.world)
    self:CreateComponents(entity,BattleEntityDefine.EntityCreateType.hero)

    --2.初始化组件基础数据（无关组件顺序）
    entity.ObjectDataComponent:SetObjectData(data)
    entity.ObjectDataComponent:SetRoleUid(roleUid)
    entity.ObjectDataComponent:SetGroup(group)
    entity.ObjectDataComponent:SetGrid(slot)
    entity.CampComponent:SetCamp(camp)

    local unitConf = self.world.BattleConfSystem:UnitData_data_unit_info(data.unit_id)
    entity.ObjectDataComponent:SetBaseConf(self.world.BattleConfSystem:HeroData_data_hero_info(unitConf.base_id))
    entity.ObjectDataComponent:SetUnitConf(unitConf)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.hero)

    --TODO:调试技能，记得删
    -- if camp == 1 then
    --     local flag = true
    --     for i,v in ipairs(data.skill_list) do
    --         if v.skill_id == 1001 then
    --             flag = false
    --         end
    --     end
    --     if flag then
    --         table.insert(data.skill_list,{skill_id = 1001,skill_level = 1})
    --     end
    -- end
    -- table.insert(data.skill_list,{skill_id = 1001,skill_level = 1})
    --

    entity.CollistionComponent:InitRadius()
    local pos = self.world.BattleTerrainSystem:GetStancePos(camp,slot)
    local offsetPosX,offsetPosZ = self:GetMultiStanceOffsetPos(camp,genNum,index,entity.CollistionComponent:GetRadius())
    entity.TransformComponent:SetPos(pos.x + offsetPosX,self.world.BattleTerrainSystem.terrainY,pos.z + offsetPosZ)
    local dirQuat = self.world.BattleMixedSystem:GetStanceDir(camp)
    entity.TransformComponent:SetRotation(dirQuat)

    --3.调用组件初始化接口（组件执行OnInit、OnLateInit方法）
    entity:InitComponent()
    entity:AfterInitComponent()

    --4.调用组件逻辑（组件必须初始化后才能调用的逻辑，非必须）
    entity.StateComponent:SetState(BattleDefine.EntityState.born)

    --5.初始化客户端相组件
    if entity.clientEntity then
        entity.clientEntity.ClientTransformComponent:SetName(string.format("英雄[uid:%s][unitId:%s]",uid,data.unit_id))
        entity.clientEntity:InitComponent()
        entity.clientEntity:AfterInitComponent()
    
        entity.clientEntity.UIComponent.entityTop:RefreshPos()

        self.world.ClientEntitySystem:AddEntity(entity.clientEntity)
    end

    --6.添加进实体系统
    self.world.EntitySystem:AddEntity(entity)

    entity.SkillComponent:InitSkill(data.skill_list)
    
    return entity
end

function BattleEntityCreateSystem:GetMultiStanceOffsetPos(camp,genNum,index,radius)
    local campIndex = self.world.BattleMixedSystem:GetCampIndex(camp)
    local offsetInfo = BattleDefine.MultiStancePos[campIndex][genNum][index]

    local radiusOffset = FPMath.Divide(radius * 500,FPFloat.Precision)

    local x = radius * offsetInfo.xDir
    local xInterval = radiusOffset * offsetInfo.xInterval * offsetInfo.xDir
    x = FPMath.Divide(x * offsetInfo.xStep,FPFloat.Precision) + xInterval

    local z = radius * offsetInfo.zDir
    local zInterval = radiusOffset * offsetInfo.zInterval * offsetInfo.zDir
    z = FPMath.Divide(z * offsetInfo.zStep,FPFloat.Precision) + zInterval

    -- Logf("偏移信息[阵营:%s][生成数量:%s][第几个:%s][范围:%s][xDir:%s][xStep:%s][xInterval:%s][zDir:%s][zStep:%s][zInterval:%s][%s,%s]"
    --     ,camp,genNum,index,radius,offsetInfo.xDir,offsetInfo.xStep,offsetInfo.xInterval,offsetInfo.zDir,offsetInfo.zStep,offsetInfo.zInterval,x,z)

    return x,z
end

function BattleEntityCreateSystem:CreateSummonEntity(ownerEntity,unitId,lev,star,attrRatio,offsetPos,relativePos)
    local ownerUnitId = ownerEntity.ObjectDataComponent.objectData.unit_id
    local roleUid = ownerEntity.ObjectDataComponent.roleUid
    local heroBaseInfo = self.world.BattleDataSystem:GetHeroBaseInfo(roleUid,ownerUnitId)
    local camp = ownerEntity.CampComponent:GetCamp()

    if not lev or lev == 0 then
        lev = heroBaseInfo.level
    end

    if not star or star == 0 then
        star = ownerEntity.ObjectDataComponent:GetStar()
    end

    if not attrRatio  then
        attrRatio = 0
    end

    local unitBaseConf = self.world.BattleConfSystem:UnitData_data_unit_info(unitId)
    local unitLevConf = self.world.BattleConfSystem:UnitData_data_unit_lev_info(unitId,lev)
    local unitStarConf = self.world.BattleConfSystem:UnitData_data_unit_star_info(unitId,star)

    if not unitBaseConf or not unitLevConf or not unitStarConf then
        assert(false,string.format("不存在的召唤物单位[单位Id:%s][单位等级:%s][单位星级:%s]",unitId,lev,star))
    end
    
    local data = {}
    data.unit_id = unitId
    data.star = star
    data.attr_list,data.skill_list = BattleUtils.CloneUnitData(ownerEntity.AttrComponent.srcAttrs,unitLevConf,unitStarConf,attrRatio)


    --
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()
    entity:Init(unitId,uid)
    entity:SetOwnerUid(ownerEntity.uid)

    entity:SetWorld(self.world)
    self:CreateComponents(entity,BattleEntityDefine.EntityCreateType.hero)

    entity.ObjectDataComponent:SetObjectData(data)
    entity.ObjectDataComponent:SetRoleUid(roleUid)
    entity.CampComponent:SetCamp(camp)

    local unitConf = self.world.BattleConfSystem:UnitData_data_unit_info(data.unit_id)
    entity.ObjectDataComponent:SetUnitConf(unitConf)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.unit)

    local ownerPos = relativePos or ownerEntity.TransformComponent:GetPos()
    local ownerForward = ownerEntity.TransformComponent:GetForward()
    -- local offsetPos = BattleDefine.SummonStancePos[index]
    local pos = FPMath.Transform(FPVector3(offsetPos.x,offsetPos.y,offsetPos.z), ownerForward, ownerPos)

    entity.TransformComponent:SetPos(pos.x,pos.y,pos.z)
    local dirQuat = self.world.BattleMixedSystem:GetStanceDir(camp)
    entity.TransformComponent:SetRotation(dirQuat)

    --
    entity:InitComponent()
    entity:AfterInitComponent()

    

    entity.StateComponent:SetState(BattleDefine.EntityState.born)

    if entity.clientEntity then
        entity.clientEntity.ClientTransformComponent:SetName(string.format("召唤单位[uid:%s][object_id:%s]",uid,data.unit_id))
        entity.clientEntity:InitComponent()
        entity.clientEntity:AfterInitComponent()
    
        entity.clientEntity.UIComponent.entityTop:RefreshPos()

        self.world.ClientEntitySystem:AddEntity(entity.clientEntity)
    end

    self.world.EntitySystem:AddEntity(entity)

    entity.SkillComponent:InitSkill(data.skill_list)
    
    return entity
end


function BattleEntityCreateSystem:CreateSummonCommanderEntity(ownerEntity,unitId,lev,star,attrRatio,maxHpRatio,transInfo)
    local roleUid = ownerEntity.ObjectDataComponent.roleUid
    local loaderBaseInfo = self.world.BattleDataSystem:GetCampCommanderInfo(roleUid)
    local camp = ownerEntity.CampComponent:GetCamp()

    if not lev or lev == 0 then
        lev = loaderBaseInfo.level
    end

    if not star or star == 0 then
        star = ownerEntity.ObjectDataComponent:GetStar()
    end

    if not attrRatio then
        attrRatio = 0
    end

    local unitBaseConf = self.world.BattleConfSystem:UnitData_data_unit_info(unitId)
    local unitLevConf = self.world.BattleConfSystem:UnitData_data_unit_lev_info(unitId,lev)
    local unitStarConf = self.world.BattleConfSystem:UnitData_data_unit_star_info(unitId,star)

    if not unitBaseConf or not unitLevConf or not unitStarConf then
        assert(false,string.format("不存在的召唤统帅单位[单位Id:%s][单位等级:%s][单位星级:%s]",unitId,lev,star))
    end

    local data = {}
    data.unit_id = unitId
    data.star = star
    data.attr_list,data.skill_list = BattleUtils.CloneUnitData(loaderBaseInfo.attr_list,unitLevConf,unitStarConf,attrRatio)

    local homeUid = self.world.BattleDataSystem:GetHomeUid(camp)
    local homeEntity = self.world.EntitySystem:GetEntity(homeUid)
    local homeMaxHp = homeEntity.AttrComponent:GetValue(GDefine.Attr.max_hp)
    table.insert(data.attr_list,{attr_id = GDefine.Attr.max_hp,attr_val = FPMath.Divide(homeMaxHp * maxHpRatio,BattleDefine.AttrRatio)})
    
    --
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()
    entity:Init(unitId,uid)
    entity:SetOwnerUid(ownerEntity.uid)

    entity:SetWorld(self.world)
    self:CreateComponents(entity,BattleEntityDefine.EntityCreateType.hero)

    

    entity.ObjectDataComponent:SetObjectData(data)
    entity.ObjectDataComponent:SetRoleUid(roleUid)
    entity.CampComponent:SetCamp(camp)

    local unitConf = self.world.BattleConfSystem:UnitData_data_unit_info(data.unit_id)
    entity.ObjectDataComponent:SetUnitConf(unitConf)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.unit)

    --local pos = self.world.BattleMixedSystem:GetStancePos(camp,-2)
    entity.TransformComponent:SetPos(transInfo.posX,0,transInfo.posZ)
    local dirQuat = self.world.BattleMixedSystem:GetStanceDir(camp)
    entity.TransformComponent:SetRotation(dirQuat)

    --
    entity:InitComponent()
    entity:AfterInitComponent()

    entity.StateComponent:SetState(BattleDefine.EntityState.born)

    if entity.clientEntity then
        entity.clientEntity.ClientTransformComponent:SetName(string.format("召唤单位[uid:%s][object_id:%s]",uid,data.unit_id))
        entity.clientEntity:InitComponent()
        entity.clientEntity:AfterInitComponent()
    
        entity.clientEntity.UIComponent.entityTop:RefreshPos()

        self.world.ClientEntitySystem:AddEntity(entity.clientEntity)
    end

    self.world.EntitySystem:AddEntity(entity)

    entity.SkillComponent:InitSkill(data.skill_list)
    
    return entity
end


function BattleEntityCreateSystem:CreateSummonCloneEntity(ownerEntity,unitId,lev,star,attrList,radius)
    local ownerUnitId = ownerEntity.ObjectDataComponent.objectData.unit_id
    local ownerAttrList = ownerEntity.AttrComponent.srcAttrs
    local roleUid = ownerEntity.ObjectDataComponent.roleUid
    local heroBaseInfo = self.world.BattleDataSystem:GetHeroBaseInfo(roleUid,ownerUnitId)
    local camp = ownerEntity.CampComponent:GetCamp()

    if not unitId or unitId == 0 then
        unitId = ownerUnitId
    end

    if not lev or lev == 0 then
        lev = heroBaseInfo.level
    end

    if not star or star == 0 then
        star = ownerEntity.ObjectDataComponent:GetStar()
    else
        local lvConf = self.world.BattleConfSystem:UnitData_data_unit_lev_info(ownerUnitId,lev)
        local starConf = self.world.BattleConfSystem:UnitData_data_unit_star_info(ownerUnitId,star)
        ownerAttrList = BattleUtils.GetUnitAttrListByStar(starConf,lvConf)
    end

    local unitBaseConf = self.world.BattleConfSystem:UnitData_data_unit_info(unitId)
    local unitLevConf = self.world.BattleConfSystem:UnitData_data_unit_lev_info(unitId,lev)
    local unitStarConf = self.world.BattleConfSystem:UnitData_data_unit_star_info(unitId,star)

    if not unitBaseConf or not unitLevConf or not unitStarConf then
        error(string.format("不存在的分身单位[单位Id:%s][单位等级:%s][单位星级:%s]",unitId,lev,star))
    end

    local data = {}
    data.unit_id = unitId
    data.star = star
    data.attr_list,data.skill_list = BattleUtils.CloneUnitDataByAttrList(ownerAttrList,unitLevConf,unitStarConf,attrList)

    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()
    entity:Init(unitId,uid)
    entity:SetOwnerUid(ownerEntity.uid)
    entity:SetWorld(self.world)

    self:CreateComponents(entity,BattleEntityDefine.EntityCreateType.hero)

    entity.ObjectDataComponent:SetObjectData(data)
    entity.ObjectDataComponent:SetRoleUid(roleUid)
    entity.CampComponent:SetCamp(camp)

    local unitConf = self.world.BattleConfSystem:UnitData_data_unit_info(data.unit_id)
    entity.ObjectDataComponent:SetUnitConf(unitConf)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.unit, BattleDefine.EntityTag.clone_unit)

    local pos = ownerEntity.TransformComponent:GetPos()
    local ownerRadius = ownerEntity.CollistionComponent:GetRadius()
    local minR = ownerRadius
    local maxR = radius or 0
    local halfX = self.world.BattleRandomSystem:Random(minR,maxR)
    local halfY = self.world.BattleRandomSystem:Random(minR,maxR)
    local posX = self.world.BattleRandomSystem:Random(0,1) == 0 and halfX or -halfX
    local posY = self.world.BattleRandomSystem:Random(0,1) == 0 and halfY or -halfY
    entity.TransformComponent:SetPos(pos.x+posX,pos.y,pos.z+posY)
    local dirQuat = self.world.BattleMixedSystem:GetStanceDir(camp)
    entity.TransformComponent:SetRotation(dirQuat)

    entity:InitComponent()
    entity:AfterInitComponent()

    entity.StateComponent:SetState(BattleDefine.EntityState.born)

    if entity.clientEntity then
        entity.clientEntity.ClientTransformComponent:SetName(string.format("分身单位[uid:%s][ownerUid:%s]",uid,ownerEntity.uid))
        entity.clientEntity:InitComponent()
        entity.clientEntity:AfterInitComponent()

        entity.clientEntity.UIComponent.entityTop:RefreshPos()

        self.world.ClientEntitySystem:AddEntity(entity.clientEntity)
    end

    self.world.EntitySystem:AddEntity(entity)

    entity.SkillComponent:InitSkill(data.skill_list)

    return entity
end


function BattleEntityCreateSystem:CreateHomeEntity(roleUid,data,camp)
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()
    entity:Init(data.unit_id,uid)

    entity:SetWorld(self.world)
    self:CreateComponents(entity,BattleEntityDefine.EntityCreateType.home)

    entity.ObjectDataComponent:SetObjectData(data)
    entity.ObjectDataComponent:SetRoleUid(roleUid)
    entity.CampComponent:SetCamp(camp)
    entity.CollistionComponent:SetEnable(false)

    local unitConf = self.world.BattleConfSystem:UnitData_data_unit_info(data.unit_id)
    entity.ObjectDataComponent:SetBaseConf(self.world.BattleConfSystem:HomeData_data_home_info(unitConf.base_id))
    entity.ObjectDataComponent:SetUnitConf(unitConf)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.home)


    

    --TODO:正式化主堡技能
    -- data.skill_list = {}
    -- local skillInfo = {}
    -- skillInfo.id = 3001
    -- skillInfo.lev = 1
    -- table.insert(data.skill_list,skillInfo)

    -- entity.SkillComponent:InitSkill(data.skill_list)
    --end

    --LogTable("主堡技能",data.skill_list)

    local pos = self.world.BattleTerrainSystem:GetHomeStancePos(camp)
    entity.TransformComponent:SetPos(pos.x,self.world.BattleTerrainSystem.commanderTerrainY,pos.z)
    local dirQuat = self.world.BattleMixedSystem:GetStanceDir(camp)
    entity.TransformComponent:SetRotation(dirQuat)


    entity:InitComponent()
    entity:AfterInitComponent()
    

    entity.StateComponent:SetState(BattleDefine.EntityState.idle)

    if entity.clientEntity then
        entity.clientEntity.ClientTransformComponent:SetName(string.format("基地[uid:%s]",uid))
        entity.clientEntity:InitComponent()
        entity.clientEntity:AfterInitComponent()
    
        --entity.clientEntity.UIComponent.entityTop:RefreshPos()

        self.world.ClientEntitySystem:AddEntity(entity.clientEntity)
    end

    self.world.BattleDataSystem:AddHomeUid(uid,camp)

    self.world.EntitySystem:AddEntity(entity)

    entity.SkillComponent:InitSkill(data.skill_list)

    return entity
end

function BattleEntityCreateSystem:CreateFakeHomeEntity(roleUid,homeInfo,commanderInfo,camp)
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()
    entity:Init(homeInfo.unit_id,uid)

    homeInfo.attr_list = commanderInfo.attr_list

    entity:SetWorld(self.world)
    self:CreateComponents(entity,BattleEntityDefine.EntityCreateType.home)

    entity.ObjectDataComponent:SetObjectData(homeInfo)
    entity.ObjectDataComponent:SetRoleUid(roleUid)
    entity.CampComponent:SetCamp(camp)
    entity.CollistionComponent:SetEnable(false)

    local unitConf = self.world.BattleConfSystem:UnitData_data_unit_info(homeInfo.unit_id)
    entity.ObjectDataComponent:SetBaseConf(self.world.BattleConfSystem:HomeData_data_home_info(unitConf.base_id))
    entity.ObjectDataComponent:SetUnitConf(unitConf)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.home)


    

    --TODO:正式化主堡技能
    -- data.skill_list = {}
    -- local skillInfo = {}
    -- skillInfo.id = 3001
    -- skillInfo.lev = 1
    -- table.insert(data.skill_list,skillInfo)

    -- entity.SkillComponent:InitSkill(data.skill_list)
    --end

    --LogTable("主堡技能",data.skill_list)

    local pos = self.world.BattleTerrainSystem:GetHomeStancePos(camp)
    entity.TransformComponent:SetPos(pos.x,self.world.BattleTerrainSystem.commanderTerrainY,pos.z)
    local dirQuat = self.world.BattleMixedSystem:GetStanceDir(camp)
    entity.TransformComponent:SetRotation(dirQuat)


    entity:InitComponent()
    entity:AfterInitComponent()
    

    entity.StateComponent:SetState(BattleDefine.EntityState.idle)

    if entity.clientEntity then
        entity.clientEntity.ClientTransformComponent:SetName(string.format("基地[uid:%s]",uid))
        entity.clientEntity:InitComponent()
        entity.clientEntity:AfterInitComponent()
    
        --entity.clientEntity.UIComponent.entityTop:RefreshPos()

        self.world.ClientEntitySystem:AddEntity(entity.clientEntity)
    end

    self.world.BattleDataSystem:AddHomeUid(uid,camp)

    self.world.EntitySystem:AddEntity(entity)

    entity.SkillComponent:InitSkill(homeInfo.skill_list)

    return entity
end

function BattleEntityCreateSystem:CreateCommander(roleUid,data,camp)
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()
    entity:Init(data.unit_id,uid)

    entity:SetWorld(self.world)
    self:CreateComponents(entity,BattleEntityDefine.EntityCreateType.commander)

    entity.ObjectDataComponent:SetObjectData(data)
    entity.ObjectDataComponent:SetRoleUid(roleUid)
    entity.CampComponent:SetCamp(camp)
    entity.CollistionComponent:SetEnable(false)

    local unitConf = self.world.BattleConfSystem:UnitData_data_unit_info(data.unit_id)
    entity.ObjectDataComponent:SetUnitConf(unitConf)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.commander)


    local homeUid = self.world.BattleDataSystem:GetHomeUid(camp)
    local homeEntity = self.world.EntitySystem:GetEntity(homeUid)


    local pos = self.world.BattleTerrainSystem:GetHomeStancePos(camp)
    entity.TransformComponent:SetPos(pos.x,self.world.BattleTerrainSystem.commanderTerrainY + homeEntity.ObjectDataComponent.unitConf.model_height,pos.z)
    local dirQuat = self.world.BattleMixedSystem:GetStanceDir(camp)
    entity.TransformComponent:SetRotation(dirQuat)


    entity:InitComponent()
    entity:AfterInitComponent()
    

    entity.StateComponent:SetState(BattleDefine.EntityState.idle)

    if entity.clientEntity then
        entity.clientEntity.ClientTransformComponent:SetName(string.format("统帅[uid:%s][unit_id:%s]",uid,data.unit_id))
        entity.clientEntity:InitComponent()
        entity.clientEntity:AfterInitComponent()

        self.world.ClientEntitySystem:AddEntity(entity.clientEntity)
    end

    self.world.EntitySystem:AddEntity(entity)

    -- entity.SkillComponent:InitSkill(data.skill_list) --TODO 创建实体时直接加载所有技能列表
    if not self.world.BattleCommanderSystem.commanderInfos[roleUid] then
        assert(false,string.format("角色进场数据不存在统领信息[角色uid:%s]",roleUid))
    end

    local unlockSkills = self.world.BattleCommanderSystem.commanderInfos[roleUid].unlockSkills
    local skillList = {}
    for k, v in pairs(unlockSkills) do
        table.insert(skillList,{skill_id = v.skillId, skill_level = v.skillLevel})
    end
    local dragSkills = self.world.BattleCommanderSystem.commanderInfos[roleUid].dragSkills
    for k, v in pairs(dragSkills) do
        if v.skillId ~= 0 then
            table.insert(skillList,{skill_id = v.skillId, skill_level = v.skillLev})
        end
    end
    entity.SkillComponent:InitSkill(skillList)

    return entity
end

function BattleEntityCreateSystem:CreateMagicCard(roleUid,data,camp)
    local uid = self.world.EntitySystem:GetUid()
    local entity = BattleEntity.New()
    entity:Init(data.unit_id,uid)

    entity:SetWorld(self.world)
    self:CreateComponents(entity,BattleEntityDefine.EntityCreateType.magic_card)

    entity.ObjectDataComponent:SetObjectData(data)
    entity.ObjectDataComponent:SetRoleUid(roleUid)
    entity.CampComponent:SetCamp(camp)

    local unitConf = self.world.BattleConfSystem:UnitData_data_unit_info(data.unit_id)
    entity.ObjectDataComponent:SetUnitConf(unitConf)

    entity.TagComponent:SetTag(BattleDefine.EntityTag.magic_card)

    --
    entity.TransformComponent:SetPos(0,0,0)
    local dirQuat = self.world.BattleMixedSystem:GetStanceDir(camp)
    entity.TransformComponent:SetRotation(dirQuat)

    entity:InitComponent()
    entity:AfterInitComponent()

    if entity.clientEntity then
        entity.clientEntity.ClientTransformComponent:SetName(string.format("魔法卡[uid:%s][unit_id:%s]",uid,data.unit_id))
        entity.clientEntity:InitComponent()
        entity.clientEntity:AfterInitComponent()
        self.world.ClientEntitySystem:AddEntity(entity.clientEntity)
    end

    self.world.EntitySystem:AddEntity(entity)
    
    return entity
end



function BattleEntityCreateSystem:BindAttackAI(entity)
    local behavior = nil
    local walkType = entity.ObjectDataComponent:GetWalkType()
    if walkType == BattleDefine.WalkType.floor then
        --behavior = entity.BehaviorComponent:AddBehavior(FloorAttackAIBehavior)
        --behavior:Init()

        --TODO:临时战斗代码
        if self.world.BattleDataSystem.pvpConf.id == 8 then
            entity.AIComponent:AddAI(1004)
        else
            entity.AIComponent:AddAI(1006)
        end
    elseif walkType == BattleDefine.WalkType.fly then
        --behavior = entity.BehaviorComponent:AddBehavior(FlyAttackAIBehavior)
        --behavior:Init()
        entity.AIComponent:AddAI(1002)
    end
end

function BattleEntityCreateSystem:CreateComponents(entity,createType)
    local componentInfo = BattleEntityDefine.EntityBindComponents[createType]
    for i,v in ipairs(componentInfo.logic) do
        local ctype = _G[v]
        assert(ctype, string.format("添加逻辑组件异常,未实现的组件类型[%s]",v))
        entity:AddComponent(ctype)
    end

    if not self.world.opts.isClient or not componentInfo.client then
        return
    end

    local clientEntity = BattleClientEntity.New()
    clientEntity:SetWorld(self.world)
    clientEntity:SetEntity(entity)

    entity:SetClientEntity(clientEntity)

    for i,v in ipairs(componentInfo.client) do
        local ctype = _G[v]
        assert(ctype, string.format("添加客户端组件异常,未实现的组件类型[%s]",v))
        clientEntity:AddComponent(ctype)
    end
end