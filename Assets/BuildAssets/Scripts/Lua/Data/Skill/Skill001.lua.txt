local Skill001 = {}

Skill001.Id = "Skill001"

Skill001.CD = 1

Skill001.Type = SkillConfig.Type.Act

Skill001.Event = {
     
}

Skill001.RelCondition = "HP > 0 && MoveSpeed > 0"

Skill001.TargetNum = 3

Skill001.Range = {
    type = RangeConfig.Type.Circle,
    radius = 5,
}

Skill001.TargetCondition = "HP > 0"

Skill001.Timeline = "SkillAction001"

return Skill001