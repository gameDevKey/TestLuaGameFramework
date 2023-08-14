BattleProxy = BaseClass("BattleProxy",Proxy)

function BattleProxy:__Init()
    self.worlds = {}
    RunWorld = nil

    self.readyEnterData = nil
end

function BattleProxy:__InitProxy()
    self:BindMsg(10400) --匹配成功
    self:BindMsg(10401,true) --客户端加载完成


    self:BindMsg(10402) --帧驱动包
    self:BindMsg(10403) --更新英雄格子
    self:BindMsg(10404) --更新随机单位列表
    

    self:BindMsg(10405) --随机单位
    self:BindMsg(10406) --选择单位
    self:BindMsg(10407) --扩展格子
    self:BindMsg(10408) --交换英雄
    self:BindMsg(10409) --出售英雄
    self:BindMsg(10426) --扩展上阵数量

    self:BindMsg(10410) --排位赛结束

    self:BindMsg(10411) --投降

    self:BindMsg(10416) --取消匹配
    self:BindMsg(10417) --排位赛结束


    --重连
    self:BindMsg(10418) --开始重连
    self:BindMsg(10419) --完成重连



    self:BindMsg(10413) --拖放魔法卡
    self:BindMsg(10424) --魔法卡帧数据

    self:BindMsg(10414) --通知成功加入匹配


    self:BindMsg(10450) --战斗校验错误信息
end

function BattleProxy:AddWorld(world)
    self.worlds[world.uid] = world
end

function BattleProxy:RemoveWorld(uid)
    self.worlds[uid] = nil
end

function BattleProxy:SetRunWorld(world)
    RunWorld = world
end

function BattleProxy:GetEntity(uid)
    return RunWorld.EntitySystem:GetEntity(uid)
end

function BattleProxy:SetReadyEnterData(data)
    self.readyEnterData = data
end

function BattleProxy:Send_10400(coreVersion,confVersion)
    local data = {}
    data.core_version = coreVersion
    data.conf_version = confVersion
    LogTable("发送10400",data)
    return data
end

--匹配成功
function BattleProxy:Recv_10400(data)
    LogTable("接收10400",data)
    for i,v in ipairs(data.role_list) do
        LogTable("角色信息:"..v.role_base.role_uid,v)
    end
    self:SetReadyEnterData(data)

    --mod.BattleFacade:SendEvent(MatchingWindow.Event.MatchingSucceed,data)
    --ViewManager.Instance:OpenWindow(BattleLoadWindow)
    mod.BattleCtrl:EnterPK(data)
end

function BattleProxy:Recv_10402(data)
    --LogTable("接受10402",data)
    if RunWorld then
        RunWorld.BattleFrameSyncSystem:RemoteDriverFrame(data)
    end
end

function BattleProxy:Recv_10403(data)
    LogTable("接受10403",data)
    if RunWorld then
        RunWorld.BattleFrameSyncSystem:SyncUpdateHero(data)
    end
end

function BattleProxy:Recv_10404(data)
    LogTable("接受10404",data)
    if RunWorld then
        -- for _,v in ipairs(data.update_list) do
        --     for i=1,#v.choose_unit_list do 
        --         v.choose_unit_list[i] = 5003
        --     end
        -- end
        RunWorld.BattleFrameSyncSystem:SyncRandomHero(data)
    end
end

function BattleProxy:Recv_10302(data)
    LogTable("接收10302",data)
    if RunWorld then
        RunWorld.BattleBroadcastSystem:SkillHit(data)
    end
end


--随机单位
function BattleProxy:Send_10405(opIndex)
    local data = {}
    data.operate_num = opIndex
    LogTable("发送10405",data)
    return data
end

function BattleProxy:Recv_10405(data)
    LogTable("接收10405",data)
    if RunWorld then
        --RunWorld.BattleInputSystem:UnlockOp(data.operate_num)
    end
end

--选择单位
function BattleProxy:Send_10406(opIndex,unitId)
    local data = {}
    data.operate_num = opIndex
    data.unit_id = unitId
    LogTable("发送10406",data)
    return data
end

function BattleProxy:Recv_10406(data)
    LogTable("接收10406",data)
    if RunWorld then
        --RunWorld.BattleInputSystem:UnlockOp(data.operate_num)
    end
end

--扩展格子
function BattleProxy:Send_10407(opIndex,grid)
    local data = {}
    data.operate_num = opIndex
    data.grid_id = grid
    LogTable("发送10407",data)
    return data
end

function BattleProxy:Recv_10407(data)
    LogTable("接收10407",data)
    if RunWorld then
        --RunWorld.BattleInputSystem:UnlockOp(data.operate_num)
    end
end


--交换英雄
function BattleProxy:Send_10408(opIndex,fromGrid,toGrid)
    local data = {}
    data.operate_num = opIndex
    data.grid_id_from = fromGrid
    data.grid_id_to = toGrid
    LogTable("发送10408",data)
    return data
end

function BattleProxy:Recv_10408(data)
    LogTable("接收10408",data)
    if RunWorld then
        --RunWorld.BattleInputSystem:UnlockOp(data.operate_num)
    end
end


--出售英雄
function BattleProxy:Send_10409(opIndex,grid)
    local data = {}
    data.operate_num = opIndex
    data.grid_id = grid
    LogTable("发送10409",data)
    return data
end

function BattleProxy:Recv_10409(data)
    LogTable("接收10409",data)
    if RunWorld then
        --RunWorld.BattleInputSystem:UnlockOp(data.operate_num)
    end
end

--排位赛结束
function BattleProxy:Send_10410(camp,frame,coreVersion,confVersion,customArgs)
    local data = {}
    data.win_camp = camp
    data.frame = frame
    data.core_version = coreVersion
    data.conf_version = confVersion
    data.custom_args = customArgs
    LogTable("发送10410",data)
    return data
end

---战斗结算
---@param data any
function BattleProxy:Recv_10410(data)
    LogTable("接收10410",data)
    if RunWorld then
        RunWorld.BattleResultSystem:ReturnResult(data)
        --mod.BattleCtrl:ExitBattle(RunWorld)
    end
end

function BattleProxy:Send_10411()
    local data = {}
    LogTable("发送10411",data)
    return data
end

function BattleProxy:Recv_10411(data)

end

--通知成功加入匹配
function BattleProxy:Recv_10414(data)
    LogTable("接收10414",data)
    ViewManager.Instance:OpenWindow(MatchingWindow)
end


--排位赛结束
function BattleProxy:Send_10417(id)
    local data = {}
    data.qualifying_cfg_id = id
    LogTable("发送10417",data)
    return data
end


--开始重连
function BattleProxy:Send_10418(frame)
    local data = {}
    data.frame = frame
    LogTable("发送10418",data)
    return data
end

function BattleProxy:Recv_10418(data)
    LogTable("接收10418",data)
    if not RunWorld then
        return
    end

    if RunWorld.BattleStateSystem.localRun then
        return
    end

    if data.server_frame < RunWorld.BattleFrameSyncSystem.frame then
		LogErrorf("服务器发来倒退的帧数[本地:%s][服务器:%s]",RunWorld.BattleFrameSyncSystem.frame,data.server_frame)
		--self.BattleProxy:SetRunError(true)
		return
	elseif data.server_frame == RunWorld.BattleFrameSyncSystem.frame then
		self:SendMsg(10419,RunWorld.BattleFrameSyncSystem.frame)
		return
	end

    
    RunWorld.BattleStateSystem:SetReconnect(true)

	if data.server_frame - RunWorld.BattleFrameSyncSystem.frame >= 60 then
        RunWorld.BattleStateSystem:SetAgainCheckReconnect(true)
		self.isContinueReconnect = true
	end

    RunWorld.BattleFrameSyncSystem:SetFrame(data.server_frame)

    local opList = {}
    for i,v in ipairs(data.choose_frams) do
        table.insert(opList,{type = BattleDefine.Operation.random_hero,data = v})
    end
    for i,v in ipairs(data.grid_frames) do
        table.insert(opList,{type = BattleDefine.Operation.update_hero,data = v})
    end
    for i,v in ipairs(data.drag_magic_frams) do
        table.insert(opList,{type = BattleDefine.Operation.use_magic_card,data = v})
    end
    for i,v in ipairs(data.embattle_frams) do
        table.insert(opList,{type = BattleDefine.Operation.update_battle_num,data = v})
    end

    table.sort(opList,self:ToFunc("SortOpRun"))
    LogTable("重连Op",opList)

    for i,v in ipairs(opList) do
        if v.type == BattleDefine.Operation.random_hero then
            RunWorld.BattleFrameSyncSystem:SyncRandomHero(v.data)
        elseif v.type == BattleDefine.Operation.update_hero then
            RunWorld.BattleFrameSyncSystem:SyncUpdateHero(v.data)
        elseif v.type == BattleDefine.Operation.use_magic_card then
            RunWorld.BattleFrameSyncSystem:SyncUseMagicCard(data)
        elseif v.type == BattleDefine.Operation.update_battle_num then
            RunWorld.BattleFrameSyncSystem:SyncUpdateBattleNum(data)
        end
    end
end

function BattleProxy:SortOpRun(a,b)
    local aData = a.data.update_list[1] or a.data.frame_list[1]
    local bData = b.data.update_list[1] or b.data.frame_list[1]
    return aData.operate_uid > bData.operate_uid
end

function BattleProxy:Send_10419(frame)
    local data = {}
    data.frame = frame
    LogTable("发送10419",data)
    return data
end

function BattleProxy:Recv_10419(data)
    LogTable("接收10419",data)

    if RunWorld then
        RunWorld.BattleInputSystem:CleanOp()
    end
end


function BattleProxy:Send_10413(opIndex,unitId,opData)
    local data = {}
    data.operate_num = opIndex
    data.unit_id = unitId
    data.data = opData
    LogTable("发送10413",data)
    return data
end

function BattleProxy:Recv_10413(data)
    LogTable("接收10413",data)
end

function BattleProxy:Recv_10424(data)
    LogTable("接收10424",data)
    if RunWorld then
        RunWorld.BattleFrameSyncSystem:SyncUseMagicCard(data)
    end
end

function BattleProxy:Recv_10426(data)
    LogTable("接收10426",data)
    if RunWorld then
        RunWorld.BattleFrameSyncSystem:SyncUpdateBattleNum(data)
    end
end

function BattleProxy:Recv_10450(data)
    LogTable("接收10450",data)
end