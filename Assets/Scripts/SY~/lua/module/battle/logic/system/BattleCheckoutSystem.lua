BattleCheckoutSystem = BaseClass("BattleCheckoutSystem",SECBEntitySystem)
BattleCheckoutSystem.checkoutWorlds = {}

function BattleCheckoutSystem:__Init()

end

function BattleCheckoutSystem:__Delete()

end

function BattleCheckoutSystem:OnInitSystem()

end

function BattleCheckoutSystem:OnLateInitSystem()
    
end

function BattleCheckoutSystem.CreateBattle(roleUid,enterData,frameData,cacheConf)
    local opts = SECBOptions.New()
    opts:SetFrameRate(20,50)
    opts:SetClient(false)

    opts:SetComponentOrder(BattleDefine.ComponentInitOrder,BattleDefine.ComponentUpdateOrder,BattleDefine.ComponentDelOrder)

    local world = BattleWorld.New(opts)
    world:SetUid(enterData.qualifying_id)
    if cacheConf then
        world.BattleConfSystem:SetCahceConf(cacheConf)
    end

    world.BattleDataSystem:SetRoleUid(roleUid)
    world.BattleOperationSystem:SetClientInput(false)

    world.BattleEnterSystem:EnterPK(enterData)

    if frameData then
        for frame,v in pairs(frameData) do
            for _,opData in ipairs(v) do
                world.BattleOperationSystem:AddRemoteInput(frame,opData)
            end
        end
    end

    return world
end

function BattleCheckoutSystem.DebugCheckBattleByFile(file)
    file = BattleUtils.GetReplayFile(file)
    local debugData = TableUtils.StringToTable(IOUtils.ReadAllText(file))
    BattleCheckoutSystem.DebugCheckBattle(debugData.role_uid,debugData.enter_data,debugData.frame_data,resultFrame)
end

function BattleCheckoutSystem.DebugCheckBattle(roleUid,enterData,frameData,resultFrame,isLog,isProfiler)
    local world = BattleCheckoutSystem.CreateBattle(roleUid,enterData,frameData)
    local beginGc = collectgarbage("count")
    
    ActiveCSType(false)

    if isProfiler then
        collectgarbage("stop")
    end

    local stopwatch = CS.System.Diagnostics.Stopwatch()
    stopwatch:Start()

    --local profiler = nil
    -- if isProfiler then
    --     profiler = require 'common/performance/Profiler'
    --     profiler.start()
    -- end


    while world.BattleStateSystem:IsBattleResult(BattleDefine.BattleResult.none) 
        and (not resultFrame or world.frame < resultFrame) do
        local t = os.clock()
        world:Update()
        t = os.clock() - t
        if isProfiler and t > 0.005 then
            print(string.format("帧执行间隔[帧:%s][耗时:%s]",world.frame,t))
        end
        --stopwatch2:Stop()
        --print(string.format("帧执行间隔[帧:%s][耗时:%sms]",world.frame,stopwatch2.Elapsed.TotalMilliseconds))
    end

    -- if isProfiler then
    --     print(profiler.report())
    --     profiler.stop()
    -- end

    stopwatch:Stop()

    if isProfiler then
        collectgarbage("restart")
    end

    

    ActiveCSType(true)
    local runTime = stopwatch.Elapsed.TotalMilliseconds
    local useGc = (collectgarbage("count") - beginGc) / 1024

    if isLog then
        Logf("战斗信息[耗时:%sms][帧数:%s][gc产生:%.2fmb]",runTime,world.BattleResultSystem.resultFrame,useGc)
    end

    --Logf("战斗信息[耗时:%sms][帧数:%s][gc产生:%.2fmb]",runTime,world.BattleResultSystem.resultFrame,useGc)

    if resultFrame and  world.BattleResultSystem.resultFrame ~= resultFrame then
        LogErrorf("本地战斗校验异常[校验帧数:%s][运行帧数:%s]",world.BattleResultSystem.resultFrame,resultFrame)
    end
end



function BattleCheckoutSystem.CheckoutBattle(enterData,frameData,resultData)
    local resultFrame = resultData.frame
    local winCamp = resultData.win_camp
    local roleUid = enterData.role_list[1].role_base.role_uid
    
    local world = BattleCheckoutSystem.CreateBattle(roleUid,enterData,frameData,resultData.conf)
    while world.BattleStateSystem:IsBattleResult(BattleDefine.BattleResult.none) 
        and (not resultFrame or world.frame < resultFrame) do
        world:Update()
    end
    if world.BattleStateSystem.winCamp ~= winCamp then
        print(string.format("本地战斗校验异常[校验帧数:%s][运行帧数:%s]",world.BattleResultSystem.resultFrame,resultFrame))
        return 0
    else
        print(string.format("本地战斗校验成功[校验帧数:%s][运行帧数:%s]",world.BattleResultSystem.resultFrame,resultFrame))
        return 1
    end
end

function BattleCheckoutSystem.CreateCheckoutBattle(enterData)
    local roleUid = enterData.role_list[1].role_base.role_uid
    local world = BattleCheckoutSystem.CreateBattle(roleUid,enterData)
    BattleCheckoutSystem.checkoutWorlds[world.uid] = world
    return world.uid
end

function BattleCheckoutSystem.CheckoutBattleToFrame(uid,toFrame,frameData)
    local world = BattleCheckoutSystem.checkoutWorlds[uid]
    if world then
        if frameData then
            for frame,v in pairs(frameData) do
                for _,opData in ipairs(v) do
                    world.BattleOperationSystem:AddRemoteInput(frame,opData)
                end
            end
        end

        while world.BattleStateSystem:IsBattleResult(BattleDefine.BattleResult.none) 
            and world.frame < toFrame do
            world:Update()
        end
    end
end

function BattleCheckoutSystem.DestroyCheckoutBattle(uid)
    local world = BattleCheckoutSystem.checkoutWorlds[uid]
    if world then
        BattleCheckoutSystem.checkoutWorlds[uid] = nil
    end
end