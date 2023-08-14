ShopNode = BaseClass("ShopNode",BaseView)

function ShopNode:__Init()
    self.goodsStyleTemp = nil
    self.gridItemTemp = nil
    self.style = nil
    self.shopGridItemCtrl = nil

    self.shopType = nil
    self.gridDatas = nil
end

function ShopNode:__Delete()
    self.goodsStyle:Destroy()
end

function ShopNode:__CacheObject()
    self.title = self.transform:Find("title")
    self.titleText = self.transform:Find("title/title").gameObject:GetComponent(Text)
    self.refreshTips = self.transform:Find("title/refresh_tips").gameObject:GetComponent(Text)

    self.refreshBtn = self.transform:Find("title/refresh_btn").gameObject:GetComponent(Button)
    self.refreshCount = self.transform:Find("title/refresh_btn/count").gameObject:GetComponent(Text)
    self.refreshBtnImg = self.transform:Find("title/refresh_btn").gameObject:GetComponent(Image)

    self.main = self.transform:Find("main")

end

function ShopNode:__Create()
    local titleWidth = self.title.rect.width
    local titleHeight = self.style.titleHeight
    UnityUtils.SetSizeDelata(self.title, titleWidth, titleHeight)

    self.titleText.text = self.style.title
    self.refreshTips.text = TI18N("每日0点后更新")

    self.canRefresh = self.style.canRefresh
    self.refreshTips.gameObject:SetActive(self.style.canRefresh)
    self.refreshBtn.gameObject:SetActive(self.style.canRefresh)
    self.refreshCount.gameObject:SetActive(self.style.canRefresh)

    UnityUtils.SetAnchoredPosition(self.main, 0, -self.style.titleHeight)

    local class = _G[ShopDefine.GoodsStyleMapping[self.style.goodsStyle].class]
    self.goodsStyle = class.New(self.style.layoutInfo,self.gridItemTemp[self.style.goodsStyle],self.shopGridItemCtrl)
    self.goodsStyle:SetObject(GameObject.Instantiate(self.goodsStyleTemp[self.style.goodsStyle]))
    self.goodsStyle.transform:SetParent(self.main)
    self.goodsStyle.transform:Reset()
    self.goodsStyle:SetData(self.shopType,self.gridDatas)
end

function ShopNode:__BindListener()
    self:AddAnimDelayPlayListener("shop_window",self:ToFunc("OnAnimDelayPlay"))
end

function ShopNode:__Show()
    self.goodsStyle:Show()
end

function ShopNode:SetData(shopType, gridDatas)
    self.shopType = shopType
    self.gridDatas = gridDatas
end

function ShopNode:OnAnimDelayPlay()
    self.gameObject:SetActive(true)
    self:PlayAnim("shop_node")
end

function ShopNode.Create(template,goodsStyleTemp,gridItemTemp,style,shopGridItemCtrl)
    local ShopNode = ShopNode.New()
    ShopNode:SetObject(GameObject.Instantiate(template))
    ShopNode.goodsStyleTemp = goodsStyleTemp
    ShopNode.gridItemTemp = gridItemTemp
    ShopNode.style = style
    ShopNode.shopGridItemCtrl = shopGridItemCtrl
    return ShopNode
end