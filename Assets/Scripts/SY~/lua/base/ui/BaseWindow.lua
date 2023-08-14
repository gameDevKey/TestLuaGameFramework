BaseWindow = BaseClass("BaseWindow",BaseView)
BaseWindow.isWindow = true

function BaseWindow:__Init()
    self.winName = self.__className
    self:SetViewType(UIDefine.ViewType.window)
    self.cacheMode = UIDefine.CacheMode.destroy
    self.assetPath = nil

    self:CreateRoot()
end

function BaseWindow:__Delete()
    PoolManager.Instance:Push(PoolType.object,PoolDefine.PoolKey.window_parent,self.rootObj)
end

function BaseWindow:CreateRoot()
    self.rootObj = ViewManager.Instance:GetWindowParent()
    self.rootTrans = self.rootObj.transform
    self.rootObj.name = self.winName
    self.rootTrans.offsetMin = Vector2.zero
    self.rootTrans.offsetMax = Vector2.zero
end

function BaseWindow:SetCacheMode(mode)
    self.cacheMode = mode 
end

function BaseWindow:CloseWindow(imm)
    self.isDeleteWindow = true
    if imm then 
        self:CloseComplete()
    else
        self:Hide()
    end
end

function BaseWindow:TempHideWindow()
    self:SetActive(self.rootTrans,false)
end

function BaseWindow:TempShowWindow()
    self:SetActive(self.rootTrans,true)
end

function BaseWindow:CloseComplete()
    if self.cacheMode == UIDefine.CacheMode.hide then
        self:HideHandle()
    elseif self.cacheMode == UIDefine.CacheMode.destroy then
        self:Destroy()
        ViewManager.Instance:RemoveWindow(self.winName)
    end
    ViewManager.Instance:CloseComplete(self.winName)
end

function BaseWindow:SetParent(parent,x,y,z)
    self.refreshParent = true
    self.parent = self.rootTrans:Find("view")

    self.rootTrans:SetParent(parent,false)
end

function BaseWindow:OnOpenParse(args)
    --if not self:isExistTab() then return end
    --local tabIndex = 1
    --if args ~= nil then tabIndex = args.tab or 1 end
    --self:getTab():onTabClick(tabIndex)
end

function BaseWindow:__BaseCreate()
    self:InitCreate()
end

function BaseWindow:InitCreate()
    -- self.rootCanvas = self:Find(nil,Canvas)
    self.rootCanvas.overrideSorting = true
    self.rootCanvas.sortingOrder = ViewDefine.Layer[self.winName] or ViewManager.Instance:GetMaxOrderLayer()

    if self.__adaptiveTop or self.__adaptiveBottom then
        ViewManager.Instance:Adaptive(self:Find("main",RectTransform),self.__adaptiveTop,self.__adaptiveBottom)
    end
end

function BaseWindow:__BaseShow()
    self:OnOpenParse(self.args)
end

function BaseWindow:__BaseHide()
    assert(self.isDeleteWindow,string.format("window对象禁止直接调用Hide方法! ==> 改用(ViewManager.Instance:CloseWindow)",tostring(self.winName)))
end

function BaseWindow:__ShowComplete()
    ViewManager.Instance:OpenComplete(self)
end

function BaseWindow:SetWindowSize(width,height)
    UnityUtils.setSizeDelata(self.rectTrans,width,height)
end

function BaseWindow:OnCloseClick()
    ViewManager.Instance:CloseWindow(self.winName)
end
