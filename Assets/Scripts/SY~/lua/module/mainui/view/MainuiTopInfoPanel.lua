MainuiTopInfoPanel = BaseClass("MainuiTopInfoPanel",ExtendView)

MainuiTopInfoPanel.Event = EventEnum.New(
)

function MainuiTopInfoPanel:__Init()

end

function MainuiTopInfoPanel:__CacheObject()
    self:CacheRoleInfo()
    self:CacheAssetInfo()
end

function MainuiTopInfoPanel:CacheRoleInfo()
    self.roleName = self:Find("top_canvas/player/txt_name",Text)
    self.headIcon = self:Find("top_canvas/player/img_bg/img_icon",Image)
    self.btnHead = self:Find("top_canvas/player",Button)
end

function MainuiTopInfoPanel:CacheAssetInfo()
    self.imgCoin = self:Find("top_canvas/gold/img_icon",Image)
    self.coinNum = self:Find("top_canvas/gold/txt_num",Text)
    self.imgDiamond = self:Find("top_canvas/diamond/img_icon",Image)
    self.diamondNum = self:Find("top_canvas/diamond/txt_num",Text)
end

function MainuiTopInfoPanel:__BindEvent()
end

function MainuiTopInfoPanel:__BindListener()
    self.btnHead:SetClick(self:ToFunc("OnHeadButtonClick"))
end

function MainuiTopInfoPanel:__Create()
    EventManager.Instance:AddEvent(EventDefine.refresh_role_item,self:ToFunc("RefreshRoleItem"))
end

function MainuiTopInfoPanel:__Show()
    self.roleData = mod.RoleProxy:GetRoleData()
    self:ShowRoleBaseData()
    self:RefreshRoleItem()
end

function MainuiTopInfoPanel:ShowRoleBaseData()
    self.roleName.text = self.roleData.name or TI18N("无名氏")
    -- self.roleGuild.text = self.roleData.guild or TI18N("无部落")
end

function MainuiTopInfoPanel:RefreshRoleItem()
    self.coinNum.text = mod.RoleItemProxy:GetItemNum(GDefine.Assets.coin)
    self.diamondNum.text = mod.RoleItemProxy:GetItemNum(GDefine.Assets.diamond)
end

function MainuiTopInfoPanel:OnHeadButtonClick()
    mod.PersonalInfoCtrl:OpenPersonalInfo({
        uid = mod.RoleProxy:GetRoleData().role_uid
    })
end