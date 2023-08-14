ShopWindow = BaseClass("ShopWindow",BaseWindow)
ShopWindow.__topInfo = true
ShopWindow.__bottomTab = true
ShopWindow.__adaptive = true
ShopWindow.Event = EventEnum.New(
    "RefreshShopData"
)

function ShopWindow:__Init()
    self:SetAsset("ui/prefab/shop/shop_window.prefab", AssetType.Prefab)
    self:AddAsset(AssetPath.shopNodeCtrl,AssetType.Object)
    self:AddAsset(AssetPath.shopGridItemCtrl,AssetType.Object)

    self.curHeight = 0
    self.scrollAnim = nil
    self.animTimer = nil
    self.shopNodeAnimIndex = 1

    self.shops = {}
    self.tabs = {}
end

function ShopWindow:__Delete()
    for k, v in pairs(self.shops) do
        v:Destroy()
    end
    self:RemoveScrollAnim()
end

function ShopWindow:__CacheObject()
    self.bgs = self:Find("main/scroll_view/bgs")

    self.scrollRect = self:Find("main/scroll_view",ScrollRect)
    self.scrollViewContent = self:Find("main/scroll_view/view_port/content")

    self.shopNodeTemp = self:Find("template/shop_node").gameObject
    self.goodsStyleTemp = {}
    self.goodsStyleTemp[ShopDefine.GoodsStyle.grid_con] = self:Find("template/shop_grids_container").gameObject
    self.gridItemTemp = {}
    self.gridItemTemp[ShopDefine.GoodsStyle.grid_con] = self:Find("template/shop_grid_item").gameObject

    self:CacheTabGroup()
end

function ShopWindow:__Create()
    self.shopGridItemCtrl = self:GetAsset(AssetPath.shopGridItemCtrl)
    AssetLoaderProxy.Instance:AddReference(AssetPath.shopGridItemCtrl)
    self.autoReleaser:Remove(AssetPath.shopGridItemCtrl)
    self.autoReleaser:Add(AssetPath.shopGridItemCtrl)
    local anim = self:GetAsset(AssetPath.shopNodeCtrl)
    for i, v in ipairs(ShopDefine.ShopOrder) do
        local style = ShopDefine.ShopTypeToTitleStyle[v]

        self:CreateShop(v, style)
        self.shops[v]:SetAnim(AssetPath.shopNodeCtrl, anim)
        self.shops[v]:SetData(v, mod.ShopProxy.shopData[v])
        self.shops[v]:Show()
        self:SetRefreshCount(v)
        local width = self.shops[v].transform.rect.width
        local height = math.abs(self.shops[v].transform:Find("main").anchoredPosition.y) + self.shops[v].goodsStyle.transform.rect.height
        UnityUtils.SetSizeDelata(self.shops[v].transform,width,height)



        local data = {}
        data.title = style.title
        data.posY = self.curHeight
        data.areaY = self.curHeight + (height/2)
        self:SetTabData(i,data)

        self.curHeight = self.curHeight + height + 40  -- 40:spacing
    end
end

function ShopWindow:__BindListener()
    for shopType, shop in pairs(self.shops) do
        if shop.canRefresh then
            shop.refreshBtn:SetClick(self:ToFunc("OnRefreshBtnClick"), shopType)
        end
    end

    for i, v in ipairs(self.tabs) do
        v.btn:SetClick( self:ToFunc("SwitchTab"),v.index)
    end

    self.scrollRect:SetValueChanged(self:ToFunc("OnScrollRectValueChanged"))
end

function ShopWindow:__BindEvent()
    self:BindEvent(ShopWindow.Event.RefreshShopData)
end

function ShopWindow:__Show()
    self:PlayAnim("shop_window")
end

function ShopWindow:CacheTabGroup()
    self.tabGroup = self:Find("main/tab_group")
    self.tabs = {}

    for i=1, #ShopDefine.ShopOrder do
        local tab = {}
        tab.index = i
        tab.isOn = false
        tab.btn = self.tabGroup:Find("tab_"..i).gameObject:GetComponent(Button)
        tab.commonNode = self.tabGroup:Find("tab_"..i.."/common").gameObject
        tab.commonText = self.tabGroup:Find("tab_"..i.."/common/text").gameObject:GetComponent(Text)
        tab.selectedNode = self.tabGroup:Find("tab_"..i.."/selected").gameObject
        tab.selectedText = self.tabGroup:Find("tab_"..i.."/selected/text").gameObject:GetComponent(Text)
        tab.posY = 0
        table.insert(self.tabs, tab)
    end
end

function ShopWindow:CreateShop(type, style)
    local shopNode = ShopNode.Create(self.shopNodeTemp,self.goodsStyleTemp,self.gridItemTemp,style,self.shopGridItemCtrl)
    shopNode.transform:SetParent(self.scrollViewContent)
    shopNode.transform:Reset()
    self.shops[type] = shopNode
end

function ShopWindow:SetTabData(index,data)
    local tab = self.tabs[index]
    tab.commonText.text = data.title
    tab.selectedText.text = data.title
    tab.posY = data.posY
    tab.areaY = data.areaY
end

function ShopWindow:RefreshShopData(type)
    self.shops[type].goodsStyle:SetData(type, mod.ShopProxy.shopData[type])
    self:SetRefreshCount(type)
end

function ShopWindow:SetRefreshCount(type)
    local shop = self.shops[type]
    if shop.canRefresh then
        local count = mod.ShopProxy:GetRefreshCountByShopType(type)
        local maxCount = mod.ShopProxy:GetMaxRefreshCountByShopType(type)
        shop.refreshCount.text = string.format("%s/%s",count,maxCount)
        UIUtils.Grey(shop.refreshBtnImg, count == 0)
    end
end

function ShopWindow:OnRefreshBtnClick(shopType)
    mod.ShopFacade:SendMsg(11801, shopType)
end

function ShopWindow:SwitchTab(index)
    for i, v in ipairs(self.tabs) do
        v.isOn = v.index == index
        v.commonNode:SetActive(v.index ~= index)
        v.selectedNode:SetActive(v.index == index)
    end
    self:ScrollTo(self.tabs[index].posY,0.2,self:ToFunc("OnScrollToComplete"))
end

function ShopWindow:ScrollTo(posY,time,callback)
    posY = posY or 0
    time = time or 0.1
    self:RemoveScrollAnim()
    self.scrollAnim = MoveAnchorYAnim.Create(self.scrollViewContent, {path = "", toY = posY, time = time})
    if callback then
        self.scrollAnim:SetComplete(callback)
    end
    self.scrollRect.decelerationRate = 0
    self.scrollAnim:Play()
end

function ShopWindow:OnScrollToComplete()
    self.scrollRect.decelerationRate = 0.135
end

function ShopWindow:OnScrollRectValueChanged()
    local posY = self.scrollViewContent.anchoredPosition.y
    local anchoredX = 0
    local anchoredY = math.floor(352 + posY + 0.5)
    if anchoredY < 192 then
        anchoredY = 192
    elseif anchoredY > 352 then
        anchoredY = 352
    end
    if (anchoredY ~= 192 or self.bgs.anchoredPosition.y ~= 192) and (anchoredY ~= 352 or self.bgs.anchoredPosition.y ~= 352) then
        UnityUtils.SetAnchoredPosition(self.bgs, anchoredX, anchoredY)
    end
    if posY >= 0 then
        local index = self:GetTabIndexByContentY(posY)
        if self.tabs[index].isOn then
            return
        end
        for i, v in ipairs(self.tabs) do
            v.isOn = v.index == index
            v.commonNode:SetActive(v.index ~= index)
            v.selectedNode:SetActive(v.index == index)
        end
    end
end

function ShopWindow:GetTabIndexByContentY(posY)
    local index = 1
    for i, tab in ipairs(self.tabs) do
        if posY >= tab.areaY then
            index = i+1
        else
            break
        end
    end
    if index > #self.tabs then
        index = #self.tabs
    end
    return index
end

function ShopWindow:RemoveScrollAnim()
    if self.scrollAnim then
        self.scrollAnim:Destroy()
        self.scrollAnim = nil
    end
end