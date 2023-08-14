BuffDefine = StaticClass("BuffDefine")

BuffDefine.ActionIndex =
{
    ["修改属性"] = "ChangeAttrBuffBehavior",
    ["冰冻"] = "FrozenStateBuffBehavior",
    ["眩晕"] = "DizzinessStateBuffBehavior",
    ["石化"] = "PetrifyingStateBuffBehavior",
    ["无法被选择"] = "NotBeSelectStateBuffBehavior",
    ["命中结算"] = "HitResultBuffBehavior",
    ["修改攻击范围"] = "ChangeAtkRangeBuffBehavior",
    ["修改被命中结算"] = "ChangeDoHitResultValBuffBehavior",
    ["吸收命中伤害"] = "AbsorbHitDmgBuffBehavior",
    ["分担范围内被命中结算值"] = "ShareDoHitResultValInRangeBuffBehavior",
    ["修改命中结算Id"] = "ChangeHitResultIdBuffBehavior",
    ["尝试闪避命中结算"] = "TryToDodgeHitResultBehavior",
    ["释放技能"] = "BuffRelSkillBehavior",
    ["反转阵营"] = "ReversalCampBuffBehavior",
    ["嘲讽"] = "TauntPrioritySelectBuffBehavior",
    ["输入技能释放暴击"] = "InputSkillRelCritBuffBehavior",
    ["输入技能修改命中结算"] = "InputSkillRelChangeHitResultBuffBehavior",
    ["目标Buff层数修改命中值"] = "TargetBuffOverlayChangeHitResultBuffBehavior",
    ["添加技能"] = "AddSkillBuffBehavior",
    ["增减益效果计数修改属性"] = "BuffCountChangeAttrBuffBehavior",
    ["禁止能量增加"] = "BanEnergyAddStateBuffBehavior",
    ["麻痹"] = "PalsyStateBuffBehavior",
    ["豁免减益效果"] = "ExemptDebuffBuffBehavior",
    ["缩放单位"] = "ChangeScaleBuffBehavior",
    ["禁止触发所有技能"] = "BanRelSkillStateBuffBehavior",
    ["输入命中修改结算Id"] = "InputHitChangeResultIdBuffBehavior",
}

BuffDefine.DispelType =
{
    doDispel_beDispel = 1, --驱散(可以被驱散)
    doDispel_notBeDispel = 2, --驱散(不可被驱散)
    notDoDispel_beDispel = 3, --不驱散(可被驱散)
    notDoDispel_notBeDispel = 4, --不驱散(不可被驱散)
}

BuffDefine.OverlayAction =
{
    keep = 1,
    reset_time = 2,
}

BuffDefine.ResultType = 
{
	buffer = 1, --增益
	deBuffer = 2, --减益
}