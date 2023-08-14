PlayerGuideView = BaseClass("PlayerGuideView",BaseView)

PlayerGuideView.Event = EventEnum.New(
    "LockScreen",
    "AddChildView",
    "RemoveChildView",
    "RemoveAllChildView",
    "AddEffect",
    "RemoveEffect",
    "ActiveListenPointer",
    "ShowMask",
    "ShowHoleMask"
)

function PlayerGuideView:__Init()
    self.childViews = {}
    self.effects = {}

    self.OnPointerDown = self:ToFunc("PointerDown")
    self.OnPointerUp = self:ToFunc("PointerUp")
    self.OnPointerClick = self:ToFunc("PointerClick")

    self.isLockScreen = false
    self.isShowMask = false
    self.isShowHoleMask = false
end

function PlayerGuideView:__CacheObject()
    self.lockScreenNode = self:Find("lock_screen").gameObject
    self.listenPointerNode = self:Find("listen_pointer").gameObject
    self.contentTrans = self:Find("content")
    self.pointerHandler = self.listenPointerNode:GetComponent(PointerHandler)
    self.maskNode = self:Find("mask").gameObject
    self.imgholeMask = self:Find("hole_mask",Image)
    self.holeMaskMat = self.imgholeMask.material

    PlayerGuideDefine.contentTrans = self.contentTrans
end

function PlayerGuideView:__BindListener()
end

function PlayerGuideView:__BindLastingEvent()
    self:BindLastingEvent(PlayerGuideView.Event.LockScreen)
    self:BindLastingEvent(PlayerGuideView.Event.AddChildView)
    self:BindLastingEvent(PlayerGuideView.Event.RemoveChildView)
    self:BindLastingEvent(PlayerGuideView.Event.RemoveAllChildView)
    self:BindLastingEvent(PlayerGuideView.Event.AddEffect)
    self:BindLastingEvent(PlayerGuideView.Event.RemoveEffect)
    self:BindLastingEvent(PlayerGuideView.Event.ActiveListenPointer)
    self:BindLastingEvent(PlayerGuideView.Event.ShowMask)
    self:BindLastingEvent(PlayerGuideView.Event.ShowHoleMask)
end

function PlayerGuideView:__Create()
    self.pointerHandler:SetOwner(self,"OnPointerDown","OnPointerUp","OnPointerClick")
end

function PlayerGuideView:__Show()
    self:SetOrder()
end

function PlayerGuideView:LockScreen(flag)
    if self.isLockScreen ~= flag then
        self.lockScreenNode:SetActive(flag)
        self.isLockScreen = flag
    end
end

function PlayerGuideView:ShowMask(active)
    if self.isShowHoleMask then
        active = false --正在显示高亮节点的hole_mask时，mask就不要显示了，不然两个mask会重叠
    end
    if self.isShowMask ~= active then
        self.maskNode:SetActive(active)
        self.isShowMask = active
    end
end

function PlayerGuideView:GetCenterVector4(x,y,w,h)
    x = x or 0
    y = y or 0
    w = w or 100
    h = h or 100
    local x1 = x - w/2
    local y1 = y - h/2
    local x2 = x + w/2
    local y2 = y + h/2
    return Vector4(x1,y1,x2,y2)
end

function PlayerGuideView:ShowHoleMask(active,args)
    if self.isShowHoleMask ~= active then
        self.isShowHoleMask = active
        self.imgholeMask.gameObject:SetActive(active)
        if active and args then
            local maskType = args.shape or 0 -- 0: 圆形 1:菱形 2:矩形
            self.holeMaskMat:SetFloat("_MaskType",maskType)
            if maskType == 0 then
                self.holeMaskMat:SetFloat("_Radius",(args.radius or 100))
                self.holeMaskMat:SetVector("_Center",Vector4((args.centerX or 0),(args.centerY or 0),1,1))
            elseif maskType == 1 then
                self.holeMaskMat:SetVector("_DiamondParameter",Vector4((args.centerX or 0),(args.centerY or 0),(args.side or 100),1))
            else
                self.holeMaskMat:SetVector("_Rectangle",self:GetCenterVector4(args.centerX,args.centerY,args.w,args.h))
            end
            local alpha = args.alpha or 1
            self.imgholeMask.color = Color(0,0,0,alpha)
        end
    end
end

function PlayerGuideView:AddEffect(effect,x,y)
    self.effects[effect] = true
    effect:SetParent(self.contentTrans)
end

function PlayerGuideView:RemoveEffect(effect)
    self.effects[effect] = nil
    effect:Destroy()
end

function PlayerGuideView:AddChildView(view,args,x,y,hide)
    self.childViews[view] = true
    view:SetParent(self.contentTrans,x,y)
    if hide then
        view:Hide()
    else
        view:Show(args)
    end
end

function PlayerGuideView:RemoveChildView(view)
    self.childViews[view] = nil
    view:Destroy()
end

function PlayerGuideView:RemoveAllChildView()
    for view, _ in pairs(self.childViews) do
        self:RemoveChildView(view)
    end
end

function PlayerGuideView:ActiveListenPointer(flag)
    self.listenPointerNode:SetActive(flag)
end

function PlayerGuideView:PointerDown(pointerData,args)
    for iter in mod.PlayerGuideProxy.listenPointers:Items() do
        local callBacks = iter.value
        if callBacks.pointerDownCb then
            callBacks.pointerDownCb(pointerData,callBacks.args)
        end
    end
end

function PlayerGuideView:PointerUp(pointerData,args)
    for iter in mod.PlayerGuideProxy.listenPointers:Items() do
        local callBacks = iter.value
        if callBacks.pointerUpCb then
            callBacks.pointerUpCb(pointerData,callBacks.args)
        end
    end
end

function PlayerGuideView:PointerClick(pointerData,args)
    for iter in mod.PlayerGuideProxy.listenPointers:Items() do
        local callBacks = iter.value
        if callBacks.pointerClickCb then
            callBacks.pointerClickCb(pointerData,callBacks.args)
        end
    end
end