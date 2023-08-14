DashboardDefine = StaticClass("DashboardDefine")

DashboardDefine.DashboardType =
{
    base_info = {title = "基础信息"},
    ui = "ui",
    battle = {title = "战斗信息"}
}

DashboardDefine.DashboardInfo =
{
    [DashboardDefine.DashboardType.ui] = {title = "UI",class = "UIDashboard"}
}