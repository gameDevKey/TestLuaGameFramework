--[[
    UI界面基类
    1.可选择性实现'#region 虚函数'
    2.界面加载完成后，可直接访问self.gameObject/self.transform等等变量，具体看ViewAssetLoaded()逻辑
]]
--
UIBase = Class("UIBase", ModuleBase)
local _ = UIBaseExtend

function UIBase:OnInit(uiType)
    self.uiType = uiType
end

function UIBase:OnDelete()
    if self.gameObject then
        UnityUtil.DestroyGameObject(self.gameObject)
        self.gameObject = nil
    end
end

---关联一个ViewCtrl
function UIBase:SetViewCtrl(ctrl)
    self.viewCtrl = ctrl
    self:SetFacade(ctrl.facade)
end

function UIBase:GetViewCtrl()
    return self.viewCtrl
end

--关联一个UI缓存处理类
function UIBase:SetCacheHandler(handler)
    self.cacheHandler = handler
end

function UIBase:GetCacheHandler()
    return self.cacheHandler
end

function UIBase:RecycleOrDelete()
    local handler = self:GetCacheHandler()
    if handler then
        local pool = CacheManager.Instance:GetPool(CacheDefine.PoolType.UI, true)
        pool:Recycle(self.uiType, handler)
    else
        self:Delete()
    end
end

--设置界面资源路径
function UIBase:SetAssetPath(path)
    self.uiAssetPath = path
end

--界面资源初始化
function UIBase:SetupViewAsset(gameObject)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.rectTransform = self.gameObject:GetComponent(typeof(UnityEngine.RectTransform))
    self:AfterSetupViewAsset()
end

--与SetupViewAsset()保持一致
function UIBase:SetupViewAssetFromView(view)
    self.gameObject = view.gameObject
    self.transform = view.transform
    self.rectTransform = view.rectTransform
    self:AfterSetupViewAsset()
end

function UIBase:AfterSetupViewAsset()
    self:CallFuncDeeply("OnFindComponent", true)
    self:CallFuncDeeply("OnInitComponent", true)
    self:CallFuncDeeply("OnSetupViewAsset", true, self.gameObject)
end

---进入界面(只能被外界调用，子类不要调用)
function UIBase:Enter(data)
    self:CallFuncDeeply("OnEnter", false, data)
end

---进入界面完成，界面进入可能是一个耗时的操作（受到加载或者入场动画的影响）
function UIBase:EnterComplete()
    self:CallFuncDeeply("OnEnterComplete", false)
end

---上级界面退出后，当前界面重新显示出来
function UIBase:Refresh()
    self:CallFuncDeeply("OnRefresh", false)
end

---上级界面入场后，当前界面暂时隐藏
function UIBase:Hide()
    self:CallFuncDeeply("OnHide", false)
end

--#region 虚函数(生命周期)

function UIBase:OnEnter(data) end

function UIBase:OnEnterComplete() end

function UIBase:OnRefresh() end

function UIBase:OnHide() end

--#endregion

--#region 虚函数(行为)

function UIBase:OnFindComponent() end

function UIBase:OnInitComponent() end

function UIBase:OnSetupViewAsset() end

--#endregion

return UIBase
