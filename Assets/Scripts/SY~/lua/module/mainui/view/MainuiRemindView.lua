MainuiRemindView = BaseClass("MainuiRemindView",ExtendView)

function MainuiRemindView:__Init()
    self.remindItems = {}
end

function MainuiRemindView:__Delete()
    for i,v in ipairs(self.remindItems) do
        v:Destroy()
    end
end

function MainuiRemindView:__CacheObject()
end

function MainuiRemindView:__Create()
    --段位
    local divisonLvReddot = MarkRemindItem.New()
    table.insert(self.remindItems,divisonLvReddot)
    divisonLvReddot:SetParent(self:Find("main/division_func/reddot"))
    divisonLvReddot:SetRemindId(RemindDefine.RemindId.division_up)

    -- local divisonRewardReddot = CustomRemindItem.New(self:Find("main/division_func/img_reward").gameObject)
    -- table.insert(self.remindItems,divisonRewardReddot)
    -- divisonRewardReddot:SetRemindId(RemindDefine.RemindId.division_reward)

    --抽卡
    local drawcardReddot = MarkRemindItem.New()
    table.insert(self.remindItems,drawcardReddot)
    drawcardReddot:SetParent(self:Find("main/draw_card_btn/reddot"))
    drawcardReddot:SetRemindId(RemindDefine.RemindId.draw_card_ticket)

    --战令
    -- local battlepassReddot = CustomRemindItem.New(self:Find("main/battlepass_func/img_reward").gameObject)
    -- table.insert(self.remindItems,battlepassReddot)
    -- battlepassReddot:SetRemindId(RemindDefine.RemindId.battlepass_reward)

    --任务
    local taskRemind = MarkRemindItem.New()
    table.insert(self.remindItems,taskRemind)
    taskRemind:SetParent(self:Find("main/daily_task_btn/remind_node"))
    taskRemind:SetRemindId(RemindDefine.RemindId.task)

    local taskEffectRemind = EffectRemindItem.New()
    table.insert(self.remindItems,taskEffectRemind)
    local effectSetting = {}
    effectSetting.confId = 10045
    effectSetting.order = self:GetOrder() + 1
    taskEffectRemind:SetEffect(effectSetting)
    taskEffectRemind:SetParent(self:Find("main/daily_task_btn/effect_remind_node"))
    taskEffectRemind:SetRemindId(RemindDefine.RemindId.task_receive)
    


    --战斗
    local battleRemind = NormalRemindItem.New()
    table.insert(self.remindItems,battleRemind)
    battleRemind:SetParent(self:Find("bottom_canvas/img_bg/tab_3/remind_node"))
    battleRemind:SetRemindId({{{RemindDefine.RemindId.pve_sweep},{RemindDefine.RemindId.pve_award}}})


    --pve入口
    -- local pveEnterRemind = NormalRemindItem.New()
    -- table.insert(self.remindItems,pveEnterRemind)
    -- pveEnterRemind:SetParent(self:Find("main/enter_pve_btn/remind_node"))
    -- pveEnterRemind:SetRemindId({{{RemindDefine.RemindId.pve_sweep},{RemindDefine.RemindId.pve_award}}})

    --藏品
    local collectionRemind = NormalRemindItem.New()
    table.insert(self.remindItems,collectionRemind)
    collectionRemind:SetParent(self:Find("bottom_canvas/tab_2/remind_node"))
    collectionRemind:SetRemindId({{{RemindDefine.RemindId.collection_new_unit},{RemindDefine.RemindId.collection_embattled_card_can_upgrade}}})

    --统领
    local commanderRemind = NormalRemindItem.New()
    table.insert(self.remindItems,commanderRemind)
    commanderRemind:SetParent(self:Find("bottom_canvas/img_bg/tab_4/remind_node"))
    commanderRemind:SetRemindId({{{RemindDefine.RemindId.commander_open_chest}
        ,{RemindDefine.RemindId.commander_chest_exist_equip}
        ,{RemindDefine.RemindId.commander_chest_intensify}
        ,{RemindDefine.RemindId.commander_chest_up_lev}}})

    --邮件
    -- local emailRemind = NormalRemindItem.New()
    -- table.insert(self.remindItems,emailRemind)
    -- emailRemind:SetParent(self:Find("main/friend_btn/remind_node"))
    -- emailRemind:SetRemindId(RemindDefine.RemindId.email_unread)

    --商店
    local shopRemind = NormalRemindItem.New()
    table.insert(self.remindItems,shopRemind)
    shopRemind:SetParent(self:Find("bottom_canvas/img_bg/tab_1/remind_node"))
    shopRemind:SetRemindId(RemindDefine.RemindId.shop_free_can_buy)

    --好友
    local friendRemind = NormalRemindItem.New()
    table.insert(self.remindItems,friendRemind)
    friendRemind:SetParent(self:Find("main/friend_btn/reddot"))
    friendRemind:SetRemindId(RemindDefine.RemindId.friend_entrance)
end

function MainuiRemindView:__BindListener()

end

function MainuiRemindView:__BindEvent()

end

function MainuiRemindView:__Hide()
end

function MainuiRemindView:__Show()

end