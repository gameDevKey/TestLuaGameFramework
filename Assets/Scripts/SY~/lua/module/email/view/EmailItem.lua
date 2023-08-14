EmailItem = BaseClass("EmailItem", BaseView)
EmailItem.MAX_AWARD_SHOW = 2

function EmailItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
    self.tbItem = {}
end

function EmailItem:__Delete()
    self:RemoveAllAwardItem()
end

function EmailItem:__CacheObject()
    self.canvasGroup = self:Find("content",CanvasGroup)
    self.txtTitle = self:Find("content/txt_title",Text)
    self.txtValidTime = self:Find("content/txt_valid",Text)
    -- self.txtRecvTime = self:Find("content/txt_sendtime",Text)
    self.imgIcon = self:Find("content/img_icon",Image)
    self.btnDetail = self:Find(nil,Button)
    self.contentAward = self:Find("content/list_award")
    self.objMore = self:Find("content/img_more").gameObject
end

function EmailItem:__Create()
    self:AddAnimDelayPlayListener("email_main_panel_open",self:ToFunc("OnAnimDelayPlay"))
end

function EmailItem:__BindListener()
    self.btnDetail:SetClick(self:ToFunc("OnDetailButtonClick"))
end

--[[
    data = {
        uint32 id = 1;                           // 玩家邮件唯一ID
        uint32 send_time = 2;                    // 发送日期   时间戳
        string sender_name = 3;                  // 发送者
        uint32 sender_uid = 4;                   // 发送者uid
        uint32 out_time = 5;                     // 过期时间  时间戳
        string title = 6;                        // 标题
        string content = 7;                      // 邮件内容
        uint32 read = 8;                         // 是否已读 1-未读 2-已读
        uint32 get = 9;                          // 奖励是否已领取 1-未领取 2-已领
        repeated pt_item reward_list = 10;       // 奖励
    }
]]--
function EmailItem:SetData(data, index, parentWindow)
    self.data = data
    self.index = index
    self.parentWindow = parentWindow
    self.rootCanvas = parentWindow.rootCanvas
    self:RefreshStyle()
end

function EmailItem:RefreshStyle()
    self.txtTitle.text = self.data.title
    -- self.txtRecvTime.text = self:GetRecvTimeShowStr(self.data.send_time)
    self.txtValidTime.text = EmailItem.GetValidTimeShowStr(self.data.out_time)
    self:LoadAllAwardItem()
    if self.data.read == EmailDefine.ReadState.Read then
        self.canvasGroup.alpha = 0.7
    else
        self.canvasGroup.alpha = 1
    end
end

-- function EmailItem:GetRecvTimeShowStr(timestamp)
--     local diff = os.time() - timestamp
--     if diff <= 0 then
--         return "来自未来?"
--     end
--     local str = TimeUtils.GetTimeFormatDayVII(diff)
--     return string.format("%s前",str)
-- end

function EmailItem:OnDetailButtonClick()
    mod.EmailFacade:SendEvent(EmailFacade.Event.ShowEmailDetailView, self.data)
    if self.data.read == EmailDefine.ReadState.Unread then
        if TableUtils.IsEmpty(self.data.reward_list) then
            mod.EmailFacade:SendMsg(11702, self.data.id)
        end
    end
end

function EmailItem:LoadAllAwardItem()
    self:RemoveAllAwardItem()
    for i = 1, EmailItem.MAX_AWARD_SHOW do
        local sc = self.data.reward_list[i]
        if not sc then
            break
        end
        local itemData = {}
        itemData.item_id = sc.item_id
        itemData.count = sc.count
        local propItem = PropItem.Create()
        propItem:SetParent(self.contentAward)
        propItem.transform:Reset()
        propItem:Show()
        propItem:SetData(itemData)
        propItem:SetScale(0.8,0.8)
        table.insert(self.tbItem, propItem)
    end
    self.objMore:SetActive(#self.data.reward_list > EmailItem.MAX_AWARD_SHOW)
end

function EmailItem:RemoveAllAwardItem()
    for _, item in ipairs(self.tbItem) do
        item:Destroy()
    end
    self.tbItem = {}
end

function EmailItem:OnRecycle()
    self:RemoveAllAwardItem()
end

function EmailItem:OnAnimDelayPlay()
    self:PlayAnim("email_item")
end

--#region 静态方法

function EmailItem.Create(template)
    local item = EmailItem.New()
    item:SetObject(GameObject.Instantiate(template))
    item:Show()
    return item
end

function EmailItem.GetValidTimeShowStr(timestamp)
    local diff = timestamp - os.time()
    if diff <= 0 then
        return "已过期"
    end
    local _,data = TimeUtils.GetTimeFormatDayVII(diff)
    local name = "秒"
    if data.type == "day" then
        name = "天"
    elseif data.type == "hour" then
        name = "小时"
    elseif data.type == "min" then
        name = "分钟"
    end
    return string.format("剩余<color=#219EF6>%d</color>%s",data.num,name)
end

--#endregion