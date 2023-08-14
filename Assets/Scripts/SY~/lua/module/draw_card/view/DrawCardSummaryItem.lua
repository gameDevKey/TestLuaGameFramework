DrawCardSummaryItem = BaseClass("DrawCardSummaryItem", BaseView)

function DrawCardSummaryItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
end

function DrawCardSummaryItem:__CacheObject()
    self.txtName = self:Find("txt_name",Text)
    self.imgQuality = self:Find("img_quality",Image)
    self.imgIcon = self:Find("img_icon",Image)
    self.txtNum = self:Find("img_num/txt_num",Text)
end

function DrawCardSummaryItem:__Create()
    self:AddAnimEffectListener("draw_card_award_item_normal",self:ToFunc("OnItemAnimPlay"))
    self:AddAnimEffectListener("draw_card_award_item_purple",self:ToFunc("OnItemAnimPlay"))
    self:AddAnimEffectListener("draw_card_award_item_gold",self:ToFunc("OnItemAnimPlay"))

    for _, name in pairs(DrawCardSummaryWindow.AnimType) do
        self:AddAnimDelayPlayListener(name,self:ToFunc("OnAnimDelayPlay"))
    end
end

function DrawCardSummaryItem:__BindListener()
end

function DrawCardSummaryItem:SetData(data, index, parentWindow)
    self.rootCanvas = parentWindow.rootCanvas
    self.data = data
    self.index = index
    local itemId = data.item_id
    local count = data.count
    self.itemConf = Config.ItemData.data_item_info[itemId]
    local quality = self.itemConf.quality
    self.txtName.text = self.itemConf.name
    self.txtNum.text = count
    self:SetSprite(self.imgIcon, AssetPath.GetDrawCardIconPath(itemId))
    self:SetSprite(self.imgQuality, AssetPath.GetDrawCardQuailtyPath(quality))
end

function DrawCardSummaryItem:OnAnimDelayPlay()
    self:RemoveAllEffect()
    local quality = self.itemConf.quality
    if quality >= GDefine.Quality.orange then
        self:PlayAnim("draw_card_award_item_gold")
    elseif quality == GDefine.Quality.purple then
        self:PlayAnim("draw_card_award_item_purple")
    else
        self:PlayAnim("draw_card_award_item_normal")
    end
end

function DrawCardSummaryItem:OnReset()
    self.data = nil
    self.index = nil
end

function DrawCardSummaryItem:OnRecycle()
    self:RemoveAllEffect()
end

function DrawCardSummaryItem:OnItemAnimPlay(name,data)
    self:LoadUIEffectByAnimData(data,true)
end

--#region 静态方法

function DrawCardSummaryItem.Create(template)
    local item = DrawCardSummaryItem.New()
    item:SetObject(GameObject.Instantiate(template))
    item:Show()
    return item
end

--#endregion