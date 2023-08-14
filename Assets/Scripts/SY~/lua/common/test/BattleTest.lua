BattleTest = StaticClass("BattleTest")

function BattleTest.Test(isProfiler)
    local file = "wxgame_battle.data"

    local content = nil
    if GDefine.platform == GDefine.PlatformType.WebGLPlayer then
        content = LuaManager.Instance:GetFileDataToString(file)
    else
        if AssetsSetup.Instance:ExistLuaSetup(file) then
            content = AssetsSetup.Instance:GetLuaBytesToString(file)
        else
            content = IOUtils.ReadAllText(BaseSetting.luaRootPath .. file)
        end
    end
    
    LogInfo(content)

    local debugData = TableUtils.StringToTable(content)
    BattleCheckoutSystem.DebugCheckBattle(debugData.role_uid,debugData.enter_data,debugData.frame_data,nil,true,isProfiler)
end