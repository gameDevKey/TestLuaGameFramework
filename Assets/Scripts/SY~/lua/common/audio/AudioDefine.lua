AudioDefine = AudioDefine or {}


AudioDefine.AudioType = 
{
    bgm   = "bgm",
    ui    = "ui",
    skill = "skill"
}


AudioDefine.SameDispose =
{
    ignore  = 1, --忽略
    overlay = 2, --叠加
    replace = 3, --替换
}

AudioDefine.AudioPlaySetting =
{
    [AudioDefine.AudioType.bgm] = {single = true,volume = 0.5,loop = true,sameDispose = AudioDefine.SameDispose.ignore},
    [AudioDefine.AudioType.ui] = {single = false,volume = 1,loop = false,sameDispose = AudioDefine.SameDispose.replace},
    [AudioDefine.AudioType.skill] = {single = false,volume = 0.8,loop = false,sameDispose = AudioDefine.SameDispose.ignore},
}
