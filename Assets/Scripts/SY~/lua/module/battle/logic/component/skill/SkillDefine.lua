SkillDefine = StaticClass("SkillDefine")


SkillDefine.DataKey =
{
    trigger_num = 1,
    temp_atk_range = 2,
    skill_hit_result = 3,
    be_hit_value = 4,
    rel_pos = 5,
}

SkillDefine.SkillType = 
{
	none = 0,
	normal_atk = 1,
    ult = 2, --大招
}



SkillDefine.RelType = 
{
	action = 1,
	pasv = 2,
	trigger = 3,
    manual = 4,   -- 手动拖拽释放
}

SkillDefine.RelCenter =
{
    self = 1,
    target = 2,
    random_self_camp_area = 3,
    random_enemy_camp_area = 4,
}

SkillDefine.RelDir =
{
    keep = 1,
    target = 2,
    forward = 3,
}

SkillDefine.RelRangeType =
{
    all = 0,
    self = 1,
    enemy = 2,
}

--被动
SkillDefine.PasvCondIndex = 
{
	["释放技能"] = "EventCond",
    ["技能准备命中"] = "EventCond",
    ["技能命中单位"] = "EventCond",
    ["技能击杀单位"] = "EventCond",
    ["技能命中检测暴击"] = "EventCond",
    ["准备死亡"] = "EventCond",
    ["单位死亡"] = "EventCond",
    ["单位受击"] = "EventCond",
    ["技能命中完毕"] = "EventCond",
    ["闪避"] = "EventCond",

    ["技能命中相同目标"] = "SkillHitSameTargetCond",
    ["技能切换命中目标"] = "SkillSwitchHitTargetCond",

    ["进入回合"] = "EnterRoundCond",

    ["主堡低于血量"] = "HomeLessHpCond",
    ["单位低于血量"] = "UnitLessHpCond",

    ["间隔执行"] = "IntervalExecuteCond",

    ["累计技能消耗的能量"] = "SkillHitTargetCostEnergyCond",
}

SkillDefine.PasvCondEventIndex = 
{
	["释放技能"] = BattleEvent.rel_skill,
    ["技能准备命中"] = BattleEvent.skill_ready_hit,
    ["技能命中单位"] = BattleEvent.skill_hit,
    ["技能击杀单位"] = BattleEvent.skill_kill_unit,
    ["技能命中检测暴击"] = BattleEvent.skill_hit_check_crit,
    ["准备死亡"] = BattleEvent.unit_ready_die,
    ["单位死亡"] = BattleEvent.unit_die,
    ["单位受击"] = BattleEvent.unit_be_hit,
    ["技能命中完毕"] = BattleEvent.skill_hit_complete,
    ["闪避"] = BattleEvent.unit_dodge,
}

SkillDefine.PasvEventToParamName = 
{
	["skillId"] = "skillId",
    ["skillLev"] = "skillLev",
    ["entityUid"] = "entityUid",
	["unitId"] = "unitId",
	["buffId"] = "buffId",
    ["beHitUnit"] = "beHitUnit",
    ["hitDistType"] = "hitDistType",
    ["radius"] = "radius",
    ["fromCondId"] = "fromCondId",
    ["targetCondId"] = "targetCondId",
    ["hitFlags"] = "hitFlags",
}

SkillDefine.PasvActionIndex = 
{

}

SkillDefine.PasvTargetType =
{
    binder = 1,
    from   = 2,
    target = 3,
}


SkillDefine.SkillNameType =
{
    head_top = 1,
    banner = 2,
    head_top_and_banner = 3,
}
