DashboardManager = SingleClass("DashboardManager")

function DashboardManager:__Init()
    self.dashboards = {}

    self:AddDashboard(DashboardDefine.DashboardType.ui)
end

function DashboardManager:__Delete()

end

function DashboardManager:Update()

end

function DashboardManager:AddDashboard(type)
    local info = DashboardDefine.DashboardInfo[type]
    local ctype = GetClass(info.class)
    local dashboard = ctype.New()
    table.insert(self.dashboards,dashboard)
    self[info.class] = dashboard
end

function DashboardManager:Call(type,funName,...)
    local info = DashboardDefine.DashboardInfo[type]
    local instance = self[info.class]
    return instance[funName](instance,...)
end