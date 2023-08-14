OpenFuncDefine = StaticClass("OpenFuncDefine")


OpenFuncDefine.CondMapping =
{
    ["到达段位"] = {class = "RoleDataCond",func = "ToDivision"},
    ["完成引导"] = {class = "PlayerGuideCond",func = "HasFinishGroup"},
}