FriendAddAndSearchItem = BaseClass("FriendAddAndSearchItem", BaseView)

function FriendAddAndSearchItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
end

function FriendAddAndSearchItem:__Delete()
end

function FriendAddAndSearchItem:__CacheObject()
    self.btn = self:Find(nil,Button)
    self.btnHead = self:Find("head",Button)
    self.imgIcon = self:Find("img_head",Image)
    self.txtName = self:Find("txt_name",Text)
    self.txtTrophy = self:Find("trophy/txt_trophy",Text)
    self.txtLv = self:Find("head/image_19/txt_lv",Text)
    self.btnAdd = self:Find("btn_add",Button)
    self.objSend = self:Find("img_send").gameObject
end

function FriendAddAndSearchItem:__Create()
end

function FriendAddAndSearchItem:__BindListener()
    self.btnAdd:SetClick(self:ToFunc("OnAddButtonClick"))
    self.btn:SetClick(self:ToFunc("OnItemClick"))
    self.btnHead:SetClick(self:ToFunc("OnHeadBtnClick"))
end

--[[
    data = {
    }
]]--
function FriendAddAndSearchItem:SetData(data, index, parentWindow)
    self.data = data
    self.index = index
    self.parentWindow = parentWindow
    self.rootCanvas = parentWindow.rootCanvas
    self:RefreshStyle()
end

function FriendAddAndSearchItem:RefreshStyle()
    self.txtName.text = self.data.name
    self.txtTrophy.text = self.data.trophy
    self:RefreshSendButton()
end

function FriendAddAndSearchItem:RefreshSendButton()
    local hasSend = mod.FriendProxy.tbTempSendApply[self.data.role_uid] or false
    local showAdd = false
    local showSend = false

    if mod.FriendProxy:IsFriend(self.data.role_uid) then
        showAdd = false
        showSend = false
    elseif mod.FriendProxy:IsLocal(self.data.role_uid) then
        showAdd = false
        showSend = false
    else
        if hasSend then
            showAdd = false
            showSend = true
        else
            showAdd = true
            showSend = false
        end
    end

    self.objSend:SetActive(showSend)
    self.btnAdd.gameObject:SetActive(showAdd)
end

function FriendAddAndSearchItem:OnRecycle()

end

function FriendAddAndSearchItem:OnAddButtonClick()
    mod.FriendProxy:SendMsg(11902, self.data.role_uid)
    self.btnAdd.gameObject:SetActive(false)
    self:RefreshSendButton()
end

function FriendAddAndSearchItem:OnItemClick()
    -- mod.PersonalInfoCtrl:OpenPersonalInfo({
    --     uid = self.data.role_uid
    -- })
end

function FriendAddAndSearchItem:OnHeadBtnClick()
    mod.PersonalInfoCtrl:OpenPersonalInfo({
        uid = self.data.role_uid
    })
end

--#region 静态方法

function FriendAddAndSearchItem.Create(template)
    local item = FriendAddAndSearchItem.New()
    item:SetObject(GameObject.Instantiate(template))
    item:Show()
    return item
end

--#endregion