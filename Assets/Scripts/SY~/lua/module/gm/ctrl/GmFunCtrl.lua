GmFunCtrl = BaseClass("GmFunCtrl",Controller)
--GM拓展命令，在Xml中写入回调方法名，重新生成,即可调用
function GmFunCtrl:__Init()
    self.lastScreenWidth = 0
    self.lastScreenHeight = 0
end

function GmFunCtrl:DebugGuide(args)
    LogTable("调试引导",args)
    mod.PlayerGuideCtrl:DebugGuideGroup(tonumber(args[1]))
end

function GmFunCtrl:OpenDashboardWindow(args)
    LogTable("打开仪表盘窗口",args)
    ViewManager.Instance:OpenWindow(DashboardWindow)
end

function GmFunCtrl:PreviewAdaptive()
    DEBUG_PreviewAdaptive = not DEBUG_PreviewAdaptive
    if DEBUG_PreviewAdaptive then
        self.lastScreenWidth = Screen.width
        self.lastScreenHeight = Screen.height

        local ratio = 720 / 1600
        Log("jinru1",self.lastScreenHeight * ratio,self.lastScreenHeight)
        Screen.SetResolution(self.lastScreenHeight * ratio,self.lastScreenHeight,false)
    else
        Log("jinru2",self.lastScreenWidth,self.lastScreenHeight)
        Screen.SetResolution(self.lastScreenWidth,self.lastScreenHeight,false)
    end
end


function GmFunCtrl:BattleWin()
    if RunWorld then
        RunWorld.BattleResultSystem:OverResult(BattleDefine.BattleResult.win)
        ViewManager.Instance:CloseWindow(GmWindow)
    end
end

function GmFunCtrl:BattleLose()
    if RunWorld then
        RunWorld.BattleResultSystem:OverResult(BattleDefine.BattleResult.lose)
        ViewManager.Instance:CloseWindow(GmWindow)
    end
end

function GmFunCtrl:FixRankWindow()
    local win = ViewManager.Instance:GetWindow(RankWindow.__className)
    if not win then
        LogError("界面不存在")
        return
    end
    local sv = win.loopScrollView
    if not sv then
        LogError("无限滚动组件不存在")
        return
    end
    print("数据量",#sv:GetAllData())
    print("正在显示数量",sv:GetShowingItemAmount())
    print("content位置",sv.content.transform.localPosition)
end

function GmFunCtrl:ShowPlayerGuide()
    local infos ={}
    for i,v in ipairs(mod.PlayerGuideProxy.guideActions) do
        local flag = v.guideTimeline ~= nil
        if flag then
            table.insert(infos,string.format("[引导Id:%s][Lua运行状态:%s]",v.guideId,tostring(flag)))
        end
    end
    LogTableInfo("新手引导信息",infos)
end

function GmFunCtrl:EnterPVE()
    mod.BattleFacade:SendMsg(10900)
end

local function GetNextGroup(group)
    local list = Config.PlayerGuideData.data_guide_group_info[group]
    local lastId = list[#list]
    local info = Config.PlayerGuideData.data_guide_info[lastId]
    local nextId = info.next_id and info.next_id[1]
    local nextInfo = nextId and Config.PlayerGuideData.data_guide_info[nextId]
    return nextInfo and nextInfo.group
end

function GmFunCtrl:QuickFinishGuide(args)
    local groupId = tonumber(args[1])
    local currentGroup = mod.PlayerGuideCtrl.firstGuideGroupId
    while currentGroup > 0 do
        LogYqh("快速完成引导",currentGroup)
        mod.PlayerGuideFacade:SendMsg(10701,currentGroup)
        if groupId == currentGroup then
            break
        end
        currentGroup = GetNextGroup(currentGroup)
    end
    if currentGroup and currentGroup > 0 then
        mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.RemoveAllChildView)
        mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.LockScreen,false)
        mod.BattlePreInitCtrl:SetMaskCameraActive(false)
        mod.BattlePreInitCtrl:SetMaskPanelActive(false)
        mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.ShowMask,false)
        mod.PlayerGuideProxy.guideActions = {}
        currentGroup = GetNextGroup(currentGroup)
        local list = Config.PlayerGuideData.data_guide_group_info[currentGroup]
        if list then
            mod.PlayerGuideCtrl:BeginGuide(list[1])
        end
    end
end


function GmFunCtrl:DebugNetworkDisconnect()
    Network.Instance:Disconnect()
end

function GmFunCtrl:AutoExecGuide()
    ViewManager.Instance:CloseWindow(GmWindow)
    PlayerGuideDefine.AutoExecMode = not PlayerGuideDefine.AutoExecMode
    Log("自动执行引导:",tostring(PlayerGuideDefine.AutoExecMode))
end

function GmFunCtrl:ExitLogin()
   GameManager.Instance:ExitLogin()
   Log("退出登录")
end

function GmFunCtrl:DebugBattleTime()
    DEBUG_BATTLE_TIME = not DEBUG_BATTLE_TIME
    Log("调试战斗时间")
end

function GmFunCtrl:ActiveBattleEffect()
    if DEBUG_ACTIVE_EFFECT == nil then
        DEBUG_ACTIVE_EFFECT = true
    end
    DEBUG_ACTIVE_EFFECT = not DEBUG_ACTIVE_EFFECT
    Log("开关战斗特效",tostring(DEBUG_ACTIVE_EFFECT))
end

function GmFunCtrl:BattleTest()
    BattleTest.Test(true)
    Log("战斗测试")
end

function GmFunCtrl:SaveBattleData()
    SAVE_BATTLE_DATA = not SAVE_BATTLE_DATA
    Log("保存本场战斗数据",tostring(SAVE_BATTLE_DATA))
end

function GmFunCtrl:OpenBattleDebugPanel()
    local open = PlayerPrefsEx.GetInt("ACTIVE_DEBUG_NODE",0)
    local curOpen = open == 0 and 1 or 0
    PlayerPrefsEx.SetInt("ACTIVE_DEBUG_NODE",curOpen)
    mod.MainuiFacade:SendEvent(MainuiPanel.Event.ActiveDebugNode,curOpen == 1)
end

function GmFunCtrl:LogAllHeroBuff()
    if not RunWorld then
        return
    end
    --检查Buff
    for v in RunWorld.EntitySystem.entityList:Items() do
        local entityUid = v.value
        local entity = RunWorld.EntitySystem:GetEntity(entityUid)
        if entity and entity.TagComponent.mainTag == BattleDefine.EntityTag.hero then
            for iter in entity.BuffComponent.buffList:Items() do
                local buff = entity.BuffComponent.buffs[iter.value]
                Log(string.format("英雄[%s]拥有Buff[ID:%s Name:%s],来源是[UID:%s],持续[%s/%s],执行次数[%s/%s]",
                    entity.uid,
                    tostring(buff.conf.id),
                    tostring(buff.conf.name),
                    tostring(buff.fromEntityUid),
                    tostring(buff.duration), tostring(buff.conf.duration),
                    tostring(buff.execNum), tostring(buff.conf.max_num)
                ))
            end
        end
    end
end