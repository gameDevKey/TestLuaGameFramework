DashboardWindow = BaseClass("DashboardWindow",BaseWindow)

function DashboardWindow:__Init()
    self:SetAsset("ui/prefab/dashboard/dashboard_window.prefab", AssetType.Prefab)
    self:SetCacheMode(UIDefine.CacheMode.hide)
    self.lastOrientation = nil
    self.lastScreenWidth = 0
    self.lastScreenHeight = 0
end

function DashboardWindow:__Delete()

end

function DashboardWindow:__CacheObject()
    self.mainTrans = self:Find("main")
end

function DashboardWindow:__BindListener()
    self:Find("close_btn",Button):SetClick(self:ToFunc("CloseClick"))
end

function DashboardWindow:__Show()
    self.lastOrientation = Screen.orientation
    self.lastScreenWidth = Screen.width
    self.lastScreenHeight = Screen.height
    Screen.orientation = ScreenOrientation.Landscape
    Screen.SetResolution(1280,720,false)

    if not self.uiDashboardPanel then
        self.uiDashboardPanel = UIDashboardPanel.New()
        self.uiDashboardPanel:SetParent(self.mainTrans)
    end
    self.uiDashboardPanel:Show()
end

function DashboardWindow:__Hide()
    Screen.orientation = self.lastOrientation
    Screen.SetResolution(self.lastScreenWidth,self.lastScreenHeight,false)

    if self.uiDashboardPanel then
        self.uiDashboardPanel:Hide()
    end
end

function DashboardWindow:CloseClick()
    ViewManager.Instance:CloseWindow(DashboardWindow)
end