PlayerGuideDefine = StaticClass("PlayerGuideDefine")

PlayerGuideDefine.GuideTimeline =
{
    battle_pause = "BattlePause",

    bubble_msg = "BubbleMsg",

    img_bubble_msg = "ImageBubbleMsg",

    role_dialogue = "RoleDialogue",

    lock_screen = "LockScreen",

    screen_any_click = "ScreenAnyClick",

    click_obj = "ClickObj",

    begin_group_finish = "BeginGroupFinish",

    capture_bridge_bubble_msg = "CaptureBridgeBubbleMsg",

    add_money = "AddMoney",

    click_random_unit = "ClickRandomUnit",

    click_unlock_grid = "ClickUnlockGrid",

    role_to_money = "RoleToMoney",

    any_click_bubble_msg = "AnyClickBubbleMsg",

    click_open_unit_tips = "ClickOpenUnitTips",

    close_battle_unit_tips = "CloseBattleUnitTips",

    drag_use_magic_card = "DragUseMagicCard",

    show_restrain_view = "ShowRestrainView",

    swap_unit_grid = "SwapUnitGrid",

    add_rage = "AddRage",

    drag_use_rage_skill = "DragUseRageSkill",

    drag_use_pve_skill = "DragUsePveSkill",

    trigger_guide = "TriggerGuide",

    play_ui_effect = "PlayUIEffect",

    play_scene_effect = "PlaySceneEffect",

    open_select_tips = "OpenSelectTips",

    add_unit_star = "AddUnitStar",

    scale_anim = "PlayScaleAnim",

    open_view = "OpenView",

    log_for_debug = "LogForDebug", --仅测试用

    scroll_to = "ScrollTo",

    highlight = "Highlight",

    hole_mask = "ShowHoleMask",

    reset_pvp_battle_state = "ResetPvpBattleState",

    pause_pve_auto_select = "PausePveAutoSelectLogic",

    change_reserve_index = "ChangeReserveIndex",

    pause_pvp_result_win_popup = "PausePvpResultWindowPopup",
    resume_pvp_result_win_popup = "ResumePvpResultWindowPopup",

    enable_sale_card = "EnableSaleCardLogic",
    enable_surrender = "EnableSurrender",
}

-- PlayerGuideDefine.GuideTriggerIndex =
-- {
--     --["进入战斗"] = "OpenUITrigger"
-- }

PlayerGuideDefine.TargetPosFinder =
{
    ["统领位置"] = "CommanderPosFinder",
    ["场景UI"] = "SceneUIFinder",
    ["场景物体"] = "SceneObjFinder",
    ["随机单位"] = "RandomUnitPosFinder",
    ["UI"] = "UINodePosFinder",
    ["固定位置"] = "FixedPosFinder",
    ["动态UI"] = "DynamicUINodeFinder",
}


PlayerGuideDefine.GuideType =
{
    bubble = 1,
    delay = 2,
    effect = 3,
    mask = 4,
}

PlayerGuideDefine.contentTrans = nil


PlayerGuideDefine.Event =
{
    enter_battle = "EnterBattle",
    random_unit = "RandomUnit",
    begin_group = "BeginGroup",
    capture_bridge = "CaptureBridge",
    role_update_money = "RoleUpdateMoney",
    unlock_grid = "UnlockGrid",
    open_unit_tips = "OpenUnitTips",
    use_magic_card = "UseMagicCard",
    commander_up_star = "CommanderUpStar",
    kill_unit = "KillUnit",
    swap_unit_grid = "SwapUnitGrid",
    refresh_place_unit = "RefreshPlaceUnit",

    use_rage_skill = "UseRageSkill",

    trigger_guide = "TriggerGuide",

    unit_up_star = "UnitUpStar",

    on_round_begin = "OnRoundBegin",

    on_view_open = "OnViewOpen",

    on_view_close = "OnViewClose",

    on_card_config = "OnCardConfig",

    on_division_change = "OnDivisionChange",

    on_division_reach = "OnDivisionReach",

    on_division_reward_uncliamed = "OnDivisionRewardUncliamed",

    on_pvp_win = "OnPVPWin",

    on_pve_win = "OnPVEWin",

    on_pve_group_begin = "OnPveGroupBegin",

    enter_target_pvp = "EnterTargetPVP",

    enter_target_pve = "EnterTargetPVE",

    on_commander_die = "OnCommanderDie",

    use_pve_skill = "UsePveSkill",

    on_func_unlock = "OnFuncUnlock",

    on_func_already_unlock = "OnFuncAlreadyUnlock",
}

--触发器映射类
PlayerGuideDefine.GuideTriggerIndex = 
{
	["进入战斗"] = "GuideEventTrigger",
    ["随机单位"] = "GuideEventTrigger",
    ["占桥"] = "GuideEventTrigger",
    ["解锁格子"] = "GuideEventTrigger",
    ["统领升星"] = "GuideEventTrigger",
    ["刷新放置单位"] = "GuideEventTrigger",
    ["单位升星"] = "GuideEventTrigger",
    ["回合开始"] = "GuideEventTrigger",
    ["打开界面"] = "GuideEventTrigger",
    ["关闭界面"] = "GuideEventTrigger",
    ["手牌刷新"] = "GuideEventTrigger",
    ["段位变化"] = "GuideEventTrigger",
    ["段位到达"] = "GuideEventTrigger",
    ["段位奖励可领"] = "GuideEventTrigger",
    ["PVP胜利"] = "GuideEventTrigger",
    ["PVE胜利"] = "GuideEventTrigger",
    ["PVE回合开始"] = "GuideEventTrigger",
    ["进入特定PVP"] = "GuideEventTrigger",
    ["进入特定PVE"] = "GuideEventTrigger",
    ["统帅死亡"] = "GuideEventTrigger",
    ["使用PVE技能"] = "GuideEventTrigger",

    ["功能解锁"] = "OpenFuncTrigger",

    ["击杀单位"] = "GuideKillUnitEventTrigger",
}

--触发器映射事件
PlayerGuideDefine.BattleTriggerEventIndex =
{
	["进入战斗"] = PlayerGuideDefine.Event.enter_battle,
    ["随机单位"] = PlayerGuideDefine.Event.random_unit,
    ["占桥"] = PlayerGuideDefine.Event.capture_bridge,
    ["解锁格子"] = PlayerGuideDefine.Event.unlock_grid,
    ["统领升星"] = PlayerGuideDefine.Event.commander_up_star,
    ["刷新放置单位"] = PlayerGuideDefine.Event.refresh_place_unit,
    ["单位升星"] = PlayerGuideDefine.Event.unit_up_star,
    ["回合开始"] = PlayerGuideDefine.Event.on_round_begin,
    ["打开界面"] = PlayerGuideDefine.Event.on_view_open,
    ["关闭界面"] = PlayerGuideDefine.Event.on_view_close,
    ["手牌刷新"] = PlayerGuideDefine.Event.on_card_config,
    ["段位变化"] = PlayerGuideDefine.Event.on_division_change,
    ["段位到达"] = PlayerGuideDefine.Event.on_division_reach,
    ["段位奖励可领"] = PlayerGuideDefine.Event.on_division_reward_uncliamed,
    ["PVP胜利"] = PlayerGuideDefine.Event.on_pvp_win,
    ["PVE胜利"] = PlayerGuideDefine.Event.on_pve_win,
    ["PVE回合开始"] = PlayerGuideDefine.Event.on_pve_group_begin,
    ["进入特定PVP"] = PlayerGuideDefine.Event.enter_target_pvp,
    ["进入特定PVE"] = PlayerGuideDefine.Event.enter_target_pve,
    ["统帅死亡"] = PlayerGuideDefine.Event.on_commander_die,
}

PlayerGuideDefine.BattleEventArgs =
{
    ["进入战斗"] = {"pvpId"},
    ["单位升星"] = {"unitId","star"},
    ["回合开始"] = {"round","delay"},
    ["打开界面"] = {"name"},
    ["关闭界面"] = {"name"},
    ["段位变化"] = {"division"},
    ["段位到达"] = {"division"},
    ["PVE回合开始"] = {"pveId","group"},
    ["进入特定PVP"] = {"maxCount"},
    ["进入特定PVE"] = {"pveId"},
    ["统帅死亡"] = {"isSelf"},
    ["使用PVE技能"] = {"skillId"},
}

PlayerGuideDefine.NodePath = {
    ["奖励界面"] = {name = "AwardWindow", path = "panel_bg"},
    ["领奖确定"] = {name = "AwardWindow", path = "btn_close"},

    ["1v1按钮"] = {name = "MainuiPanel", path = "main/enter_battle_btn"},
    ["背包按钮"] = {name = "MainuiPanel", path = "bottom_canvas/img_bg/tab_2/btn"},
    ["对战按钮"] = {name = "MainuiPanel", path = "bottom_canvas/img_bg/tab_3/btn"},
    ["统帅按钮"] = {name = "MainuiPanel", path = "bottom_canvas/img_bg/tab_4/btn"},
    -- ["PVE按钮"] = {name = "MainuiPanel", path = "main/enter_pve_btn"},
    ["招募按钮"] = {name = "MainuiPanel", path = "main/draw_card_btn"},
    ["战令按钮"] = {name = "MainuiPanel", path = "main/battlepass_func"},
    ["段位入口按钮"] = {name = "MainuiPanel", path = "main/division_func"},
    ["日常任务按钮"] = {name = "MainuiPanel", path = "main/daily_task_btn"},

    ["PVE挑战按钮"] = {name = "PveEnterPanel", path = "main/pve_btn"},

    ["段位返回按钮"] = {name = "RankWindow", path = "bottom/btn_back"},

    ["上阵按钮"] = {name = "UnitDetailsWindow", path = "main/panel_bg/attr_panel/btn"},

    ["1v1快速匹配按钮"] = {name = "BattleModePanel", path = "main/match_btn"},

    ["技能三选一(左)"] = {name = "PveMainPanel", path = "main/select_item_node/item_root/item_1_root/item_1/btn"},
    ["技能三选一(中)"] = {name = "PveMainPanel", path = "main/select_item_node/item_root/item_2_root/item_2/btn"},
    ["技能三选一(右)"] = {name = "PveMainPanel", path = "main/select_item_node/item_root/item_3_root/item_3/btn"},

    ["招募一次按钮"] = {name = "DrawCardWindow", path = "main/btn_single"},
    ["招募十次按钮"] = {name = "DrawCardWindow", path = "main/btn_multi"},
    ["招募返回按钮"] = {name = "DrawCardWindow", path = "main/btn_back"},
    ["再次招募按钮"] = {name = "DrawCardSummaryWindow", path = "btn_again"},
    ["招募确定按钮"] = {name = "DrawCardSummaryWindow", path = "btn_confirm"},
    ["单抽招募结果"] = {name = "DrawCardSummaryWindow", path = "content/mode_1/pos_1"},

    ["统帅宝箱按钮"] = {name = "CommanderWindow", path = "main/pve/open_chest_btn"},

    ["装备按钮"] = {name = "NewEquipWindow", path = "main/op_node/put_on_btn"},

    ["战令返回按钮"] = {name = "BattlepassWindow", path = "canvas_bottom/bottom/image_49"},
    ["战令进度条"] = {name = "BattlepassWindow", path = "canvas_top/img_total_pgr"},

    ["功能解锁关闭按钮"] = {name = "OpenFuncWindow", path = "panel_bg"},
}

--自动执行引导
PlayerGuideDefine.AutoExecMode = false

--引导是否关闭
PlayerGuideDefine.BanGuide = true