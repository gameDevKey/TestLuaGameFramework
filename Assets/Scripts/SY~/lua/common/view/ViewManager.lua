ViewManager = SingleClass("ViewManager")

function ViewManager:__Init()
    self.windows = {}
    self.orderLayer = 10
    self.curWindow = nil
    self.readyOpenWindow = nil
    self.readyCloseWindow = nil
    self.windowList = {}

    self.checkMainui = true

    --留10给Tips?
    self.topCanvasSortingOrder = 32768 - 10
    --self:CreateTopCanvas()
end

function ViewManager:SetCheckMainui(flag)
    self.checkMainui = flag
end

function ViewManager:RemoveWindow(windowName)
    self.windows[windowName] = nil
end

function ViewManager:OpenWindowById(id,args)
    local winName = ViewDefine.WindowIdToName[id]
    return self:OpenWindowByName(winName)
end

function ViewManager:OpenWindow(win,args,isCache)
    local winName = win.__className
    return self:OpenWindowByName(winName,args,isCache)
end

function ViewManager:OpenWindowByName(winName,args,isCache)
    local windowClass = GetClass(winName)
    assert(windowClass ~= nil,string.format("没有对应的窗口类[win:%s]",tostring(winName)))
    if not self:CanOpenWindow(windowClass,args) then 
        return false 
    end
    local win = self.windows[winName] or self:CreateWindow(windowClass)
    self.windows[winName] = win
    if isCache then 
        win:CreateCache() 
        return true 
    end
    self.readyOpenWindow = winName
    win:Show(args)
    return true
end


function ViewManager:CanOpenWindow(windowClass,args)
    if not windowClass.IsOpen then 
        return true
    else
        return windowClass.IsOpen(args)
    end
end

function ViewManager:CacheWindow(windowName)
    self:OpenWindow(windowName,nil,true)
end

function ViewManager:CreateWindow(windowClass)
    local window = windowClass.New()
    window:SetParent(UIDefine.canvasRoot)
    return window
end

function ViewManager:OpenComplete(window)
    self:RemoveWindowList(window.winName)
    table.insert(self.windowList,window.winName)

    if not self.windows[window.winName] then 
        self.windows[window.winName] = window 
    end

    if self.readyOpenWindow ~= window.winName then
        window.gameObject:SetActive(false)
    else
        if self.curWindow ~= window.winName then 
            self:TempHideWindow(window)
        end

        self.curWindow = window.winName
        self.readyOpenWindow = nil
        self:CheckMainui(window)
    end
end

--[[
    __showMainui:是否显示主界面
    __topInfo:是否显示上栏
    __bottomTab:是否显示下栏
    __topBebind:上栏显示时，true代表把层级设置为顶层界面-1，false代表把层级设置在最高级
    __bottomBebind:下栏显示时，true代表把层级设置为顶层界面-1，false代表把层级设置在最高级
]]--
function ViewManager:CheckMainui(win)
    if not self.checkMainui then
        return
    end

    if win then
        mod.MainuiFacade:SendEvent(MainuiPanel.Event.ActiveMainui,win.__showMainui == true)
        mod.MainuiFacade:SendEvent(MainuiPanel.Event.ActiveTopInfo,win.__topInfo == true,win.__topBebind == true)
        mod.MainuiFacade:SendEvent(MainuiPanel.Event.ActiveBottomTab,win.__bottomTab == true,win.__bottomBebind == true)
    elseif #self.windowList <= 0 then
        mod.MainuiFacade:SendEvent(MainuiPanel.Event.ActiveMainui,true)
        mod.MainuiFacade:SendEvent(MainuiPanel.Event.ActiveTopInfo,true)
        mod.MainuiFacade:SendEvent(MainuiPanel.Event.ActiveBottomTab,true)
    end
end

function ViewManager:CloseComplete(winName)
    if not self.readyCloseWindow or self.readyCloseWindow ~= winName then
        return 
    end
    self.curWindow = nil
    self.readyCloseWindow = nil
    self:RemoveWindowList(winName)
    self:TempShowWindow()

    self:CheckMainui(self.windows[self.curWindow])
end

function ViewManager:TempHideWindow(openWindow)
    if not self.curWindow or openWindow.notTempHide then 
        return
    end
    local win = self.windows[self.curWindow]
    if win then
        win:TempHideWindow()
    end
end

function ViewManager:TempShowWindow()
    local len = #self.windowList
    if len <= 0 then 
        return 
    end

    local win = self.windows[self.windowList[len]]
    if not win then 
        return 
    end

    win:TempShowWindow()
    self.curWindow = win.winName
end

function ViewManager:GetCurWindow()
   return self.curWindow
end

function ViewManager:CloseMissWindow(windowName)
    if self.readyOpenWindow == windowName then 
        return false 
    end
    local win = self.windows[windowName]
    if win ~= nil then 
        win:CloseWindow(true) 
    end
    return true
end

function ViewManager:CloseWindow(win)
    local winName = win.__className
    self:CloseWindoByName(winName)
end

function ViewManager:CloseWindoByName(winName)
    local win = self.windows[winName]
    if win == nil then return end
    local isCurWindow = self.curWindow == winName

    if isCurWindow then
        self.readyCloseWindow = winName
    else
        self:RemoveWindowList(winName)
    end

    win:CloseWindow(not isCurWindow)
end


function ViewManager:RemoveWindowList(windowName)
    local len = #self.windowList
    if len<=0 then return end

    local index = nil
    for i=len,1,-1 do 
        if self.windowList[i] == windowName then 
            index = i 
            break 
        end
    end
    if not index then return end
    table.remove(self.windowList,index)
end

function ViewManager:GetWindow(windowName)
    return self.windows[windowName]
end

function ViewManager:HasWindow(win)
    local winName = win.__className
    local win = self.windows[winName]
    return win and win:Active() or false
end

function ViewManager:HasView()
    return #self.windowList > 0
end

function ViewManager:IsOpenWindow(win)
    local winName = win.__className
    local window = self.windows[winName]
    return window and window:Active()
end

function ViewManager:GetShowWindowTotal()

end

function ViewManager:GetMaxOrderLayer()
    self.orderLayer = self.orderLayer + GDefine.EffectOrderAdd * 2
    return self:GetCurOrderLayer()
end

function ViewManager:GetCurOrderLayer()
    return self.orderLayer
end

function ViewManager:IsExistWindow()
end

function ViewManager:AddOrderLayer(val)
    self.orderLayer = self.orderLayer + val
end

function ViewManager:CloseAllWindow()
    for k,v in pairs(self.windows) do v:CloseWindow(true) end
    self.windowList = {}
    self.curWindow = nil
    self.readyOpenWindow = nil
    self.readyCloseWindow = nil
    self.orderLayer = 10
    self:CheckMainui() 
end

function ViewManager:CleanAllWindow()
    for k,v in pairs(self.windows) do v:Destroy() end
    self.windowList = {}
    self.windows = {}
    self.curWindow = nil
    self.readyOpenWindow = nil
    self.readyCloseWindow = nil
    self.orderLayer = 10
    self.checkMainui = true
end

function ViewManager:CreateTopCanvas()
    self.topCanvasObj = GameObject("TopCanvas")
    local transform = self.topCanvasObj:AddComponent(RectTransform)
    UIUtils.AddPanel(ctx.CanvasContainer.transform, transform)

    Utils.ChangeLayersRecursively(transform, "UI")

    self.topCanvasObj:AddComponent(CanvasRenderer)
    
    local canvas = self.topCanvasObj:AddComponent(Canvas)
    canvas.additionalShaderChannels = ctx.CanvasContainer:GetComponent(Canvas).additionalShaderChannels
    canvas.overrideSorting = true
    canvas.sortingOrder = self.topCanvasSortingOrder
    canvas.worldCamera = UIDefine.uiCamera

    self.topCanvasObj:AddComponent(GraphicRaycaster)
end

function ViewManager:GetCurWinLayer()
    local cur = self.windows[self.curWindow]
    if not cur then
        return 0
    end
    return cur.rootCanvas.sortingOrder
end


function ViewManager:GetWindowParent()
    local windowParent = PoolManager.Instance:Pop(PoolType.object,PoolDefine.PoolKey.window_parent)
    if not windowParent then
        local parentObjAssets = PreloadManager.Instance:GetAsset(AssetPath.windowParent)
        windowParent = GameObject.Instantiate(parentObjAssets)
    end
    return windowParent
end

function ViewManager:GetPanelParent()
    local panelParent = PoolManager.Instance:Pop(PoolType.object,PoolDefine.PoolKey.panel_parent)
    if not panelParent then
        local parentObjAssets = PreloadManager.Instance:GetAsset(AssetPath.panelParent)
        panelParent = GameObject.Instantiate(parentObjAssets)
    end
    return panelParent
end

function ViewManager:Adaptive(rectTrans,adaptiveTop,adaptiveBottom)
    if not rectTrans then
        return
    end

    local topAdaptiveHeight = DevicesManager.Instance:GetNotch()
    if adaptiveTop and topAdaptiveHeight > 0 then
        rectTrans.offsetMax = Vector2(0.0,-topAdaptiveHeight)
    end

    local bottomAdaptiveHeight = 0
    if adaptiveBottom and bottomAdaptiveHeight > 0 then
        rectTrans.offsetMin = Vector2(0.0,bottomAdaptiveHeight)
    end
end

function ViewManager:HasView()
    return not TableUtils.IsEmpty(self.windows)
end