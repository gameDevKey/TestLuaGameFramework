ShopDefine = StaticClass("ShopDefine")

ShopDefine.ShopType =
{
    choiceness = 1, -- 每日精选
    hero = 2, -- 英灵直购
    currency_recharge = 3, -- 货币直购
}

ShopDefine.ShopOrder =
{
    [1] = ShopDefine.ShopType.choiceness,
    [2] = ShopDefine.ShopType.hero,
    [3] = ShopDefine.ShopType.currency_recharge
}

ShopDefine.GoodsStyle =
{
    grid_con = 1, -- 格子容器
    banner = 2, -- 横幅广告(非需求 仅预留位置)
}

ShopDefine.GoodsStyleMapping =
{
    [ShopDefine.GoodsStyle.grid_con] = { class = "ShopGridsContainer"}
}

ShopDefine.ShopTypeToTitleStyle =
{
    [ShopDefine.ShopType.choiceness] = {
        title = TI18N("每日精选"),
        titleHeight = 96,
        canRefresh = true,
        goodsStyle = ShopDefine.GoodsStyle.grid_con,
        layoutInfo = {columnCount = 3, padding = {left=20,right=0,top=28,bottom=0}, gridSize = {x=225, y=344}, spacing = {x=3, y=30}},
    },
    [ShopDefine.ShopType.hero] = {
        title = TI18N("英灵直购"),
        titleHeight = 96,
        canRefresh = true,
        goodsStyle = ShopDefine.GoodsStyle.grid_con,
        layoutInfo = {columnCount = 3, padding = {left=20,right=0,top=28,bottom=0}, gridSize = {x=225, y=344}, spacing = {x=3, y=30}},
    },
    [ShopDefine.ShopType.currency_recharge] = {
        title = TI18N("资源兑换"),
        titleHeight = 57,
        canRefresh = false,
        goodsStyle = ShopDefine.GoodsStyle.grid_con,
        layoutInfo = {columnCount = 3, padding = {left=20,right=0,top=39,bottom=0}, gridSize = {x=225, y=344}, spacing = {x=3, y=30}},
    },
}

ShopDefine.IsBuy = 2  -- pb_118.proto pt_shopping_grid.is_buy // 是否购买 1-没买 2-买了

ShopDefine.IsFirst = 1 -- pb_118.proto pt_shopping_recharge_grid.is_first // 是否还剩首冲 1-是 2-没了
ShopDefine.IsNotFirst = 2

ShopDefine.ItemIdToDesc = {
	[GDefine.ItemId.Diamond] = "钻石",
	[GDefine.ItemId.Gold] = "金币",
}