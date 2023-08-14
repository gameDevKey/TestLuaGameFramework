DrawCardAccChestItem = BaseClass("DrawCardAccChestItem", BaseView)

function DrawCardAccChestItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
    self.awardState = GDefine.AwardState.Lock
end

function DrawCardAccChestItem:__CacheObject()
    self.imgIcon = self:Find("img_icon",Image)
    self.txtNum = self:Find("txt_num",Text)
    self.btn = self:Find("btn",Button)
    self.objRecv = self:Find("img_recv").gameObject
end

function DrawCardAccChestItem:__Create()
end

function DrawCardAccChestItem:__BindListener()
    self.btn:SetClick(self:ToFunc("OnClick"))
end

function DrawCardAccChestItem:SetData(data, index)
    self.data = data
    self.index = index
    self:RefreshAllStyle()
end

function DrawCardAccChestItem:RefreshAllStyle()
    local iconPath
    self.txtNum.text = self.data.need_count
    if mod.DrawCardProxy:IsAccRewardRecv(self.data.id, self.data.grade) then
        --已领
        iconPath = AssetPath.DrawCardAccChestRecvIcon[self.data.grade]
        self.awardState = GDefine.AwardState.Receive
        self.objRecv:SetActive(true)
    else
        self.objRecv:SetActive(false)
        iconPath = AssetPath.DrawCardAccChestIcon[self.data.grade]
        local state = mod.DrawCardProxy.accRewardState[self.data.id]
        local ownValue = state and state.value or 0
        if ownValue >= self.data.need_count then
            --可领
            self.awardState = GDefine.AwardState.Unclaimed
        else
            --未解锁
            self.awardState = GDefine.AwardState.Lock
        end
    end
    if iconPath then
        self:SetSprite(self.imgIcon, iconPath, true)
    end
end

function DrawCardAccChestItem:OnClick()
    if self.awardState == GDefine.AwardState.Receive then
        return
    end
    local onlyPreview = self.awardState == GDefine.AwardState.Lock
    local data = {accDrawId = self.data.id, grade = self.data.grade}
    self:ActiveSelectHeroView(data,onlyPreview)
end

function DrawCardAccChestItem:ActiveSelectHeroView(data,onlyPreview)
    local list = {}
    local gradeConf = Config.DrawCardData.data_acc_draw[data.accDrawId .. "_" .. data.grade]
    local items = Config.DrawCardData.data_acc_draw_content_items[data.accDrawId][data.grade]
    for _, id in ipairs(items) do
        local key = string.format("%d_%d_%d",data.accDrawId,data.grade,id)
        local itemData = Config.DrawCardData.data_acc_draw_content[key]
        table.insert( list, {
            item_id = itemData.item_id,
            count = itemData.item_count,
            accDrawId = data.accDrawId,
            grade = data.grade,
        })
    end
    ViewManager.Instance:OpenWindow(CustomSelectWindow, {
        items = list,
        judgeOwned = gradeConf.need_unit_active == 1,
        sortType = CustomSelectWindow.SortType.OwnedFirstAndItemOrder,
        cbItemSelect = self:ToFunc("OnCustomItemSelect"),
        cbSelect = self:ToFunc("OnCustomWindowSelect"),
        cbClose = self:ToFunc("OnCustomWindowClose"),
        onlyPreview = onlyPreview,
    })
end

function DrawCardAccChestItem:OnCustomItemSelect(item, validate)
    if validate then
        mod.DrawCardProxy:SetSelectHeroData(item.data.accDrawId, item.data.grade, item.data.item_id)
    else
        SystemMessage.Show(TI18N("尚未获取该英雄!"))
    end
end

function DrawCardAccChestItem:OnCustomWindowSelect()
     if not mod.DrawCardProxy.selectHeroData then
        SystemMessage.Show(TI18N("请选择英雄!"))
        return
    end
    mod.DrawCardFacade:SendMsg(11202)
end

function DrawCardAccChestItem:OnReset()
    self.data = nil
    self.index = nil
end

function DrawCardAccChestItem:OnRecycle()
end

--#region 静态方法

function DrawCardAccChestItem.Create(template)
    local item = DrawCardAccChestItem.New()
    item:SetObject(GameObject.Instantiate(template))
    item:Show()
    return item
end

--#endregion