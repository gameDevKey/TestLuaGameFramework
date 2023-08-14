FriendApplyListItem = BaseClass("FriendApplyListItem", BaseView)

function FriendApplyListItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
end

function FriendApplyListItem:__Delete()
end

function FriendApplyListItem:__CacheObject()
    self.btn = self:Find(nil,Button)
    self.btnHead = self:Find("head",Button)
    self.imgIcon = self:Find("img_head",Image)
    self.txtName = self:Find("txt_name",Text)
    self.txtTrophy = self:Find("trophy/txt_trophy",Text)
    self.btnAllow = self:Find("btn_allow",Button)
    self.btnReject = self:Find("btn_reject",Button)
    self.txtLv = self:Find("head/image_19/txt_lv",Text)
end

function FriendApplyListItem:__Create()
end

function FriendApplyListItem:__BindListener()
    self.btn:SetClick(self:ToFunc("OnItemClick"))
    self.btnHead:SetClick(self:ToFunc("OnHeadBtnClick"))
    self.btnAllow:SetClick(self:ToFunc("OnAllowButtonClick"))
    self.btnReject:SetClick(self:ToFunc("OnRejectButtonClick"))
end

--[[
    data = {
    }
]]--
function FriendApplyListItem:SetData(data, index, parentWindow)
    self.data = data
    self.index = index
    self.parentWindow = parentWindow
    self.rootCanvas = parentWindow.rootCanvas
    self:RefreshStyle()
end

function FriendApplyListItem:RefreshStyle()
    self.txtName.text = self.data.name
    self.txtTrophy.text = self.data.trophy
end

function FriendApplyListItem:OnRecycle()

end

function FriendApplyListItem:OnAllowButtonClick()
    mod.FriendProxy:SendMsg(11910,self.data.role_uid,true)
end

function FriendApplyListItem:OnRejectButtonClick()
    mod.FriendProxy:SendMsg(11910,self.data.role_uid,false)
end

function FriendApplyListItem:OnItemClick()
    -- mod.PersonalInfoCtrl:OpenPersonalInfo({
    --     uid = self.data.role_uid
    -- })
end

function FriendApplyListItem:OnHeadBtnClick()
    mod.PersonalInfoCtrl:OpenPersonalInfo({
        uid = self.data.role_uid
    })
end

--#region 静态方法

function FriendApplyListItem.Create(template)
    local item = FriendApplyListItem.New()
    item:SetObject(GameObject.Instantiate(template))
    item:Show()
    return item
end

--#endregion