BattleFrameSyncSystem = BaseClass("BattleFrameSyncSystem",SECBEntitySystem)

function BattleFrameSyncSystem:__Init()
    self.frame = 0
end

function BattleFrameSyncSystem:__Delete()

end

function BattleFrameSyncSystem:OnInitSystem()

end

function BattleFrameSyncSystem:OnLateInitSystem()
    
end

function BattleFrameSyncSystem:RemoteDriverFrame(data)
    if self.frame + 1 ~= data.frame then
        LogErrorf("10402跳帧了[本地同步帧:%s][服务器帧:%s]",self.frame,data.frame)
        --self.BattleProxy:SetRunError(true)
        return
    end

    --self.frameIntervalStopwatch:Stop()
    --local intervalTime = self.frameIntervalStopwatch.Elapsed.TotalMilliseconds
    
    -- if DEBUG_FRAME then
    --     DEBUG_FRAME_NUM = DEBUG_FRAME_NUM + 1
    --     if DEBUG_FRAME_NUM <= 2 then
    --         Log("测试延迟")
    --         return
    --     else
    --         DEBUG_FRAME_NUM = 0
    --     end
    -- end
    
    self.frame = data.frame

    -- for i,v in ipairs(data.frame_op) do
    --     local op = loadstring(string.format("return %s",v.op))()
    --     self.BattleFrameActionCtrl:AddFrameAction(data.frame,op)
    -- end
    
    -- if #data.frame_op > 0 then
    --     LogTable("收到操作",data)
    -- end

    --self.frameIntervalStopwatch:Restart()

    if self.world.checkWorld then
        self.world.checkWorld.BattleFrameSyncSystem:RemoteDriverFrame(data)
    end
end

--断线重连，直接设置到最新帧
function BattleFrameSyncSystem:SetFrame(frame)
    self.frame = frame

    if self.world.checkWorld then
        self.world.checkWorld.BattleFrameSyncSystem:SetFrame(frame)
    end
end


function BattleFrameSyncSystem:SyncRandomHero(data)
    if not self.world.BattleStateSystem.isReconnect and self.frame + 1 ~= data.frame then
        LogErrorf("10404跳帧了[本地同步帧:%s][服务器帧:%s]",self.frame,data.frame)
        --self.BattleProxy:SetRunError(true)
        return
    end

    self.world.BattleOperationSystem:AddRemoteInput(data.frame,{type = BattleDefine.Operation.random_hero,data = data})

    --self.world.ClientIFacdeSystem:Call("RefreshSelectHero",self.world.BattleDataSystem.roleUid,data.update_list)

    if self.world.checkWorld then
        self.world.checkWorld.BattleFrameSyncSystem:SyncRandomHero(data)
    end
end

function BattleFrameSyncSystem:SyncUpdateHero(data)
    if not self.world.BattleStateSystem.isReconnect and self.frame + 1 ~= data.frame then
        LogErrorf("10403跳帧了[本地同步帧:%s][服务器帧:%s]",self.frame,data.frame)
        --self.BattleProxy:SetRunError(true)
        return
    end
    
    self.world.BattleOperationSystem:AddRemoteInput(data.frame,{type = BattleDefine.Operation.update_hero,data = data})

    if self.world.checkWorld then
        self.world.checkWorld.BattleFrameSyncSystem:SyncUpdateHero(data)
    end
end

function BattleFrameSyncSystem:SyncUseMagicCard(data)
    if not self.world.BattleStateSystem.isReconnect and self.frame + 1 ~= data.frame then
        LogErrorf("10424跳帧了[本地同步帧:%s][服务器帧:%s]",self.frame,data.frame)
        --self.BattleProxy:SetRunError(true)
        return
    end

    self.world.BattleOperationSystem:AddRemoteInput(data.frame,{type = BattleDefine.Operation.use_magic_card,data = data})

    if self.world.checkWorld then
        self.world.checkWorld.BattleFrameSyncSystem:SyncUseMagicCard(data)
    end
end

function BattleFrameSyncSystem:SyncUpdateBattleNum(data)
    if not self.world.BattleStateSystem.isReconnect and self.frame + 1 ~= data.frame then
        LogErrorf("10426跳帧了[本地同步帧:%s][服务器帧:%s]",self.frame,data.frame)
        --self.BattleProxy:SetRunError(true)
        return
    end

    self.world.BattleOperationSystem:AddRemoteInput(data.frame,{type = BattleDefine.Operation.update_battle_num,data = data})

    if self.world.checkWorld then
        self.world.checkWorld.BattleFrameSyncSystem:SyncUpdateBattleNum(data)
    end
end