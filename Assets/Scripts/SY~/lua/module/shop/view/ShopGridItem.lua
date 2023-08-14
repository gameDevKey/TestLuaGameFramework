ShopGridItem = BaseClass("ShopGridItem",BaseView)

function ShopGridItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)

    self.data = nil
    self.belongShop = nil
    self.gridId = nil
    self.isFree = false
    self.isBuy = false
    self.isFirst = false
    self.isLocked = false
    self.cost = nil
    self.realCurrency = 0

    self.newRemind = nil
    self.newRemindNode = nil

    self.toPlayAnim = ""
end

function ShopGridItem:__Delete()
    self:RemoveRemind()
end

function ShopGridItem:__CacheObject()
    self.canvasGroup = self:Find("",CanvasGroup)
    self.bg = self:Find("bg",Image)

    self.normalNode = self:Find("main/normal").gameObject
    self.itemName = self:Find("main/normal/name",Text)
    self.icon = self:Find("main/normal/icon",Image)
    self.priceNode = self:Find("main/normal/price").gameObject
    self.priceImg = self:Find("main/normal/price/img",Image)
    self.priceNum = self:Find("main/normal/price/num",Text)
    self.freeText = self:Find("main/normal/free_text").gameObject
    self.sellOut = self:Find("main/normal/sell_out").gameObject

    self.lockedNode = self:Find("main/locked").gameObject
    self.conditionNode = self:Find("main/locked/condition")
    self.unlockCondText = self:Find("main/locked/condition/text",Text)
    self.trophyImg = self:Find("main/locked/condition/trophy_img")

    self.superscriptFirst = self:Find("main/currency_superscript/first").gameObject
    self.superscriptAdd = self:Find("main/currency_superscript/add").gameObject
    self.addText =  self:Find("main/currency_superscript/add/text",Text)

    self.newRemindNode = self:Find("main/new_remind_node").gameObject
end

function ShopGridItem:__Create()
    self.freeText:GetComponent(Text).text = TI18N("免费")
    self:Find("main/normal/sell_out",Text).text = TI18N("已售罄")
    self:Find("main/currency_superscript/first/pivot/text",Text).text = TI18N("首充双倍")
end

function ShopGridItem:__BindListener()
    self:AddAnimDelayPlayListener("shop_node",self:ToFunc("OnAnimDelayPlay"))
    self:Find("main",Button):SetClick(self:ToFunc("BuyShopGrid"))
end

function ShopGridItem:SetData(shopType,data)
    self.data = data
    self.gridId = data.gridId
    self.belongShop = shopType
    self.isLocked = data.isLocked

    if self.data.isFirst ~= ShopDefine.IsFirst and not self.data.discountText then
        self.toPlayAnim = "shop_grid_item_none"
    elseif self.data.isFirst == ShopDefine.IsFirst then
        self.toPlayAnim = "shop_grid_item_redcard"
    elseif self.data.isFirst ~= ShopDefine.IsFirst and not StringUtils.IsEmpty(self.data.discountText) then
        self.toPlayAnim = "shop_grid_item_orangecard"
    end
end

function ShopGridItem:__Show()
    if not self.isLocked and TableUtils.IsValid(self.data.itemInfo) then
        self.lockedNode:SetActive(false)
        self.itemConf = Config.ItemData.data_item_info[self.data.itemInfo.itemId]
        self:SetGridImg()
        self.itemName.text = self.itemConf.name.."x"..self.data.itemInfo.num
        if self.data.isBuy and self.data.isBuy == ShopDefine.IsBuy then
            self.isBuy = true
            self.normalNode:SetActive(true)
            self.sellOut:SetActive(true)
            self.priceNode:SetActive(false)
            self.freeText:SetActive(false)

            self.canvasGroup.alpha = 0.8
        else
            self.isBuy = false
            self.normalNode:SetActive(true)
            self.sellOut:SetActive(false)

            self:SetPriceNode(self.data.itemInfo)
            self:SetCurrencySuperscript()
        end
    else
        self.lockedNode:SetActive(true)
        self.normalNode:SetActive(false)
        self.sellOut:SetActive(false)

        self.unlockCondText.text = self.data.unlockCond
        local width = self.unlockCondText.preferredWidth + self.trophyImg.rect.width
        local height = self.conditionNode.rect.height
        UnityUtils.SetSizeDelata(self.conditionNode, width, height)
    end

    self:RemoveRemind()
    self.newRemindNode:SetActive(false)
    self:SetNewRemind()
end

function ShopGridItem:SetGridImg()
    self:SetSprite(self.icon,AssetPath.GetShopItemIcon(self.itemConf.icon),true)
    self:SetSprite(self.bg,AssetPath.QualityToShopGridImg[self.itemConf.quality])
end

function ShopGridItem:SetPriceNode(itemInfo)
    self.isFree = false
    self.realCurrency = itemInfo.realCurrency
    self.priceNode:SetActive(true)
    self.freeText:SetActive(false)
    if TableUtils.IsEmpty(itemInfo.cost) and itemInfo.realCurrency ~= 0 then
        self.cost = nil
        self.priceImg.gameObject:SetActive(false)
        self.priceNum.text = TI18N("RMB"..self.realCurrency) -- TODO LanguageUtils.GetCurrencySymbol
        self:SetPriceNumWidth(true)
    elseif TableUtils.IsEmpty(itemInfo.cost) and itemInfo.realCurrency == 0 then
        self.isFree = true
        self.priceNode:SetActive(false)
        self.freeText:SetActive(true)
    elseif TableUtils.IsValid(itemInfo.cost) and itemInfo.realCurrency == 0 then
        self.cost = itemInfo.cost[1]
        self.priceImg.gameObject:SetActive(true)
        self:SetSprite(self.priceImg,AssetPath.GetCurrencyIconByItemId(self.cost[1]))
        self.priceNum.text = self.cost[2]
        self:SetPriceNumWidth(false)
    elseif TableUtils.IsValid(itemInfo.cost) and itemInfo.realCurrency ~= 0 then
        assert(false,string.format("商品[type:%s][gridId:%s] 即要使用真实货币又要消耗游戏货币。",self.belongShop,self.gridId))
    end
end

function ShopGridItem:SetPriceNumWidth(isRealCurrency)
    local height = self.priceNode.transform.rect.height
    local width = self.priceNum.preferredWidth

    local anchoredX = 0
    local anchoredY = self.priceNum.transform.anchoredPosition.y
    if not isRealCurrency then
        anchoredX = 42 -- 42:相对游戏内货币图标右偏移
    end
    UnityUtils.SetAnchoredPosition(self.priceNum.transform,anchoredX,anchoredY)
    width = width + anchoredX

    UnityUtils.SetSizeDelata(self.priceNode.transform,width,height)
end

function ShopGridItem:SetCurrencySuperscript()
    if self.data.isFirst ~= ShopDefine.IsFirst and not self.data.discountText then
        self.superscriptFirst:SetActive(false)
        self.superscriptAdd:SetActive(false)
    elseif self.data.isFirst == ShopDefine.IsFirst then
        self.superscriptFirst:SetActive(true)
        self.superscriptAdd:SetActive(false)
    elseif self.data.isFirst ~= ShopDefine.IsFirst and not StringUtils.IsEmpty(self.data.discountText) then
        self.superscriptFirst:SetActive(false)
        self.superscriptAdd:SetActive(true)
        self.addText.text = self.data.discountText
    end
end

function ShopGridItem:BuyShopGrid()
    if self.isLocked then
        SystemMessage.Show(TI18N("杯数达到"..self.unlockCondText.text))
        return
    end
    if self.isBuy then
        SystemMessage.Show(TI18N("本商品已售罄！"))
        return
    end
    if self.isFree then
        mod.ShopCtrl:BuyShopGrid(self.belongShop,self.gridId)
    elseif self.realCurrency == 0 then
        local data = {}
        data.content = TI18N(string.format("是否花费[%s]x%s购买[%s]x%s", ShopDefine.ItemIdToDesc[self.cost[1]], self.cost[2], self.itemConf.name, self.data.itemInfo.num))
        data.notShowKey = "buy_shop_grid"
        data.onConfirm = self:ToFunc("ConfirmBuy")
        SystemDialog.Show(data)
    elseif self.realCurrency ~= 0 then
        Log("现实货币sdk")
    end
end

function ShopGridItem:ConfirmBuy()
    --TODO 资源不足->跳转到钻石购买
    mod.ShopCtrl:BuyShopGrid(self.belongShop,self.gridId)
end

function ShopGridItem:OnAnimDelayPlay()
    self.gameObject:SetActive(true)
    self:PlayAnim(self.toPlayAnim)
end

function ShopGridItem:OnReset()
    self.data = nil
    self.belongShop = nil
    self.gridId = nil
    self.isFree = false
    self.isBuy = false
    self.isFirst = false
    self.cost = nil
    self.realCurrency = 0

    self.canvasGroup.alpha = 1

    self:RemoveRemind()
    self.newRemindNode:SetActive(false)
end

function ShopGridItem:SetNewRemind()
    self.newRemind = CustomRemindItem.New(self.newRemindNode)
    self.newRemind:SetRemindId(RemindDefine.RemindId.shop_new_unit, self.belongShop.."_"..self.gridId)
end

function ShopGridItem:RemoveRemind()
    if self.newRemind then
        self.newRemind:Destroy()
        self.newRemind = nil
    end
end

function ShopGridItem.Create(template)
    local ShopGridItem = ShopGridItem.New()
    ShopGridItem:SetObject(GameObject.Instantiate(template))
    return ShopGridItem
end