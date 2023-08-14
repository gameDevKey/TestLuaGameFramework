BattleCtrl = BaseClass("BattleCtrl",Controller)

function BattleCtrl:__Init()

end

function BattleCtrl:__InitCtrl()

end

function BattleCtrl:EnterPK(data)
    local roleData = mod.RoleProxy.roleData

    local opts = SECBOptions.New()
    opts:SetFrameRate(20,50)
    opts:SetClient(true)
    opts:SetClientWorldType(BattleClientWorld)

    opts:SetComponentOrder(BattleDefine.ComponentInitOrder,BattleDefine.ComponentUpdateOrder,BattleDefine.ComponentDelOrder)

    local worldType = BattleWorld
    if data.qualifying_base_id == 8 then
        worldType = PvpWorld
    end

    local runWorld = worldType.New(opts)
    runWorld:SetUid(data.qualifying_id)
    runWorld:SetWorldType(BattleDefine.WorldType.pvp)

    runWorld.BattleDataSystem:SetRoleUid(roleData.role_uid)
    runWorld.BattleOperationSystem:SetClientInput(false)

    mod.BattleProxy:AddWorld(runWorld)
    mod.BattleProxy:SetRunWorld(runWorld)


    runWorld.BattleEnterSystem:EnterPK(data)


    if BaseSetting.editor and BattleDefine.localCheck and not runWorld.BattleStateSystem.localRun then
        local opts = SECBOptions.New()
        opts:SetFrameRate(20,50)
        opts:SetClient(false)
        opts:SetClientWorldType(BattleClientWorld)

        opts:SetComponentOrder(BattleDefine.ComponentInitOrder,BattleDefine.ComponentUpdateOrder,BattleDefine.ComponentDelOrder)

        local checkWorld = worldType.New(opts)
        checkWorld:SetUid(-runWorld.uid)
        checkWorld:SetWorldType(BattleDefine.WorldType.pvp)
        checkWorld.isCheck = true

        local checkRoleUid = nil
        for i,v in ipairs(runWorld.BattleDataSystem.data.role_list) do
            if v.role_base.role_uid ~= runWorld.BattleDataSystem.roleUid then
                checkRoleUid = v.role_base.role_uid
            end
        end

        checkWorld.BattleDataSystem:SetRoleUid(checkRoleUid)
        checkWorld.BattleOperationSystem:SetClientInput(false)

        checkWorld.BattleEnterSystem:EnterPK(data)

        runWorld:SetCheckWorld(checkWorld,runWorld:ToFunc("CheckWorld"))
    end
end

function BattleCtrl:EnterPve(data)
    local roleData = mod.RoleProxy.roleData

    local opts = SECBOptions.New()
    opts:SetFrameRate(20,50)
    opts:SetClient(true)
    opts:SetClientWorldType(BattleClientWorld)

    opts:SetComponentOrder(BattleDefine.ComponentInitOrder,BattleDefine.ComponentUpdateOrder,BattleDefine.ComponentDelOrder)

    local runWorld = PveWorld.New(opts)
    runWorld:SetUid(data.pve_uid)
    runWorld:SetWorldType(BattleDefine.WorldType.pve)

    runWorld.BattleTerrainSystem:SetEnableRoadArea(false)

    runWorld.BattleDataSystem:SetRoleUid(roleData.role_uid)
    runWorld.BattleStateSystem:SetLocalRun(true)
    runWorld.BattleOperationSystem:SetClientInput(true)

    mod.BattleProxy:AddWorld(runWorld)
    mod.BattleProxy:SetRunWorld(runWorld)

    runWorld.BattleEnterSystem:EnterPK(data)


    -- if BaseSetting.editor and BattleDefine.localCheck then
    --     local opts = SECBOptions.New()
    --     opts:SetFrameRate(20,50)
    --     opts:SetClient(false)
    --     opts:SetClientWorldType(BattleClientWorld)

    --     opts:SetComponentOrder(BattleDefine.ComponentInitOrder,BattleDefine.ComponentUpdateOrder,BattleDefine.ComponentDelOrder)

    --     local checkWorld = PveWorld.New(opts)
    --     checkWorld:SetUid(-data.pve_uid)
    --     checkWorld:SetWorldType(BattleDefine.WorldType.pve)

    --     local checkRoleUid = nil
    --     for i,v in ipairs(runWorld.BattleDataSystem.data.role_list) do
    --         if v.role_base.role_uid ~= runWorld.BattleDataSystem.roleUid then
    --             checkRoleUid = v.role_base.role_uid
    --         end
    --     end

    --     checkWorld.BattleDataSystem:SetRoleUid(checkRoleUid)
    --     checkWorld.BattleOperationSystem:SetClientInput(false)

    --     checkWorld.BattleEnterSystem:EnterPK(data)

    --     runWorld:SetCheckWorld(checkWorld,runWorld:ToFunc("CheckWorld"))
    -- end
end

function BattleCtrl:EnterDebugReplay(file)
    file = BattleUtils.GetReplayFile(file)
    Log("开始回放文件:" .. file)


    local debugData = nil
    if BaseSetting.channel == ChannelDefine.wxgame then
        local content = LuaManager.Instance:GetFileDataToString("wxgame_battle.data")
        LogInfo(content)
        debugData = TableUtils.StringToTable(content)
    else
        debugData = TableUtils.StringToTable(IOUtils.ReadAllText(file))
    end

   
    
    mod.BattleProxy:SetReadyEnterData(debugData.enter_data)

    local opts = SECBOptions.New()
    opts:SetFrameRate(20,50)
    opts:SetClient(true)
    opts:SetClientWorldType(BattleClientWorld)

    opts:SetComponentOrder(BattleDefine.ComponentInitOrder,BattleDefine.ComponentUpdateOrder,BattleDefine.ComponentDelOrder)

    local world = BattleWorld.New(opts)
    world:SetUid(debugData.enter_data.qualifying_id)
    world:SetWorldType(BattleDefine.WorldType.pvp)

    world.BattleConfSystem:SetCahceConf(debugData.result_data.conf)
    world.BattleDataSystem:SetRoleUid(debugData.role_uid)
    world.BattleStateSystem:SetLocalRun(true)
    world.BattleStateSystem:SetReplay(true)
    world.BattleOperationSystem:SetClientInput(false)

    mod.BattleProxy:AddWorld(world)
    mod.BattleProxy:SetRunWorld(world)


    world.BattleEnterSystem:EnterPK(debugData.enter_data)

    for frame,v in pairs(debugData.frame_data) do
        for _,opData in ipairs(v) do
            world.BattleOperationSystem:AddRemoteInput(frame,opData)
        end
    end
end

function BattleCtrl:EnterBattle(data)
    -- data.battle_actor = {}

    -- local roleData = {}
    -- roleData.id = 1
    -- roleData.config_id = 1
    -- roleData.camp = 1
    -- roleData.hp = 1000
    -- roleData.max_hp = 1000
    -- roleData.action_val = 1
    -- roleData.max_action_val = 1
    -- roleData.actor_round = 0
    -- roleData.slot = 1

    -- table.insert(data.battle_actor,roleData)


    -- local roleData = {}
    -- roleData.id = 2
    -- roleData.config_id = 2
    -- roleData.camp = 2
    -- roleData.hp = 1000
    -- roleData.max_hp = 1000
    -- roleData.action_val = 1
    -- roleData.max_action_val = 1
    -- roleData.actor_round = 0
    -- roleData.slot = 1

    -- table.insert(data.battle_actor,roleData)



    local opts = SECBOptions.New()
    opts:SetFrameRate(15,66)
    opts:SetClient(true)
    opts:SetClientWorldType(BattleClientWorld)

    opts:SetComponentOrder(BattleDefine.ComponentInitOrder,BattleDefine.ComponentUpdateOrder,BattleDefine.ComponentDelOrder)

    local world = BattleWorld.New(opts)

    mod.BattleProxy:AddWorld(world,1)
    mod.BattleProxy:SetRunWorld(world)

    world.BattleStateSystem:SetBattleState(BattleDefine.BattleState.enter)
    world.BattleDataSystem:InitData(data)

    world.BattleEnterSystem:EnterPK()

    do return end
    world:SetData(data)

    
    --如果是观战，roleData.role_id不要从本地取
    local roleData = mod.RoleProxy.roleData
    local selfCamp = nil
    for _,v in ipairs(data.member_list) do
        if v.role_uid == roleData.role_uid then
            selfCamp = v.camp
            break
        end
    end

    local extraData = {}
    extraData.selfCamp = selfCamp

    -- local selfCampNum = 0
    -- local enemyCampNum = 0
    -- for _,v in ipairs(data.object_list) do
    --     local flag = world.BattleMixedSystem:IsSelfCamp(v.camp)
    --     if flag then
    --         selfCampNum = selfCampNum + 1
    --     else
    --         enemyCampNum = enemyCampNum + 1
    --     end
    -- end
    -- extraData.selfCampNum = selfCampNum
    -- extraData.enemyCampNum = enemyCampNum


    --Log("阵营",extraData.selfCamp)


    world:SetExtraData(extraData)

    mod.BattleProxy:AddWorld(world)
    mod.BattleProxy:SetRunWorld(world)


    world.BattleEnterSystem:EnterBattle()
end

function BattleCtrl:ExitBattle(world)

    if BaseSetting.editor and RunWorld == world and not world.BattleStateSystem.localRun then
        BattleCheckoutSystem.DebugCheckBattle(world.BattleDataSystem.roleUid,world.BattleDataSystem.data
            ,world.BattleOperationSystem.remoteInputs,world.BattleResultSystem.resultFrame)
    end

    if SAVE_BATTLE_DATA then
        SAVE_BATTLE_DATA = false
        self:SaveWorld(world)
    end

    mod.BattleProxy:RemoveWorld(world.uid)

    local stopwatch = CS.System.Diagnostics.Stopwatch()
    stopwatch:Start()
    world:Destroy()
    stopwatch:Stop()
    local runTime = stopwatch.Elapsed.TotalMilliseconds
    Log("清理耗时",runTime)

    if RunWorld ~= world then
        return
    end

    -- if BattleDefine.mainPanel then
    --     BattleDefine.mainPanel:Destroy()
    --     BattleDefine.mainPanel = nil
    -- end
    RunWorld.BattlePreLoadSystem:ClearLoadersAndAsset()

    if BaseSetting.editor then
        for k,v in pairs(FlyingTextHpItem.PoolKey) do
            PoolManager.Instance:ClearPoolByKey(PoolType.base_view,v)
        end

        -- local classCreateInfos = {}
        -- for className,v in pairs(DebugFightClassCreate) do
        --     table.insert(classCreateInfos,{className = className,num = v.num})
        -- end

        -- table.sort(classCreateInfos,function(a,b)
        --     return a.num > b.num
        -- end)

        -- for i,v in ipairs(classCreateInfos) do
        --     Log("类创建信息",v.className,v.num)
        -- end


		for k,traceInfo in pairs(DebugFightClassClear) do
			Log("退出战斗时,对象未清理",traceInfo)
		end

		DebugFightClassClear = {}
        DebugFightClassCreate = {}
        
	end

    

    if BattleDefine.rootNode then
        BattleDefine.rootNode:SetActive(false)
    end
    
    mod.BattleProxy:SetRunWorld(nil)
    ViewManager.Instance:SetCheckMainui(true)
    ViewManager.Instance:CloseAllWindow()

    EventManager.Instance:SendEvent(EventDefine.on_battle_exit)
end

function BattleCtrl:ExitPve(world)

    if BaseSetting.editor and RunWorld == world and not world.BattleStateSystem.localRun then
        BattleCheckoutSystem.DebugCheckBattle(world.BattleDataSystem.roleUid,world.BattleDataSystem.data
            ,world.BattleOperationSystem.remoteInputs,world.BattleResultSystem.resultFrame)
    end

    mod.BattleProxy:RemoveWorld(world.uid)

    local stopwatch = CS.System.Diagnostics.Stopwatch()
    stopwatch:Start()
    world:Destroy()
    stopwatch:Stop()
    local runTime = stopwatch.Elapsed.TotalMilliseconds
    Log("清理耗时",runTime)

    if RunWorld ~= world then
        return
    end

    -- if BattleDefine.mainPanel then
    --     BattleDefine.mainPanel:Destroy()
    --     BattleDefine.mainPanel = nil
    -- end
    RunWorld.BattlePreLoadSystem:ClearLoadersAndAsset()

    if BaseSetting.editor then
        for k,v in pairs(FlyingTextHpItem.PoolKey) do
            PoolManager.Instance:ClearPoolByKey(PoolType.base_view,v)
        end

        -- local classCreateInfos = {}
        -- for className,v in pairs(DebugFightClassCreate) do
        --     table.insert(classCreateInfos,{className = className,num = v.num})
        -- end

        -- table.sort(classCreateInfos,function(a,b)
        --     return a.num > b.num
        -- end)

        -- for i,v in ipairs(classCreateInfos) do
        --     Log("类创建信息",v.className,v.num)
        -- end


		for k,traceInfo in pairs(DebugFightClassClear) do
			Log("退出战斗时,对象未清理",traceInfo)
		end

		DebugFightClassClear = {}
        DebugFightClassCreate = {}
        
	end

    

    if BattleDefine.rootNode then
        BattleDefine.rootNode:SetActive(false)
    end
    
    mod.BattleProxy:SetRunWorld(nil)
    ViewManager.Instance:SetCheckMainui(true)
    ViewManager.Instance:CloseAllWindow()

    EventManager.Instance:SendEvent(EventDefine.on_battle_exit) --TODO 修改事件
end

function BattleCtrl:CancelOperate()
    mod.BattleFacade:SendEvent(BattleFacade.Event.CancelOperate)
end


function BattleCtrl:CheckReconnet()
    if not RunWorld then
        return
    end

    Log("开始进行战斗重连")
    mod.BattleFacade:SendMsg(10418,RunWorld.BattleFrameSyncSystem.frame)
end

function BattleCtrl:ReconnectComplete()
    Log("重连,执行补帧完成")
    if RunWorld.BattleStateSystem.isAgainCheckReconnect then
        RunWorld.BattleStateSystem:SetAgainCheckReconnect(false)
		mod.BattleFacade:SendMsg(10418,RunWorld.BattleFrameSyncSystem.frame)
	else
		mod.BattleFacade:SendMsg(10419,RunWorld.BattleFrameSyncSystem.frame)
	end
end


function BattleCtrl:SaveWorld(world)
    if not world then
        return
    end
    
    local debugData = {}
    debugData["role_uid"] = world.BattleDataSystem.roleUid
    debugData["enter_data"] = world.BattleDataSystem.data
    debugData["frame_data"] = world.BattleOperationSystem.remoteInputs
    debugData["result_data"] =  {}
    debugData["result_data"].win_camp = world.BattleStateSystem.winCamp
    debugData["result_data"].frame = world.BattleResultSystem.resultFrame
    debugData["result_data"].conf = world.BattleConfSystem:GetCacheConf()
    
    local file = BattleUtils.GetReplayFile(os.date("%Y-%m-%d-%H-%M-%S"))
    IOUtils.CreateFolderByFile(file)

    local debugDataStr = string.gsub(TableUtils.TableToString(debugData),"\n", "")
    debugDataStr = string.gsub(debugDataStr,"\'{", "\"{")
    debugDataStr = string.gsub(debugDataStr,"}\'", "}\"")

    IOUtils.WriteAllText(file,debugDataStr)

    Log("保存成功:" .. file)
end