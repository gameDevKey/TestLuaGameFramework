ShopFacade = BaseClass("ShopFacade",Facade)

function ShopFacade:__Init()

end

function ShopFacade:__InitFacade()
    self:BindCtrl(ShopCtrl)
    self:BindProxy(ShopProxy)
end