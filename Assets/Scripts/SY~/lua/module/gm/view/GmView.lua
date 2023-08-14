GmView = BaseClass("GmView",BaseView)

GmView.Event = EventEnum.New(
	"ActiveGm"
)

function GmView:__Init()
    self:SetAsset("ui/prefab/gm/gm.prefab", AssetType.Prefab)
end

function GmView:__CacheObject()

end

function GmView:__BindListener()
    self:Find("gm_btn",Button):SetClick(self:ToFunc("OpenGm"))
end

function GmView:__BindEvent()
	self:BindEvent(GmView.Event.ActiveGm)
end

function GmView:__Create()
    self:SetOrder()
end

function GmView:__Show()
    self.gameObject:SetActive(IS_DEBUG)
end

function GmView:OpenGm()
    ViewManager.Instance:OpenWindow(GmWindow)
end

function GmView:ActiveGm(flag)
    self.gameObject:SetActive(flag)
end