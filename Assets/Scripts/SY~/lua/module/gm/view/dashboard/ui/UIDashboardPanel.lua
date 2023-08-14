UIDashboardPanel = BaseClass("UIDashboardPanel",BaseView)

function UIDashboardPanel:__Init()
    self:SetAsset("ui/prefab/dashboard/ui_dashboard_panel.prefab", AssetType.Prefab)
    self.items = {}
end

function UIDashboardPanel:__Delete()

end

function UIDashboardPanel:__CacheObject()
    self.item = self:Find("main/Scroll View/Viewport/Content/item").gameObject
    self.itemParent = self:Find("main/Scroll View/Viewport/Content")
end

function UIDashboardPanel:__Hide()

end


function UIDashboardPanel:__Show()
    for i,v in ipairs(self.items) do
        GameObject.Destroy(v)
    end
    self.items = {}

    local uiInfos = DashboardManager.Instance:Call(DashboardDefine.DashboardType.ui,"GetUIInfos")
    for i,v in ipairs(uiInfos) do
        if not v.viewName:find("Dashboard") and v.viewName ~= BattleMainPanel.__className  then
            local item = GameObject.Instantiate(self.item)
            item:SetActive(true)
            item.transform:SetParent(self.itemParent)
            item.transform:Reset()
            item.transform:Find("view_name").gameObject:GetComponent(Text).text = v.viewName
            item.transform:Find("time").gameObject:GetComponent(Text).text = string.format("打开耗时:%sms",v.time)
            table.insert(self.items,item)
        end
    end
end

