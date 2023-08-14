FriendBlackListItem = BaseClass("FriendBlackListItem", BaseView)

function FriendBlackListItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
end

function FriendBlackListItem:__Delete()
end

function FriendBlackListItem:__CacheObject()
    self.btn = self:Find(nil,Button)
    self.btnHead = self:Find("head",Button)
    self.imgIcon = self:Find("img_head",Image)
    self.txtName = self:Find("txt_name",Text)
    self.txtTrophy = self:Find("trophy/txt_trophy",Text)
    self.txtState = self:Find("txt_state",Text)
    self.btnRemove = self:Find("btn_remove",Button)
    self.txtLv = self:Find("head/image_19/txt_lv",Text)
end

function FriendBlackListItem:__Create()
end

function FriendBlackListItem:__BindListener()
    self.btn:SetClick(self:ToFunc("OnItemClick"))
    self.btnHead:SetClick(self:ToFunc("OnHeadBtnClick"))
    self.btnRemove:SetClick(self:ToFunc("OnRemoveButtonClick"))
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
function FriendBlackListItem:SetData(data, index, parentWindow)
    self.data = data
    self.index = index
    self.parentWindow = parentWindow
    self.rootCanvas = parentWindow.rootCanvas
    self:RefreshStyle()
end

function FriendBlackListItem:RefreshStyle()
    self.txtName.text = self.data.name
    self.txtTrophy.text = self.data.trophy
    self.txtState.text = FriendProxy.GetLoginStateShowStr(self.data.is_online,self.data.last_logout_time)
    self.txtState.color = self.data.is_online == FriendDefine.OnlineState.Online and FriendDefine.ONLINE_TXT_COLOR or FriendDefine.OFFLINE_TXT_COLOR
end

function FriendBlackListItem:OnRecycle()

end

function FriendBlackListItem:OnRemoveButtonClick()
    mod.FriendProxy:SendMsg(11911,self.data.role_uid)
end

function FriendBlackListItem:OnItemClick()
    -- mod.PersonalInfoCtrl:OpenPersonalInfo({
    --     uid = self.data.role_uid
    -- })
end

function FriendBlackListItem:OnHeadBtnClick()
    mod.PersonalInfoCtrl:OpenPersonalInfo({
        uid = self.data.role_uid
    })
end

--#region 静态方法

function FriendBlackListItem.Create(template)
    local item = FriendBlackListItem.New()
    item:SetObject(GameObject.Instantiate(template))
    item:Show()
    return item
end

--#endregion