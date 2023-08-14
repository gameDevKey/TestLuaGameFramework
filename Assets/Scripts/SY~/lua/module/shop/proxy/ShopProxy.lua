ShopProxy = BaseClass("ShopProxy",Proxy)

function ShopProxy:__Init()
    self.shopData = {}
    self.shopDataDict = {}
    self.refreshCount = {}
    self.maxRefreshCount = {}
    self:SetMaxRefreshCount()
end

function ShopProxy:__InitProxy()
    --TODO 绑定协议
    self:BindMsg(11800) -- 商场信息
    self:BindMsg(11801) -- 刷新
    self:BindMsg(11802) -- 购买
    self:BindMsg(11803) -- 格子解锁
end

function ShopProxy:RefreshChoicenessData(choicenessList)
    self.shopData[ShopDefine.ShopType.choiceness] = {}
    self.shopDataDict[ShopDefine.ShopType.choiceness] = {}
    for i, v in ipairs(choicenessList) do
        local gridData = {}
        gridData.gridId = v.grid_id
        gridData.isBuy = v.is_buy
        gridData.isLocked = false

        local warehouseConf = Config.ShoppingData.data_warehouse[v.id]
        local itemInfo = {}
        itemInfo.itemId = warehouseConf.item_id
        itemInfo.num = warehouseConf.num
        itemInfo.cost = warehouseConf.need
        itemInfo.realCurrency = warehouseConf.real_currency
        gridData.itemInfo = itemInfo
        table.insert(self.shopData[ShopDefine.ShopType.choiceness], gridData)
        self.shopDataDict[ShopDefine.ShopType.choiceness][v.grid_id] = gridData
    end

    -- 每日精选配置中有grid_id而服务端没发对应的数据即锁定中
    local choicenessConf = Config.ShoppingData.data_choiceness_grid
    for k, v in pairs(choicenessConf) do
        if not self.shopDataDict[ShopDefine.ShopType.choiceness][v.grid_id] then
            local gridData = {}
            gridData.gridId = v.grid_id
            gridData.isBuy = nil
            gridData.isLocked = true
            gridData.itemInfo = nil
            gridData.unlockCond = v.locked_show

            table.insert(self.shopData[ShopDefine.ShopType.choiceness], gridData)
            self.shopDataDict[ShopDefine.ShopType.choiceness][v.grid_id] = gridData
        end
    end
    table.sort(self.shopData[ShopDefine.ShopType.choiceness],self:ToFunc("SortGridByGridId"))
end

function ShopProxy:RefreshHeroData(heroList)
    self.shopData[ShopDefine.ShopType.hero] = {}
    self.shopDataDict[ShopDefine.ShopType.hero] = {}
    for i, v in ipairs(heroList) do
        local gridData = {}
        gridData.gridId = v.grid_id
        gridData.isBuy = v.is_buy
        gridData.isLocked = false

        local warehouseConf = Config.ShoppingData.data_warehouse[v.id]
        local itemInfo = {}
        itemInfo.itemId = warehouseConf.item_id
        itemInfo.num = warehouseConf.num
        itemInfo.cost = warehouseConf.need
        itemInfo.realCurrency = warehouseConf.real_currency
        gridData.itemInfo = itemInfo

        table.insert(self.shopData[ShopDefine.ShopType.hero], gridData)
        self.shopDataDict[ShopDefine.ShopType.hero][v.grid_id] = gridData
    end
    table.sort(self.shopData[ShopDefine.ShopType.hero],self:ToFunc("SortGridByGridId"))
end

function ShopProxy:RefreshCurrencyData(rechargeList)
    self.shopData[ShopDefine.ShopType.currency_recharge] ={}
    self.shopDataDict[ShopDefine.ShopType.currency_recharge] = {}

    for i, v in ipairs(rechargeList) do
        local conf = Config.ShoppingData.data_currency_grid[v.grid_id]
        local gridData = {}
        gridData.gridId = v.grid_id
        gridData.isBuy = nil
        gridData.isLocked = false
        gridData.isFirst = v.is_first
        local itemInfo = {}
        itemInfo.itemId = conf.item_id
        itemInfo.num = conf.num
        itemInfo.cost = conf.need
        itemInfo.realCurrency = conf.real_currency
        gridData.itemInfo = itemInfo
        gridData.discountText = conf.discount_show

        table.insert(self.shopData[ShopDefine.ShopType.currency_recharge], gridData)
        self.shopDataDict[ShopDefine.ShopType.currency_recharge][v.grid_id] = gridData
    end
    table.sort(self.shopData[ShopDefine.ShopType.currency_recharge],self:ToFunc("SortGridByGridId"))
end

function ShopProxy:SortGridByGridId(a,b)
    return a.gridId < b.gridId
end

function ShopProxy:SetRefreshCount(type, count)
    self.refreshCount[type] = count
end

function ShopProxy:GetRefreshCountByShopType(type)
    return self.refreshCount[type]
end

function ShopProxy:SetMaxRefreshCount()
    self.maxRefreshCount[ShopDefine.ShopType.choiceness] = Config.ShoppingData.data_shopping_const["day_refresh_times"].num
    self.maxRefreshCount[ShopDefine.ShopType.hero] = Config.ShoppingData.data_shopping_const["hero_refresh_times"].num
end

function ShopProxy:GetMaxRefreshCountByShopType(type)
    return self.maxRefreshCount[type]
end

function ShopProxy:SetGridDataIsBuy(type,gridId)
    if type == ShopDefine.ShopType.choiceness or type == ShopDefine.ShopType.hero then
        self.shopDataDict[ShopDefine.ShopType.choiceness][gridId].isBuy = ShopDefine.IsBuy
    elseif type == ShopDefine.ShopType.currency_recharge then
        self.shopDataDict[ShopDefine.ShopType.currency_recharge][gridId].isFirst = ShopDefine.IsNotFirst
    end
end

function ShopProxy:SetGridUnlock(type, data)
    if type == ShopDefine.ShopType.choiceness then
        local gridData = self.shopDataDict[ShopDefine.ShopType.choiceness][data.grid_id]

        gridData.isBuy = data.is_buy
        gridData.isLocked = false

        local warehouseConf = Config.ShoppingData.data_warehouse[data.id]
        local itemInfo = {}
        itemInfo.itemId = warehouseConf.item_id
        itemInfo.num = warehouseConf.num
        itemInfo.cost = warehouseConf.need
        itemInfo.realCurrency = warehouseConf.real_currency
        gridData.itemInfo = itemInfo
    end
end

function ShopProxy:Recv_11800(data)
    LogTable("接收11800",data)
    -- 每日精选
    self:RefreshChoicenessData(data.choiceness_list)

    -- 英灵直购
    self:RefreshHeroData(data.hero_list)

    -- 货币直购
    self:RefreshCurrencyData(data.recharge_list)

    -- 刷新次数
    self:SetRefreshCount(ShopDefine.ShopType.choiceness, data.choiceness_refresh_times)
    self:SetRefreshCount(ShopDefine.ShopType.hero, data.hero_refresh_times)

end

function ShopProxy:Send_11801(type)
    local data = {}
    data.type = type

    LogTable("发送11801",data)
    return data
end

function ShopProxy:Recv_11801(data)
    LogTable("接收11801", data)
    if data.type == ShopDefine.ShopType.choiceness then
        self:RefreshChoicenessData(data.info)
    elseif data.type == ShopDefine.ShopType.hero then
        self:RefreshHeroData(data.info)
    end
    self:SetRefreshCount(data.type, data.times)

    mod.ShopFacade:SendEvent(ShopWindow.Event.RefreshShopData,data.type)
end

function ShopProxy:Send_11802(type,gridId)
    local data = {}
    data.type = type
    data.grid_id = gridId

    LogTable("发送了11802",data)
    return data
end

function ShopProxy:Recv_11802(data)
    LogTable("接收11802",data)
    self:SetGridDataIsBuy(data.type, data.grid_id)
    mod.ShopFacade:SendEvent(ShopWindow.Event.RefreshShopData,data.type)
end

function ShopProxy:Recv_11803(data)
    LogTable("接收11803",data)
    self:SetGridUnlock(data.type, data.grid)
    mod.ShopFacade:SendEvent(ShopWindow.Event.RefreshShopData,data.type)
end