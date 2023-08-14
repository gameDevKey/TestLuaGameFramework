BasePanel = BaseClass("BasePanel",BaseView)

function BasePanel:__Init()
    self:SetViewType(UIDefine.ViewType.panel)
    self:CreateRoot()
end

function BasePanel:__Delete()
    PoolManager.Instance:Push(PoolType.object,PoolDefine.PoolKey.panel_parent,self.rootObj)
end

function BasePanel:CreateRoot()
    self.rootObj = ViewManager.Instance:GetPanelParent()
    self.rootTrans = self.rootObj.transform
    self.rootObj.name = self.__className
    self.rootTrans.offsetMin = Vector2.zero
    self.rootTrans.offsetMax = Vector2.zero
end

function BasePanel:SetParent(parent,x,y,z)
    self.refreshParent = true
    self.parent = self.rootTrans:Find("view")
    self.rootTrans:SetParent(parent,false)
end

function BasePanel:__BaseCreate()
    self:InitCreate()
end

function BasePanel:InitCreate()
    -- self.rootCanvas = self:Find(nil,Canvas)
    if self.rootCanvas then
        self.rootCanvas.overrideSorting = true
        self.rootCanvas.sortingOrder = ViewDefine.Layer[self.__className] or ViewManager.Instance:GetMaxOrderLayer()
    end

    if self.__adaptiveTop or self.__adaptiveBottom then
        ViewManager.Instance:Adaptive(self:Find("main",RectTransform),self.__adaptiveTop,self.__adaptiveBottom)
    end
end

function BasePanel:SetWindowSize(width,height)
    UnityUtils.setSizeDelata(self.rectTrans,width,height)
end

function BasePanel:__BaseLoadAsset()
    --判断对象池是否存在此对象
    if not self.assetPath then
        assert(false, "UI资源路径为空，请调用SetAsset接口设置") 
    end
    self:MergeAsset()
end
