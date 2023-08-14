RemindDefine = StaticClass("RemindDefine")

--红点模块设计标准：
--1.红点逻辑判定与具体业务层脱钩，业务逻辑层不需要做任何红点达成判断
--2.业务逻辑层构造相应Remind的Item并进行设置红点id即可
--3.业务逻辑层只关心红点对应的Id、需要用那个Item、以及挂载Item的父节点即可
--4.红点的刷新逻辑由绑定的协议自行触发


--使用流程：
--1.RemindDefine.RemindId定义所需红点id(参考下方统帅相关定义)
--2.RemindDefine.RemindInfo定义模块红点树结构(参考下方统帅相关定义)
--3.实现红点逻辑处理函数(参考CommanderRemindCtrl)
--4.业务逻辑层New相应的Remind类、并调用SetParent设置父节点、调用SetRemindId设置绑定的红点id(参考MainuiBottomBtnPanel)


--备注：
--1.红点树结构定义可以看下方案例
--2.支持动态key红点，比如卡牌升级红点检测，可能同时会有N个卡牌的红点，我们不可能在红点树里把所有卡牌的红点id都定义出来
--动态key红点，我们只需要定义个卡牌升级的红点id，然后在业务逻辑层设置SetRemindId的时候把卡牌flagKey传进去，
--然后红点逻辑处理的回调函数里，设置SetFlag的时候，把flagKey一起传进去，即可实现动态key红点



RemindDefine.RemindId =
{
    --统帅部分
    commander_open_chest = "commander_open_chest",--是否可以开启宝箱
    commander_chest_exist_equip = "commander_chest_exist_equip", --是否存在开启的装备
    commander_chest_intensify = "commander_chest_intensify", --宝箱强化
    commander_chest_up_lev = "commander_chest_up_lev", --宝箱升级

    --段位
    division_up = "division_up",        --段位升级
    division_reward = "division_reward", --段位有奖励可领

    --抽卡
    draw_card_ticket = "draw_card_ticket",   --抽卡券足够

    --战令
    battlepass_reward = "battlepass_reward", --战令有奖励可领

    --任务
    task = "task",
    task_receive = "task_receive",

    --pve
    pve_sweep = "pve_sweep",
    pve_award = "pve_award",

    --藏品
    collection_new_unit = "collection_new_unit", --有新卡
    collection_embattled_card_can_upgrade = "collection_embattled_card_can_upgrade", --已上阵卡牌可升级
    collection_library_card_can_upgrade = "collection_library_card_can_upgrade", --牌库(未上阵)卡牌可升级

    --邮件
    email_unread = "email_unread",

    --商店
    shop_new_unit = "shop_new_unit",
    shop_free_can_buy = "shop_free_can_buy",

    --好友
    friend_entrance = "friend_entrance",
    friend_apply = "friend_apply",
}


RemindDefine.RemindInfo = {}
------------------------------------------------------------------
--统领养成
RemindDefine.RemindInfo[RemindDefine.RemindId.commander_open_chest] =
{
    protoId = {10300,10301}, --触发红点逻辑的协议列表
    isChangeParent = false, --是否影响父节点
    func = "CommanderRemindCtrl.CommanderOpenChest", --接受协议后，回调的处理函数
    childs = {},--子红点树
}

RemindDefine.RemindInfo[RemindDefine.RemindId.commander_chest_exist_equip] =
{
    protoId = {10300,10301},
    isChangeParent = false,
    func = "CommanderRemindCtrl.CommanderChestExistEquip",
    childs = {},
}

RemindDefine.RemindInfo[RemindDefine.RemindId.commander_chest_intensify] =
{
    protoId = {11002,10301},
    isChangeParent = false,
    func = "CommanderRemindCtrl.CommanderChestIntensify",
    childs = {},
}

RemindDefine.RemindInfo[RemindDefine.RemindId.commander_chest_up_lev] =
{
    protoId = {11002,11005,11007},
    isChangeParent = false,
    func = "CommanderRemindCtrl.CommanderChestUpLev",
    childs = {},
}


--段位
RemindDefine.RemindInfo[RemindDefine.RemindId.division_up] =
{
    protoId = {10111}, --触发红点逻辑的协议列表
    isChangeParent = true, --是否影响父节点
    func = "DivisionRemindCtrl.CheckDivisionUp", --接受协议后，回调的处理函数
    childs = {},--子红点树
}

RemindDefine.RemindInfo[RemindDefine.RemindId.division_reward] =
{
    protoId = {10111,10600,10601}, --触发红点逻辑的协议列表
    isChangeParent = true, --是否影响父节点
    func = "DivisionRemindCtrl.CheckDivisionReward", --接受协议后，回调的处理函数
    childs = {},--子红点树
}


--抽卡
RemindDefine.RemindInfo[RemindDefine.RemindId.draw_card_ticket] =
{
    protoId = {10300,10301}, --触发红点逻辑的协议列表
    isChangeParent = true, --是否影响父节点
    func = "DrawCardRemindCtrl.CheckTicketEnough", --接受协议后，回调的处理函数
    childs = {},--子红点树
}

--战令
RemindDefine.RemindInfo[RemindDefine.RemindId.battlepass_reward] =
{
    protoId = {11100,11101,11102,10801,10802}, --触发红点逻辑的协议列表
    isChangeParent = true, --是否影响父节点
    func = "BattlepassRemindCtrl.CheckBattlepassReward", --接受协议后，回调的处理函数
    childs = {},--子红点树
}


--任务
RemindDefine.RemindInfo[RemindDefine.RemindId.task] = {
    protoId = {11500,11501,11502},
    isChangeParent = false,
    func = "TaskRemindCtrl.CheckTaskRemind",
    childs = {}
}

RemindDefine.RemindInfo[RemindDefine.RemindId.task_receive] = {
    protoId = {11500,11501,11502},
    isChangeParent = false,
    func = "TaskRemindCtrl.CheckReceiveTaskRemind",
    childs = {}
}

--



--PVE
RemindDefine.RemindInfo[RemindDefine.RemindId.pve_sweep] = 
{
    protoId = {10901,10902,10300,10301},
    isChangeParent = true,
    func = "PveRemindCtrl.CheckPveSweep",
    childs = {},
}

RemindDefine.RemindInfo[RemindDefine.RemindId.pve_award] = 
{
    protoId = {10901,10903},
    isChangeParent = true,
    func = "PveRemindCtrl.CheckPveAward",
    childs = {},
}

--背包
RemindDefine.RemindInfo[RemindDefine.RemindId.collection_new_unit] =
{
    protoId = {10200,10201}, --触发红点逻辑的协议列表
    isChangeParent = false, --是否影响父节点
    func = "CollectionRemindCtrl.CollectionObtainNewCard",
    childs = {},
}

RemindDefine.RemindInfo[RemindDefine.RemindId.collection_embattled_card_can_upgrade] =
{
    protoId = {10201,10204,10205,10300,10301},
    isChangeParent = false,
    func = "CollectionRemindCtrl.CollectionEmbattledCardCanUpgrade",
    childs = {},
}

RemindDefine.RemindInfo[RemindDefine.RemindId.collection_library_card_can_upgrade] =
{
    protoId = {10201,10204,10205,10300,10301},
    isChangeParent = false,
    func = "CollectionRemindCtrl.CollectionLibraryCardCanUpgrade",
    childs = {},
}

--邮件
RemindDefine.RemindInfo[RemindDefine.RemindId.email_unread] = {
    protoId = {11700,11701,11702,11703},
    isChangeParent = false,
    func = "EmailRemindCtrl.CheckEmailUnread",
    childs = {},
}

--商店
RemindDefine.RemindInfo[RemindDefine.RemindId.shop_new_unit] =
{
    protoId = {11800,11801,11802,11803},
    isChangeParent = false,
    func = "ShopRemindCtrl.ShopNewUnit",
    childs = {},
}

RemindDefine.RemindInfo[RemindDefine.RemindId.shop_free_can_buy] =
{
    protoId = {11800,11801,11802,11803},
    isChangeParent = false,
    func = "ShopRemindCtrl.ShopFreeCanBuy",
    childs = {},
}

--好友
RemindDefine.RemindInfo[RemindDefine.RemindId.friend_apply] =
{
    protoId = {11900,11905,11906,11910},
    isChangeParent = false,
    func = "FriendRemindCtrl.CheckFriendApply",
    childs = {},
}

RemindDefine.RemindInfo[RemindDefine.RemindId.friend_entrance] =
{
    protoId = {11900,11905,11906,11910},
    isChangeParent = false,
    func = "FriendRemindCtrl.CheckFriendEntrance",
    childs = {},
}