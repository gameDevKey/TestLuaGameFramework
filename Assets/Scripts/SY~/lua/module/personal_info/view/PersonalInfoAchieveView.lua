PersonalInfoAchieveView = BaseClass("PersonalInfoAchieveView",ExtendView)
PersonalInfoAchieveView.Event = EventEnum.New(
    "ShowAchieveView"
)

function PersonalInfoAchieveView:__Init()
    self.tbItem = {}
end

function PersonalInfoAchieveView:__CacheObject()
    self.view = self:Find("achieve_view").gameObject
    self.content = self:Find("achieve_view/sv/Viewport/Content")
    self.template = self:Find("achieve_view/sv/Viewport/Content/achieve_item").gameObject
    self.template:SetActive(false)
end

function PersonalInfoAchieveView:__Create()
end

function PersonalInfoAchieveView:__BindListener()

end

function PersonalInfoAchieveView:__BindEvent()
    self:BindEvent(PersonalInfoAchieveView.Event.ShowAchieveView)
end

function PersonalInfoAchieveView:__Show()
    self.view:SetActive(false)
end

function PersonalInfoAchieveView:__Hide()
    self:RemoveAllItem()
end

function PersonalInfoAchieveView:ShowAchieveView(data)
    self.view:SetActive(true)
    -- self:LoadAllItem(data.achieves) --TODO 读取玩家拥有的所有勋章
end

function PersonalInfoAchieveView:HideAchieveView()
    self.view:SetActive(false)
    self:RemoveAllItem()
end

function PersonalInfoAchieveView:LoadAllItem(datas)
    self:RemoveAllItem()
    for _, data in ipairs(datas) do
        local obj = GameObject.Instantiate(self.template)
        obj:SetActive(true)
        obj.transform:SetParent(self.content)
        obj.transform:Reset()
        local imgIcon = obj.transform:Find("img_icon"):GetComponent(Image)
        local objSelect = obj.transform:Find("select").gameObject
        local btn = obj:GetComponent(Button)
        btn:SetClick(self:ToFunc("OnItemClick"),data)
        table.insert(self.tbItem, obj)
    end
end

function PersonalInfoAchieveView:RemoveAllItem()
    for _, obj in ipairs(self.tbItem) do
        GameObject.Destroy(obj)
    end
    self.tbItem = {}
end

function PersonalInfoAchieveView:OnItemClick(data)
    self:HideAchieveView()
end