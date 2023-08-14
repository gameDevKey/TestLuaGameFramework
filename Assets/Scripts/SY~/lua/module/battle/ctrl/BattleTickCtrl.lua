BattleTickCtrl = BaseClass("BattleTickCtrl",Controller)

function BattleTickCtrl:__Init()
    --DEBUG_COLLISTION_RANGE = true

    -- local test1 = TestQuaternion(0,0,0,0)
    -- test1:SetFromToRotation(Vector3(1,0,0), Vector3(0.4,0,0.6))
    -- Log("test1",test1.x,test1.y,test1.z,test1.w)
   

    -- local test2 = CS_FPQuaternion(0,0,0,0)
    -- test2:SetFromToRotation(FPVector3(1000,0,0), FPVector3(400,0,600))
    -- Log("test2",test2.x,test2.y,test2.z,test2.w)
    -- local test1Obj = GameObject()
    -- test1Obj.name = "test2"
    -- test1Obj.transform.rotation = Quaternion(test2.x * 0.001,test2.y * 0.001,test2.z * 0.001,test2.w * 0.001)


    -- local test3 = Quaternion(0,0,0,0)
    -- test3:SetFromToRotation(Vector3(1,0,0), Vector3(0.4,0,0.6))
    -- Log("test3",test3.x,test3.y,test3.z,test3.w)

    -- local test1Obj = GameObject()
    -- test1Obj.name = "test3"
    -- test1Obj.transform.rotation = test3
end

function BattleTickCtrl:ResetData()

end

function BattleTickCtrl:Update(deltaTime)
    for _,world in pairs(mod.BattleProxy.worlds) do
        world:Update(deltaTime)
    end

    -- if RunWorld and BattleDefine.mainPanel then
    --     BattleDefine.mainPanel:Update()
    -- end

    self:CheckFlyingText()
    self:CheckHeroTopItem()

    if Input.GetKey(KeyCode.Space) and RunWorld then
        if RunWorld and RunWorld.BattleStateSystem.localRun then
            DEBUG_SPEED = 10
        end
    end

    if Input.GetKeyUp(KeyCode.Space) and RunWorld then
        if RunWorld and RunWorld.BattleStateSystem.localRun then
            DEBUG_SPEED = nil
        end

        --RunWorld.BattleResultSystem:OverResult(BattleDefine.BattleResult.win)

        --添加buff
        -- for v in RunWorld.EntitySystem.entityList:Items() do
        --     local entityUid = v.value
        --     local entity = RunWorld.EntitySystem:GetEntity(entityUid)
        --     if entity and entity.CampComponent.camp == 1 and entity.TagComponent.mainTag == BattleDefine.EntityTag.hero then
        --         Log("添加buff",entity.uid)
        --         entity.BuffComponent:AddBuff(0,5)
        --     end
        -- end

        --检查Buff
        -- mod.GmFunCtrl:LogAllHeroBuff()

        -- local heroInfo = nil
        -- for i=1,BattleDefine.GridNum do
        --     heroInfo = RunWorld.BattleDataSystem:GetHeroGird(RunWorld.BattleDataSystem.roleUid,i)
        --     if heroInfo then
        --         break
        --     end
        -- end

        

        --local entity1 = RunWorld.BattleEntityCreateSystem:CreateHeroEntity(RunWorld.BattleDataSystem.roleUid,heroInfo,3,1,1,1)
        --Log("id",entity1.uid)
        -- --entity1.CollistionComponent.mass = entity1.CollistionComponent.mass + 100
        -- entity1.TransformComponent:SetPos(0,0,-10000)
        -- entity1.MoveComponent:MoveToPos(0,0,10000,{})

        -- local entity2 = RunWorld.BattleEntityCreateSystem:CreateHeroEntity(RunWorld.BattleDataSystem.roleUid,heroInfo,3,1,1,1)
        -- entity2.TransformComponent:SetPos(0,0,-10000)
        -- entity2.MoveComponent:MoveToPos(0,0,10000,{})

        --RunWorld.BattleStateSystem:SetBattleResult(BattleDefine.BattleResult.win)
        --RunWorld.BattleStateSystem.winCamp = BattleDefine.Camp.attack
        

        -- local entity3 = RunWorld.BattleEntityCreateSystem:CreateHeroEntity(RunWorld.BattleDataSystem.roleUid,heroInfo,3,1,1,1)
        -- entity3.TransformComponent:SetPos(3000,0,-6280)
        -- entity3.MoveComponent:MoveToPos(-3000,0,-6280,{})

        --Network.Instance:Disconnect()


        --RunWorld:SetRunError(true)
    end

    -- if Input.GetKeyUp(KeyCode.F1) and RunWorld then
    --     DEBUG_HP = not DEBUG_HP
    --     for v in RunWorld.EntitySystem.entityList:Items() do
    --         local entityUid = v.value
    --         local entity = RunWorld.EntitySystem:GetEntity(entityUid)
    --         if entity and entity.clientEntity.UIComponent 
    --             and entity.clientEntity.UIComponent.entityTop and entity.clientEntity.UIComponent.entityTop["SetDebug"] then
    --             entity.clientEntity.UIComponent.entityTop:SetDebug(DEBUG_HP)
    --             entity.clientEntity.UIComponent.entityTop:RefreshHp()
    --         end
    --     end
    -- end

    if Input.GetKeyUp(KeyCode.F1) and RunWorld then
        DEBUG_REFER_GRID = not DEBUG_REFER_GRID
        Logf("调试参照地图格子[%s]",DEBUG_REFER_GRID and "开启" or "关闭")
        RunWorld.BattleCollistionSystem:ActiveDebugGrid(DEBUG_REFER_GRID)
    end

    --碰撞范围
    if Input.GetKeyUp(KeyCode.F2) and RunWorld then
        DEBUG_COLLISTION_RANGE = not DEBUG_COLLISTION_RANGE
        for v in RunWorld.EntitySystem.entityList:Items() do
            local entityUid = v.value
            local entity = RunWorld.EntitySystem:GetEntity(entityUid)
            if entity.clientEntity.ClientRangeComponent then
                entity.clientEntity.ClientRangeComponent:ActiveCollistionRange(DEBUG_COLLISTION_RANGE)
            end
        end
    end

    if Input.GetKeyUp(KeyCode.F3) and RunWorld then
        DEBUG_ATK_RANGE = not DEBUG_ATK_RANGE
        for v in RunWorld.EntitySystem.entityList:Items() do
            local entityUid = v.value
            local entity = RunWorld.EntitySystem:GetEntity(entityUid)
            if entity.clientEntity.ClientRangeComponent then
                entity.clientEntity.ClientRangeComponent:ActiveAtkRange(DEBUG_ATK_RANGE)
            end
        end
    end

   
    if Input.GetKeyUp(KeyCode.F4) and RunWorld then
        DEBUG_HP = not DEBUG_HP
        for v in RunWorld.EntitySystem.entityList:Items() do
            local entityUid = v.value
            local entity = RunWorld.EntitySystem:GetEntity(entityUid)
            if entity and entity.clientEntity and entity.clientEntity.UIComponent 
                and entity.clientEntity.UIComponent.entityTop and entity.clientEntity.UIComponent.entityTop["SetDebug"] then
                entity.clientEntity.UIComponent.entityTop:SetDebug(DEBUG_HP)
                entity.clientEntity.UIComponent.entityTop:RefreshHp()
            end
        end
    end

    if Input.GetKeyUp(KeyCode.F5) then
        local app = IOUtils.GetAbsPath(Application.dataPath .. "/../app.exe");
        CS.System.Diagnostics.Process.Start(app)
        Application.Quit()
    end
    

    if Input.GetKeyUp(KeyCode.F6) and RunWorld then
        DEBUG_COLLISTION_GRID = not DEBUG_COLLISTION_GRID
        Logf("调试碰撞地图格子[%s]",DEBUG_COLLISTION_GRID and "开启" or "关闭")
        RunWorld.BattleCollistionSystem:ActivePreviewGrid(DEBUG_COLLISTION_GRID)
    end

    if Input.GetKeyUp(KeyCode.F7) and RunWorld then
        DEBUG_COLLISTION_OCCUPY_GRID = not DEBUG_COLLISTION_OCCUPY_GRID
        Logf("调试碰撞占用格子[%s]",DEBUG_COLLISTION_OCCUPY_GRID and "开启" or "关闭")
        RunWorld.BattleCollistionSystem:ActiveOccupyGrids(DEBUG_COLLISTION_OCCUPY_GRID)
    end

    if Input.GetKeyUp(KeyCode.F8) then
        DEBUG_FLYHP = not DEBUG_FLYHP
    end

    if Input.GetKeyUp(KeyCode.F11) then
        --mod.BattleCtrl:EnterDebugReplay("2022-10-11-17-24-23")
    end

    if Input.GetKeyUp(KeyCode.F12) and RunWorld then
        mod.BattleCtrl:SaveWorld(RunWorld)
    end
end

function BattleTickCtrl:CheckFlyingText()
    --技能解锁
    if Input.GetKeyUp(KeyCode.Y) and RunWorld then
        --测试飘字
        for v in RunWorld.EntitySystem.entityList:Items() do
            local entityUid = v.value
            RunWorld.ClientIFacdeSystem:Call("SendEvent","FlyingTextView","ShowFlyingText",BattleDefine.FlyingText.skill_unlock,
                {uid = entityUid,skillName = "测试技能",skillIcon = 1001})
        end
    end

    --技能喊招
    if Input.GetKeyUp(KeyCode.U) and RunWorld then
        --测试飘字
        for v in RunWorld.EntitySystem.entityList:Items() do
            local entityUid = v.value
            local entity = RunWorld.EntitySystem:GetEntity(entityUid)
            if entity and entity.CampComponent.camp == 1 then
                RunWorld.ClientIFacdeSystem:Call("SendEvent","FlyingTextView","ShowFlyingText",BattleDefine.FlyingText.skill_banner,
                    {uid = entityUid, unitId = 10111, skillId = 1011104})
            end
        end
    end

    --暴击
    if Input.GetKeyUp(KeyCode.Q) and RunWorld then
        --测试飘字
        for v in RunWorld.EntitySystem.entityList:Items() do
            local entityUid = v.value
            RunWorld.ClientIFacdeSystem:Call("SendEvent","FlyingTextView","ShowFlyingText",BattleDefine.FlyingText.hp,
                {value = -1234,isCrit = true,uid = entityUid})
        end
    end
    
    --伤害
    if Input.GetKeyUp(KeyCode.W) and RunWorld then
        --测试飘字
        for v in RunWorld.EntitySystem.entityList:Items() do
            local entityUid = v.value
            RunWorld.ClientIFacdeSystem:Call("SendEvent","FlyingTextView","ShowFlyingText",BattleDefine.FlyingText.hp,
                {value = -5678,isCrit = false,uid = entityUid})
        end
    end

    --治疗
    if Input.GetKeyUp(KeyCode.T) and RunWorld then
        --测试飘字
        for v in RunWorld.EntitySystem.entityList:Items() do
            local entityUid = v.value
            RunWorld.ClientIFacdeSystem:Call("SendEvent","FlyingTextView","ShowFlyingText",BattleDefine.FlyingText.hp,
                {value = 8888,uid = entityUid})
        end
    end

    --能量
    if Input.GetKeyUp(KeyCode.E) and RunWorld then
        --测试飘字
        for v in RunWorld.EntitySystem.entityList:Items() do
            local entityUid = v.value
            RunWorld.ClientIFacdeSystem:Call("SendEvent","FlyingTextView","ShowFlyingText",BattleDefine.FlyingText.energy,
                {value = 9999,uid = entityUid})
        end
    end

    --护盾
    if Input.GetKeyUp(KeyCode.R) and RunWorld then
        --测试飘字
        for v in RunWorld.EntitySystem.entityList:Items() do
            local entityUid = v.value
            RunWorld.ClientIFacdeSystem:Call("SendEvent","FlyingTextView","ShowFlyingText",BattleDefine.FlyingText.shield,
                {value = 7777,uid = entityUid})
        end
    end
end

function BattleTickCtrl:CheckHeroTopItem()
    if Input.GetKeyUp(KeyCode.Z) and RunWorld then
        for v in RunWorld.EntitySystem.entityList:Items() do
            local entityUid = v.value
            local entity = RunWorld.EntitySystem:GetEntity(entityUid)
            if entity and entity.AttrComponent and entity.clientEntity.UIComponent and entity.clientEntity.UIComponent.entityTop then
                -- LogYqh("添加最大血量",entityUid)
                entity.AttrComponent:AddValue(GDefine.Attr.max_hp,100)
            end
        end
    end
    if Input.GetKeyUp(KeyCode.X) and RunWorld then
        for v in RunWorld.EntitySystem.entityList:Items() do
            local entityUid = v.value
            local entity = RunWorld.EntitySystem:GetEntity(entityUid)
            if entity and entity.AttrComponent and entity.clientEntity.UIComponent and entity.clientEntity.UIComponent.entityTop then
                -- LogYqh("添加最大护盾",entityUid)
                entity.AttrComponent:AddValue(BattleDefine.Attr.extra_hp,50)
            end
        end
    end
end