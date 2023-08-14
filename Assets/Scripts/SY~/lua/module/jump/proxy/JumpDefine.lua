JumpDefine = StaticClass("JumpDefine")


JumpDefine.JumperMapping =
{
    ["卡牌背包"] = {class = "BackpackJumper"},
    ["PVP入口"] = {class = "BattleEnterJumper",mode=1},
    ["PVE入口"] = {class = "BattleEnterJumper",mode=2},

    ["战令界面"] = {class = "BattlepassJumper"},
    ["段位界面"] = {class = "RankJumper"},
    ["统帅界面"] = {class = "CommanderJumper"},
    ["日常任务"] = {class = "TaskJumper"},
    ["抽卡界面"] = {class = "DrawCardJumper"},
}