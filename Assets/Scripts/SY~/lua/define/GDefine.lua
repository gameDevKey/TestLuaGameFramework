GDefine = {}

GDefine.PlatformType =
{
	["WindowsEditor"] = 7,
	["OSXEditor"] = 0,
	["IPhonePlayer"] = 8,
	["Android"] = 11,
	["OSXPlayer"] = 1,
	["WindowsPlayer"] = 2,
	["WebGLPlayer"] = 17,
}

GDefine.DeviceLevel = 
{
	low = 1,
	middle = 2,
	high = 3,
}

GDefine.platform = nil

GDefine.mainCamera = nil


GDefine.JobIndex = 
{
	zhanshi = 1,     -- 战士
	fashi = 2,       -- 法师
	sheshou = 3,     -- 射手
	fuzhu = 4,       -- 辅助
	zhaohuan = 5,    -- 召唤
}

GDefine.JobIndexToDesc =
{
	[GDefine.JobIndex.zhanshi] = "战士",
	[GDefine.JobIndex.fashi] = "法师",
	[GDefine.JobIndex.sheshou] = "射手",
	[GDefine.JobIndex.fuzhu] = "辅助",
	[GDefine.JobIndex.zhaohuan] = "召唤",
}

GDefine.RaceType =
{
	ren_zu = 1,
	an_yuan = 2,
	shen_zu = 3,
}



GDefine.LifeType =
{
    none  = 0,
    youji = 1,
    jixie = 2,
}

GDefine.LifeTypeToDesc =
{
	[GDefine.LifeType.none]  = "",
	[GDefine.LifeType.youji] = "有机生命",
	[GDefine.LifeType.jixie] = "机械生命",
}

GDefine.WalkType =
{
	none  = 0,
    floor = 1,
	fly   = 2,
}

GDefine.WalkTypeToDesc =
{
	[GDefine.WalkType.none]  = "",
    [GDefine.WalkType.floor] = "地面",
	[GDefine.WalkType.fly]   = "飞行",
}

GDefine.FollowWalkType =
{
    floor  = 1,
	fly = 2,
    floor_fly = 3,
    home = 4,
}

GDefine.FollowWalkTypeToDesc =
{
    [GDefine.FollowWalkType.floor]     = "地面",
	[GDefine.FollowWalkType.fly]       = "飞行",
    [GDefine.FollowWalkType.floor_fly] = "地面+飞行",
    [GDefine.FollowWalkType.home]      = "统帅",
}

if not IS_CHECK then
	GDefine.Layer = 
	{
		default =  LayerMask.NameToLayer("Default"), --战斗对象层

		layer6 =  LayerMask.NameToLayer("Layer6"), --战斗对象层
		layer7 =  LayerMask.NameToLayer("Layer7"), --战斗特效层
		layer8 =  LayerMask.NameToLayer("Layer8"), --战斗射线层
		layer10 =  LayerMask.NameToLayer("Layer10"), --战斗遮罩层

		ui =  LayerMask.NameToLayer("UI"),
	}

	GDefine.screenCenter = Vector2(Screen.width * 0.5,Screen.height * 0.5)

	GDefine.SkillKind = {
		[SkillDefine.RelType.action] = TI18N("主"),  -- 主动技能
		[SkillDefine.RelType.pasv] = TI18N("被"),    -- 被动技能
		[SkillDefine.RelType.manual] = TI18N("怒"),  -- 怒气拖拽技能
	}
end

GDefine.isDebug = false

GDefine.DmgType =
{
	phy = 1,
	magic = 2,
}

GDefine.Attr = 
{
	max_hp = 101,
	atk = 102,
	atk_speed = 103,
	move_speed = 104,
	move_speed_rate = 105,--没用到
	crit_rate = 106,--暴击率
	crit_dmg = 107,--爆伤

	dodge = 110, --闪避

	atk_distance = 115,--射程

	max_energy = 116, --能量
	energy_add_rate = 117, --能量恢复比例

	battle_power = 1000,--战斗力
}

GDefine.EquipPart =
{
	tou_kui = 1,
	hu_jian = 2,
	yi_fu = 3,
	shou_tao = 4,
	ku_zi = 5,
	xie_zi = 6,
	yao_dai = 7,
	xiang_lian = 8,
	jie_zhi = 9,
}

GDefine.BagType =
{
	item = 1,
	equip = 2,
	temp = 3,
	
}

GDefine.AttrIdToName = {
	[GDefine.Attr.max_hp] = "max_hp",  --最大生命值
	[GDefine.Attr.atk] = "atk", --攻击
	[GDefine.Attr.atk_speed] = "atk_speed", --攻击速度
	[GDefine.Attr.move_speed] = "move_speed", --移动速度
	[GDefine.Attr.move_speed_rate] = "move_speed_rate", --移动速度比例
	[GDefine.Attr.crit_rate] = "crit_rate", --暴击率
	[GDefine.Attr.crit_dmg] = "crit_dmg", --爆伤
	[GDefine.Attr.atk_distance] = "atk_distance", --射程
	[GDefine.Attr.max_energy] = "max_energy", --最大能量
}

GDefine.AttrNameToId =
{
	[GDefine.AttrIdToName[GDefine.Attr.max_hp]] = GDefine.Attr.max_hp,
	[GDefine.AttrIdToName[GDefine.Attr.atk]] = GDefine.Attr.atk,
	[GDefine.AttrIdToName[GDefine.Attr.atk_speed]] = GDefine.Attr.atk_speed,
	[GDefine.AttrIdToName[GDefine.Attr.move_speed]] = GDefine.Attr.move_speed,
	[GDefine.AttrIdToName[GDefine.Attr.crit_rate]] = GDefine.Attr.crit_rate,
	[GDefine.AttrIdToName[GDefine.Attr.crit_dmg]] = GDefine.Attr.crit_dmg,
	[GDefine.AttrIdToName[GDefine.Attr.atk_distance]] = GDefine.Attr.atk_distance,
	[GDefine.AttrIdToName[GDefine.Attr.max_energy]] = GDefine.Attr.max_energy,
}



GDefine.Quality = {
	white     = 1, --白色
	green     = 2, --绿色
	bule      = 3, --蓝色
	purple    = 4, --紫色
	orange    = 5, --橙色
	red       = 6, --红色
	colourful = 7, --七彩
}

GDefine.QualityLowToHigh =
{
	GDefine.Quality.white,
	GDefine.Quality.green,
	GDefine.Quality.bule,
	GDefine.Quality.purple,
	GDefine.Quality.orange,
	GDefine.Quality.red,
	GDefine.Quality.colourful,
}

GDefine.QualityToName = {
	[GDefine.Quality.white]  = "普通",
	[GDefine.Quality.green]  = "优秀",
	[GDefine.Quality.bule]   = "稀有",
	[GDefine.Quality.purple] = "史诗",
	[GDefine.Quality.orange] = "传说",
	[GDefine.Quality.red]    = "神话",
	[GDefine.Quality.colourful]   = "创世",
}

GDefine.QualityTextColorLight ={
	[1] = "ffffff",
	[2] = "caf7ce",
	[3] = "c9eaff",
	[4] = "eec9ff",
	[5] = "feff99",
}

GDefine.QualityTextColorDark ={
	[1] = "ffffff",
	[2] = "9ff1a7",
	[3] = "a1c9ff",
	[4] = "caaae2",
	[5] = "f6ce79",
}

GDefine.StarStatus ={
	nonMax = 1,
	max = 2,
}

GDefine.UnitType ={
	hero = 1,
	commander = 2,
	castle = 3,
	summoner = 4,
	magicCard = 5,
	buildingCard =6,
}

GDefine.UnitTypeToDesc ={
	[GDefine.UnitType.hero]         = "英雄",
	[GDefine.UnitType.commander]    = "统帅",
	[GDefine.UnitType.castle]       = "城堡",
	[GDefine.UnitType.summoner]     = "召唤物",
	[GDefine.UnitType.magicCard]    = "魔法卡",
	[GDefine.UnitType.buildingCard] = "建筑卡",
}

GDefine.AttrTag =
{
	base = 1,
	entry = 2,
}

GDefine.ItemType ={
	currency = 1, -- 货币
	unitCard = 2, -- 单位卡
	gameplayCurrency = 3, -- 玩法内部货币
	chest = 4, -- 宝箱
	equip = 6, -- 装备
	customSelectAward = 7,	--自选奖励
}

GDefine.ItemTypeToDesc ={
	[GDefine.ItemType.currency] = "资源卡",
	[GDefine.ItemType.unitCard] = "单位卡",
	[GDefine.ItemType.gameplayCurrency] = "玩法内部货币",
	[GDefine.ItemType.chest] = "宝箱",
}

GDefine.Assets =
{
	diamond = 1,
	coin = 2,
}

GDefine.AssetsToName = {
	[GDefine.Assets.diamond] = "diamond",  -- 钻石
	[GDefine.Assets.coin]    = "coin",     -- 金币
}

GDefine.AssetsNameToId =
{
	[GDefine.AssetsToName[GDefine.Assets.diamond]] = GDefine.Assets.diamond,
	[GDefine.AssetsToName[GDefine.Assets.coin]] = GDefine.Assets.coin,
}

GDefine.RewardReceiveType ={
	newUnitCard = 1, -- 获得新卡
	gainItem    = 2, -- 获得道具
}

GDefine.ChestStateType = {
	unlocked            = 0, -- 宝箱开始解锁
	notUnlocked         = 1, -- 未开始倒计时
	unlocking           = 2, -- 倒计时未结束
	otherUnlocking      = 3, -- 其他正在倒计时中且已满
	countdownFinished   = 4, -- 宝箱倒计时已解锁
}

GDefine.DivisionNodeType = {
	division     = 1, -- 段位大节点
	trophyReward = 2, -- 阶段奖励小节点
}


GDefine.AttrIdToDesc ={
	[GDefine.Attr.max_hp] = "生命值",
	[GDefine.Attr.atk] = "攻击力",
	[GDefine.Attr.atk_speed] = "攻击速度",
	[GDefine.Attr.move_speed] = "移动速度",
	-- [GDefine.Attr.crit_rate] = "暴击率",
	-- [GDefine.Attr.crit_dmg] = "暴击伤害",
}
GDefine.AttrNameToDesc ={
	[GDefine.AttrIdToName[GDefine.Attr.max_hp]] = "生命值",
	[GDefine.AttrIdToName[GDefine.Attr.atk]] = "攻击力",
	[GDefine.AttrIdToName[GDefine.Attr.atk_speed]] = "攻击速度",
	[GDefine.AttrIdToName[GDefine.Attr.move_speed]] = "移动速度",
	-- [GDefine.AttrIdToName[GDefine.Attr.crit_rate]] = "暴击率",
	-- [GDefine.AttrIdToName[GDefine.Attr.crit_dmg]] = "暴击伤害",
}

GDefine.DetailsWindowOpenType ={
	embattled = 0,  -- 已上阵
	obtained = 1,  -- 已拥有但未上阵
	notObtained = 2,  -- 未拥有
}

GDefine.frameCount = 0

GDefine.luaDebug = false

GDefine.standardScreenWidth  = 720
GDefine.standardScreenHeight = 1280
GDefine.curScreenWidth  = 0
GDefine.curScreenHeight = 0




GDefine.Bone = 
{
	floot = 1,--脚底
	chest = 2,--胸口
	head = 3, --头
	waist = 4,--腰部
	left_hand = 5, --左手
	right_hand = 6,--右手
	left_weapon = 7, --左武器
	right_weapon = 8, --右武器

	root = 100, --根节点（不带有任何旋转）
	origin = 101,--模型原点（跟随模型旋转）
	custom = 102,
	forward = 103,
}

GDefine.BoneName = 
{
	floot = "bp_root",
	chest = "bp_chest",
	head = "bp_head",
	waist = "bp_waist",
	left_hand = "bp_l_hand",
	right_hand = "bp_r_hand",
	left_weapon = "bp_l_weapon",
	right_weapon = "bp_r_weapon",

	root = "root",
	origin = "origin",
	custom = "custom",
	forward = "forward"
}

GDefine.BoneIndex = 
{
	[GDefine.Bone.floot] = GDefine.BoneName.floot,
	[GDefine.Bone.chest] = GDefine.BoneName.chest,
	[GDefine.Bone.head] = GDefine.BoneName.head,
	[GDefine.Bone.waist] = GDefine.BoneName.waist,
	[GDefine.Bone.left_hand] = GDefine.BoneName.left_hand,
	[GDefine.Bone.right_hand] = GDefine.BoneName.right_hand,
	[GDefine.Bone.left_weapon] = GDefine.BoneName.left_weapon,
	[GDefine.Bone.right_weapon] = GDefine.BoneName.right_weapon,

	[GDefine.Bone.root] = GDefine.BoneName.root,
	[GDefine.Bone.origin] = GDefine.BoneName.origin,
	[GDefine.Bone.custom] = GDefine.BoneName.custom,
	[GDefine.Bone.forward] = GDefine.BoneName.forward,
}


GDefine.Nature =
{
	all   = 0, --全部 
	water = 1, --水
	fire  = 2, --火
	wind  = 3, --风
	light = 4, --光
	dark  = 5, --暗
}

--判断是否模拟器
GDefine.isEmulator = false 
--是否有刘海
GDefine.supportNotch = false
--刘海的高度 
GDefine.notchHeight = 50

--玩家数据类型
GDefine.RoleInfoType =
{
	trophy = 1,--杯数
	division = 2,--段位
	win_count = 3,--胜利场次
	battle_count = 4,--总战斗场次
}

GDefine.RoleInfoName =
{
	[GDefine.RoleInfoType.trophy] = "trophy", --杯数
	[GDefine.RoleInfoType.division] = "division", --段位
	[GDefine.RoleInfoType.win_count] = "win_count", --胜利场次
	[GDefine.RoleInfoType.battle_count] = "battle_count", --总战斗场次
}

GDefine.ItemId = {
	Diamond = 1,				--钻石
	Gold = 2,					--金币
	Trophy = 3,                 --奖杯
	EquipChest = 105,			--装备箱
	DrawCardAddUpTicket = 106,	--累抽币
	SpeedCard = 107,			--加速卡
	DrawCardTicket = 108, 		--抽卡券
	AdvTicket = 110,			--扫荡券(冒险)
}

--抽卡类型
GDefine.DrawCardType = {
    Single = 101,   --单抽
    Multi = 102,    --连抽
    Progress = 103, --累抽
}

GDefine.AwardState = {
    Lock = 1, --未解锁
    Unclaimed = 2, --可领
    Receive = 3, --已领
}

GDefine.ResFloatType = {
    Trophy = 1,
    Battlepass = 2,
    Gold = 3,
    Diamond = 4,
    EquipChest = 5,
    AdvTicket = 6,
    DrawCardTicket = 7,
}

GDefine.FuncUnlockId = {
	OpenChest = 101,--开宝箱
	Pve = 102,		--PVE
	DrawCard = 103,	--抽卡
	DailyTask = 104,--每日任务
	Battlepass = 105,--战令
	RoomBattle = 106,--创建房间对战
	ChangeCardGroup = 107,--切换卡组
	Store = 108,	--商城
	Email = 109,	--邮件
	Friend = 110,	--好友
}

--预留十层给特效那边做夹层动效
GDefine.EffectOrderAdd = 10



--全局变量
IS_DEBUG = false --是否调试（编辑器、pc环境一定为true，其它平台根据特殊操作开启）
IS_EDITOR = false --是否编辑器环境