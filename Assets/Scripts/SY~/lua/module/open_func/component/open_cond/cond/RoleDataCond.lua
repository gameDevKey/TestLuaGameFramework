RoleDataCond = StaticClass("RoleDataCond")


function RoleDataCond.ToDivision(cond)
    local roleData = mod.RoleProxy.roleData
    if cond.division > 0 and roleData.division < cond.division then
        return false
    elseif cond.trophy > 0 and roleData.trophy < cond.trophy then
        return false
    end
    return true
end