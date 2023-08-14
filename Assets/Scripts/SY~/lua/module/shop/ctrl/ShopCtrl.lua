ShopCtrl = BaseClass("ShopCtrl",Controller)

function ShopCtrl:__Init()
end

function ShopCtrl:__Delete()
end

function ShopCtrl:BuyShopGrid(type,gridId)
    mod.ShopFacade:SendMsg(11802,type,gridId)
end