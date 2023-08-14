OpenFuncWindow = BaseClass("OpenFuncWindow",BaseWindow)
OpenFuncWindow.__showMainui = true

function OpenFuncWindow:__Init()
    self:SetAsset("ui/prefab/open_func/open_func_window.prefab",AssetType.Prefab)
    self.changeList = nil
end

function OpenFuncWindow:__Delete()
end

function OpenFuncWindow:__CacheObject()
    self.funcIcon = self:Find("main/func_icon",Image)
    self.funcName = self:Find("main/func_name",Text)
    self.content = self:Find("main/content",Text)
end

function OpenFuncWindow:__Create()
    self:Find("main/title",Text).text = TI18N("功能开启")
end

function OpenFuncWindow:__BindEvent()
end

function OpenFuncWindow:__BindListener()
    self:Find("panel_bg",Button):SetClick(self:ToFunc("ShowNextOpenFunc"))
end

function OpenFuncWindow:__Show()
    self.showList = self.args.showList
    LogTable("self.showList",self.showList)
    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_open, "open_func")
    self:ShowNextOpenFunc()
end

function OpenFuncWindow:__Hide()
end

function OpenFuncWindow:ShowNextOpenFunc()
    if next(self.showList) ~= nil then
        self:SetOpenFuncInfo()
    else
        mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_close, "open_func")
        ViewManager.Instance:CloseWindow(OpenFuncWindow)
    end
end

function OpenFuncWindow:SetOpenFuncInfo()
    local info = table.remove(self.showList,1)
    local path = AssetPath.GetFuncOpenIcon(info.funcIcon)
    self:SetSprite(self.funcIcon,path,true)
    self.funcName.text = info.funcName
    self.content.text = info.content
end