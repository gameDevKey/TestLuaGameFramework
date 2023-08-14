EffectDefine = SingleClass("EffectDefine")


EffectDefine.EffectType = 
{
    skill = 1,
    buff = 2,
    hit = 3,
    action = 4,
}

EffectDefine.CreateType = 
{
    loader = 1,
    object = 2,
}

EffectDefine.EffectNumInfo = 
{

}

function EffectDefine.GetEffectNum(effectType)
    return EffectDefine.EffectNumInfo[effectType] or 0
end

function EffectDefine.ClearEffectNumInfo()
    EffectDefine.EffectNumInfo = {}
end