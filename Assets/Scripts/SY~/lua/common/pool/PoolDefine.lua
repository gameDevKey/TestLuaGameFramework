PoolDefine = SingleClass("PoolDefine")

PoolDefine.poolMappings = 
{
	[PoolType.base_view] = BaseViewPool,
	[PoolType.class] = ClassPool,
	[PoolType.object] = ObjectPool,
	[PoolType.hero_tpose] = HeroTposePool,
	[PoolType.battle_effect] = BattleEffectPool,
}

--有些对象类型，系统进行封装，并不想改动源文件，在此做索引
PoolDefine.PoolKey = 
{
	["vector3"] = "vector3",
	["vector2"] = "vector2",
	["object"] = "object",
	["empty_object"] = "empty_object",
	["window_parent"] = "window_parent",
	["panel_parent"] = "panel_parent",
}

PoolDefine.poolMaxExistNum =
{
	-- [PoolType.base_view] = BaseViewPool,
	-- [PoolType.class] = ClassPool,
	[PoolType.object] = 20,
	[PoolType.hero_tpose] = 10,
	[PoolType.battle_effect] = 2,
}