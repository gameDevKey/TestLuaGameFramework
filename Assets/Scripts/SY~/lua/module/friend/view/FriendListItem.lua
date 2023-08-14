FriendListItem = BaseClass("FriendListItem", BaseView)

function FriendListItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
end

function FriendListItem:__Delete()
end

function FriendListItem:__CacheObject()
    self.btn = self:Find(nil,Button)
    self.btnHead = self:Find("head",Button)
    self.btnDelete = self:Find("btn_delete",Button)
    self.imgIcon = self:Find("img_icon",Image)
    self.txtName = self:Find("txt_name",Text)
    self.txtTrophy = self:Find("trophy/txt_trophy",Text)
    self.txtState = self:Find("txt_state",Text)
    self.txtLv = self:Find("head/image_19/txt_lv",Text)
end

function FriendListItem:__Create()
end

function FriendListItem:__BindListener()
    self.btn:SetClick(self:ToFunc("OnButtonClick"))
    self.btnHead:SetClick(self:ToFunc("OnHeadBtnClick"))
    self.btnDelete:SetClick(self:ToFunc("OnDeleteButtonClick"))
end

--[[
    data = {
        string name = 1;                            // 玩家名字
        string role_uid = 2;                        // 玩家唯一id
        uint32 trophy = 3;                          // 当前杯数
        uint32 is_online = 4;                       // 在线  1-是 2-否
        uint32 last_logout_time = 5;                // 上次登出时间
        string face_id = 6;                         // 头像
    }
]]--
function FriendListItem:SetData(data, index, parentWindow)
    self.data = data
    self.index = index
    self.parentWindow = parentWindow
    self.rootCanvas = parentWindow.rootCanvas
    self:RefreshStyle()
end

function FriendListItem:RefreshStyle()
    self.txtName.text = self.data.name
    self.txtTrophy.text = self.data.trophy
    self.txtState.text = FriendProxy.GetLoginStateShowStr(self.data.is_online,self.data.last_logout_time)
    self.txtState.color = self.data.is_online == FriendDefine.OnlineState.Online and FriendDefine.ONLINE_TXT_COLOR or FriendDefine.OFFLINE_TXT_COLOR

    if self.data.isDeleteMode then
        self.btnDelete.gameObject:SetActive(true)
        self.txtState.gameObject:SetActive(false)
    else
        self.btnDelete.gameObject:SetActive(false)
        self.txtState.gameObject:SetActive(true)
    end
end

function FriendListItem:OnRecycle()

end

function FriendListItem:OnButtonClick()
    -- mod.PersonalInfoCtrl:OpenPersonalInfo({
    --     uid = self.data.role_uid
    -- })
end

function FriendListItem:OnDeleteButtonClick()
    mod.FriendCtrl:ReqDelFriendByDialog(self.data.role_uid)
end

function FriendListItem:OnHeadBtnClick()
    mod.PersonalInfoCtrl:OpenPersonalInfo({
        uid = self.data.role_uid
    })
end

--#region 静态方法

function FriendListItem.Create(template)
    local item = FriendListItem.New()
    item:SetObject(GameObject.Instantiate(template))
    item:Show()
    return item
end

--#endregion