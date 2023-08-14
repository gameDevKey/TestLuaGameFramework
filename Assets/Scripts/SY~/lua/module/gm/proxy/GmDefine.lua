GmDefine = BaseClass("GmDefine")

GmDefine.FromType =
{
    conf = 1,
    server = 2,
    client = 3,
}

GmDefine.gmList = {
    ["常规命令"] =
    {
        {
            command = "debug_battle",
            args = {},
            func = "GmFunCtrl.OpenBattleDebugPanel",
            id=11,
            notes="战斗调试面板开关",
            remark="",
        },
        {
            command = "debug_guide",
            args = {},
            func = "GmFunCtrl.DebugGuide",
            id=11,
            notes="调试引导",
            remark="",
        },
        {
            command = "debug_network_disconnect",
            args = {},
            func = "GmFunCtrl.DebugNetworkDisconnect",
            id=11,
            notes="断网",
            remark="",
        },
        {
            command = "open_dashboard_window",
            args = {},
            func = "GmFunCtrl.OpenDashboardWindow",
            id=11,
            notes="打开仪表盘",
            remark="",
        },
        {
            command = "preview_adaptive",
            args = {},
            func = "GmFunCtrl.PreviewAdaptive",
            id=11,
            notes="预览适配",
            remark="",
        },
        {
            command = "fix_rank_window",
            args = {},
            func = "GmFunCtrl.FixRankWindow",
            id=11,
            notes="修复段位界面BUG",
            remark="",
        },
        {
            command = "show_player_guide",
            args = {},
            func = "GmFunCtrl.ShowPlayerGuide",
            id=11,
            notes="输出正在运行的引导",
            remark="",
        },
        {
            command = "enter_pve",
            args = {},
            func = "GmFunCtrl.EnterPVE",
            id=11,
            notes="进入PVE",
            remark="",
        },
        {
            command = "quick_finish_guide",
            args = {},
            func = "GmFunCtrl.QuickFinishGuide",
            id=11,
            notes="完成至该引导",
            remark="",
        },
        {
            command = "auto_exec_guide",
            args = {},
            func = "GmFunCtrl.AutoExecGuide",
            id=11,
            notes="自动跑引导",
            remark="",
        },
    },
    ["战斗"] =
    {
        {
            command = "battle_win",
            args = {},
            func = "GmFunCtrl.BattleWin",
            id=11,
            notes="直接胜利",
            remark="",
        },
        {
            command = "battle_lose",
            args = {},
            func = "GmFunCtrl.BattleLose",
            id=11,
            notes="直接失败",
            remark="",
        },
        {
            command = "debug_battle_time",
            args = {},
            func = "GmFunCtrl.DebugBattleTime",
            id=11,
            notes="调试战斗时间",
            remark="",
        },
        {
            command = "active_battle_effect",
            args = {},
            func = "GmFunCtrl.ActiveBattleEffect",
            id=11,
            notes="开关战斗特效",
            remark="",
        },
        {
            command = "battle_test",
            args = {},
            func = "GmFunCtrl.BattleTest",
            id=11,
            notes="战斗测试",
            remark="",
        },
        {
            command = "save_battle_data",
            args = {},
            func = "GmFunCtrl.SaveBattleData",
            id=11,
            notes="保存本场战斗数据",
            remark="",
        },
        {
            command = "unit_to_star",
            args = {},
            func = "BattleFunCtrl.UnitToStar",
            id=11,
            notes="设置单位星级",
            remark="",
        },
        {
            command = "unit_max_energy",
            args = {},
            func = "BattleFunCtrl.UnitMaxEnergy",
            id=11,
            notes="单位满怒",
            remark="",
        },
        {
            command = "log_hero_buffs",
            args = {},
            func = "GmFunCtrl.LogAllHeroBuff",
            id=11,
            notes="检索英雄Buff",
            remark="",
        }
    },
    ["其它"] =
    {
        {
            command = "exit_login",
            args = {},
            func = "GmFunCtrl.ExitLogin",
            id=11,
            notes="退出登录",
            remark="",
        },
    }
}