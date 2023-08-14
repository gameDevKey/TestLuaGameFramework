MainuiPanel = BaseClass("MainuiPanel",BasePanel)
MainuiPanel.__adaptiveTop = true

MainuiPanel.Event = EventEnum.New(
    "ActiveMainui",
    "ActiveTopInfo",
    "ActiveBottomTab",
    "ActivePveEnterPanel",
    "ActiveDebugNode",
    "ActiveSceneNode"
)

function MainuiPanel:__Init()
    self:SetViewType(UIDefine.ViewType.panel)
    self:SetAsset("ui/prefab/mainui/mainui_panel.prefab",AssetType.Prefab)
    if IS_DEBUG then
        self:AddAsset(AssetPath.debugNode, AssetType.Prefab)
    end
    self.clickTime = 0
    self.activeStatus = nil
end

function MainuiPanel:__ExtendView()
    self.topInfoPanel = self:ExtendView(MainuiTopInfoPanel)
    self.bottomBtnPanel = self:ExtendView(MainuiBottomBtnPanel)

    self:ExtendView(MainuiAnimEffectView)
    self:ExtendView(MainuiRemindView)
    self:ExtendView(MainuiMoreFuncView)
    self:ExtendView(MainuiModelView)
end

function MainuiPanel:__CacheObject()
    self.mainTrans = self:Find("main")
    self.mainNode = self.mainTrans.gameObject

    self.sceneNode = self:Find("scene")

    self.topInfoNode = self:Find("top_canvas").gameObject
    self.canvasTop = self:Find("top_canvas",Canvas)
    self.rectTopCanvas = self:Find("top_canvas",RectTransform)
    self.bottomTabNode = self:Find("bottom_canvas/img_bg").gameObject
    self.canvasBottom = self:Find("bottom_canvas",Canvas)

    --division
    self.objDivision = self:Find("main/division_func").gameObject
    self.txtTrophy = self:Find("main/division_func/txt_trophy",Text)
    -- self.txtBattleCount = self:Find("main/division_func/txt_battle_count",Text)
    -- self.txtWinrate = self:Find("main/division_func/txt_winrate",Text)
    self.rectDivisionPgr = self:Find("main/division_func/img_pgr_bg/img_pgr",RectTransform)
    self.rectDivisionSize = self.rectDivisionPgr.sizeDelta
    self.txtCmderLv = self:Find("main/division_func/image_52/txt_cmder_lv",Text)
    self.btnDivision = self:Find("main/division_func",Button)

    --battlepass
    self.objBattlepass = self:Find("main/battlepass_func").gameObject
    self.imgBattlepass = self:Find("main/battlepass_func",Image)
    self.txtBattlepass = self:Find("main/battlepass_func/txt_score",Text)
    self.btnBattlepass = self:Find("main/battlepass_func",Button)
    self.rectBattlepassPgr = self:Find("main/battlepass_func/img_pgr_bg/img_pgr",RectTransform)
    self.rectBattlepassSize = self.rectBattlepassPgr.sizeDelta

    --drawcard
    self.imgDrawCard = self:Find("main/draw_card_btn",Image)
    self.btnDarwCard = self:Find("main/draw_card_btn",Button)

    --dailyTask
    self.imgDailyTask = self:Find("main/daily_task_btn",Image)
    self.dailyTaskBtn = self:Find("main/daily_task_btn",Button)

    self.btnPvp = self:Find("main/enter_battle_btn",Button)
    -- self.btnPve = self:Find("main/enter_pve_btn",Button)
    -- self.imgPve = self:Find("main/enter_pve_btn",Image)

    self.btnFriend = self:Find("main/friend_btn",Button)

    self.btnMoreFunc = self:Find("main/more_func_btn",Button)

    if IS_DEBUG then
        self.debugNode = self:GetAsset(AssetPath.debugNode)
        self.debugNode:SetActive(false)
        self.debugNode.transform:SetParent(self.mainTrans)
        self.debugNode.transform:Reset()
        UnityUtils.SetAnchoredPosition(self.debugNode:GetComponent(RectTransform),0,-241)
        self.btnDebugBattle = self.debugNode.transform:Find("debug_battle_btn"):GetComponent(Button)
        self.btnDebugReplay = self.debugNode.transform:Find("debug_replay_btn"):GetComponent(Button)
        self.inputDebugBattle = self.debugNode.transform:Find("debug_battle_input"):GetComponent(InputField)
        self.inputDebugReplay = self.debugNode.transform:Find("debug_replay_input"):GetComponent(InputField)
    end
end

function MainuiPanel:__BindListener()
    self.btnFriend:SetClick( self:ToFunc("EnterFriendPanel") )
    self.btnPvp:SetClick(self:ToFunc("SelectBattleMode"))
    -- self.btnPve:SetClick(self:ToFunc("ShowPveEnterPanel"))
    self.btnDivision:SetClick(self:ToFunc("OpenDivisionWindow"))
    self.btnBattlepass:SetClick(self:ToFunc("OnBattlepassBtnClick"))
    self.btnDarwCard:SetClick(self:ToFunc("OnDrawCardBtnClick"))
    self.dailyTaskBtn:SetClick(self:ToFunc("OnDailyTaskBtnClick"))
    self.btnMoreFunc:SetClick(self:ToFunc("OnMoreFuncBtnClick"))
    if IS_DEBUG then
        self.btnDebugBattle:SetClick(self:ToFunc("DebugEnterBattle"))
        self.btnDebugReplay:SetClick(self:ToFunc("DebugReplayBattle"))
    end
end

function MainuiPanel:__BindEvent()
    self:BindBeforeEvent(MainuiPanel.Event.ActiveMainui)
    self:BindBeforeEvent(MainuiPanel.Event.ActiveTopInfo)
    self:BindBeforeEvent(MainuiPanel.Event.ActiveBottomTab)
    self:BindEvent(MainuiPanel.Event.ActivePveEnterPanel)
    self:BindEvent(MainuiPanel.Event.ActiveDebugNode)
    self:BindEvent(MainuiPanel.Event.ActiveSceneNode)
end

function MainuiPanel:__Create()
    self:SetOrder()
    self.canvasTop.sortingOrder = ViewDefine.Layer["MainuiPanel_Top_Bottom"]
    self.canvasBottom.sortingOrder = ViewDefine.Layer["MainuiPanel_Top_Bottom"]
    ViewManager.Instance:Adaptive(self.rectTopCanvas,true,false)
end

function MainuiPanel:__Show()
    self:RefreshAll()
end

function MainuiPanel:__LastShow()
    EventManager.Instance:SendEvent(EventDefine.enter_mainui)
    EventManager.Instance:SendEvent(EventDefine.active_mainui)
    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_open, "mainui")
    self:ActiveMainui(true)
end

function MainuiPanel:__Hide()
    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_close, "mainui")
end

function MainuiPanel:ActiveMainui(flag)
    if not self:Active() then
        return
    end
    if self.activeStatus == nil or self.activeStatus ~= flag then
        self.activeStatus = flag
        self:SetActive(self.mainNode,flag)
        self:ActiveSceneNode(flag)

        if flag then
            self:RefreshAll()
        else
            self:HidePanels()
        end
        EventManager.Instance:SendEvent(EventDefine.on_mainui_active, self.activeStatus)
    end

    if flag and not ViewManager.Instance:HasView() then
        mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_open, "mainui")
        EventManager.Instance:SendEvent(EventDefine.active_mainui)
    end
end

function MainuiPanel:ActiveSceneNode(active)
    self:SetActive(self.sceneNode,active)
    mod.MainuiFacade:SendEvent(MainuiModelView.Event.ActiveCamera,active)
end

function MainuiPanel:RefreshAll()
    self:RefreshDivison()
    self:RefreshBattlepass()
    UIUtils.Grey(self.imgDrawCard, not mod.OpenFuncProxy:IsFuncUnlock(GDefine.FuncUnlockId.DrawCard))
    UIUtils.Grey(self.imgDailyTask, not mod.OpenFuncProxy:IsFuncUnlock(GDefine.FuncUnlockId.DailyTask))
    -- UIUtils.Grey(self.imgPve, not mod.OpenFuncProxy:IsFuncUnlock(GDefine.FuncUnlockId.Pve))
    if IS_DEBUG then
        local open = PlayerPrefsEx.GetInt("ACTIVE_DEBUG_NODE",0)
        self:ActiveDebugNode(open == 1)
    end
end

function MainuiPanel:HidePanels()
    if self.battleModePanel then
        self.battleModePanel:Hide()
    end
    if self.pveEnterPanel then
        self.pveEnterPanel:Hide()
    end
end

function MainuiPanel:ActiveTopInfo(flag,bebind)
    if self.topInfoNode.activeSelf ~= flag then
        self:SetActive(self.topInfoNode,flag)
        if flag then
            EventManager.Instance:SendEvent(EventDefine.active_mainui_top)
        end
    end
    if flag then
        if bebind then
            self.canvasTop.sortingOrder = ViewManager.Instance:GetCurWinLayer() - 1
        else
            self.canvasTop.sortingOrder = ViewDefine.Layer["MainuiPanel_Top_Bottom"]
        end
    end
end

function MainuiPanel:ActiveBottomTab(flag,bebind)
    if self.bottomTabNode.activeSelf ~= flag then
        self:SetActive(self.bottomTabNode,flag)
        if flag then
            EventManager.Instance:SendEvent(EventDefine.active_mainui_bottom)
        end
    end
    if flag then
        if bebind then
            self.canvasBottom.sortingOrder = ViewManager.Instance:GetCurWinLayer() - 1
        else
            self.canvasBottom.sortingOrder = ViewDefine.Layer["MainuiPanel_Top_Bottom"]
        end
    end
end

function MainuiPanel:InitRefresh()
    if not mod.RoleProxy:ExistData() then return end
end

function MainuiPanel:SelectBattleMode()
    if not self.battleModePanel then
        self.battleModePanel = BattleModePanel.New()
        self.battleModePanel:SetParent(self.transform)
    end
    self.battleModePanel:Show()
end

function MainuiPanel:EnterBattle()
    --mod.BattleFacade:SendMsg(10210)
    mod.BattleFacade:SendMsg(10400,"1","1")
    --mod.BattleCtrl:EnterPK({})
end

function MainuiPanel:DebugEnterBattle()
    if not IS_DEBUG then
        return
    end
    local testId = self.inputDebugBattle.text
    if testId == "" then
        SystemMessage.Show("请输入排位Id")
    else
        mod.BattleFacade:SendMsg(10417,tonumber(testId))
        ViewManager.Instance:OpenWindow(MatchingWindow)
    end
end

function MainuiPanel:DebugReplayBattle()
    if not IS_DEBUG then
        return
    end
    local file = self.inputDebugReplay.text
    if file == "" then
        SystemMessage.Show("请输入回放文件")
    else
        mod.BattleCtrl:EnterDebugReplay(file)
    end
end

-- function MainuiPanel:RefreshLayout()
--     local curLayout = mod.MainProxy.curLayout
--     if curLayout == MainDefine.Layout.default then
--         self:Find("battle_btn").gameObject:SetActive(true)
--         self:Find("up_ride_btn").gameObject:SetActive(true)
--         self:Find("trace_node").gameObject:SetActive(true)
--         self:Find("top_btns").gameObject:SetActive(true)
--     elseif curLayout == MainDefine.Layout.hook then
--         self:Find("battle_btn").gameObject:SetActive(false)
--         self:Find("up_ride_btn").gameObject:SetActive(false)
--         self:Find("trace_node").gameObject:SetActive(false)
--         self:Find("top_btns").gameObject:SetActive(false)
--     end
-- end

function MainuiPanel:RefreshDivison()
    local playerDivision = mod.DivisionProxy:GetPlayerDivision()
    local playerTrophy = mod.DivisionProxy:GetPlayerTrophy()
    local playerData = mod.RoleProxy.roleData

    local progress = mod.DivisionProxy:CalcTrophyProgress(playerDivision)
    local width = self.rectDivisionSize.x * progress
    UnityUtils.SetSizeDelata(self.rectDivisionPgr,width,self.rectDivisionSize.y)

    self.txtTrophy.text = playerTrophy
    -- self.txtBattleCount.text = playerData.battle_count
    -- self.txtWinrate.text = UIUtils.GetWinrateText(playerData.win_count,playerData.battle_count)
end

function MainuiPanel:RefreshBattlepass()
    if not mod.OpenFuncProxy:IsFuncUnlock(GDefine.FuncUnlockId.Battlepass) then
        self.txtBattlepass.text = ""
        UIUtils.Grey(self.imgBattlepass,true)
        UnityUtils.SetSizeDelata(self.rectBattlepassPgr,0,self.rectBattlepassSize.y)
        return
    end
    UIUtils.Grey(self.imgBattlepass,false)
    local data = mod.BattlepassProxy:GetAllData()
    local lv = data.level
    local exp = data.exp
    local seasonId = data.season_id
    local dailyGet = data.day_exp
    local conf = mod.BattlepassProxy:GetInfoConfig(seasonId,lv)
    local nextExp = conf.need_exp

    local width = self.rectBattlepassSize.x
    local height = self.rectBattlepassSize.y
    local progress = 1
    if nextExp > 0 then
        progress = exp / nextExp
    end
    width = width * progress
    UnityUtils.SetSizeDelata(self.rectBattlepassPgr,width,height)

    self.txtBattlepass.text = string.format("%d/%d",exp,nextExp)
end

function MainuiPanel:OpenDivisionWindow()
    ViewManager.Instance:OpenWindow(RankWindow)
end

function MainuiPanel:EnterChatPanel()
    SystemMessage.Show(TI18N("聊天功能开发中…"))
end

function MainuiPanel:EnterFriendPanel()
    -- SystemMessage.Show(TI18N("好友功能开发中…"))

    mod.FriendCtrl:OpenFriend()
end

function MainuiPanel:ActivePveEnterPanel(active)
    -- if active then
    --     self:ShowPveEnterPanel()
    -- else
    --     if self.pveEnterPanel then
    --         self.pveEnterPanel:Hide()
    --     end
    -- end
end

function MainuiPanel:ActiveDebugNode(active)
    if self.debugNode then
        self.debugNode:SetActive(active)
    end
end

function MainuiPanel:ShowPveEnterPanel()
    -- if not mod.OpenFuncProxy:JudgeFuncUnlockAndMsg(GDefine.FuncUnlockId.Pve) then
    --     return
    -- end
    -- if not self.pveEnterPanel then
    --     self.pveEnterPanel = PveEnterPanel.New()
    --     self.pveEnterPanel:SetParent(self.transform)
    -- end
    -- self.pveEnterPanel:Show()
end

function MainuiPanel:OnDrawCardBtnClick()
    if not mod.OpenFuncProxy:JudgeFuncUnlockAndMsg(GDefine.FuncUnlockId.DrawCard) then
        return
    end
    ViewManager.Instance:OpenWindow(DrawCardWindow)
end

function MainuiPanel:OnBattlepassBtnClick()
    if not mod.OpenFuncProxy:JudgeFuncUnlockAndMsg(GDefine.FuncUnlockId.Battlepass) then
        return
    end
    ViewManager.Instance:OpenWindow(BattlepassWindow)
end

function MainuiPanel:OnDailyTaskBtnClick()
    if not mod.OpenFuncProxy:JudgeFuncUnlockAndMsg(GDefine.FuncUnlockId.DailyTask) then
        return
    end
    ViewManager.Instance:OpenWindow(DailyTaskWindow)
end

function MainuiPanel:OnMoreFuncBtnClick()
    mod.MainuiFacade:SendEvent(MainuiMoreFuncView.Event.ActiveMoreFuncView, true)
end