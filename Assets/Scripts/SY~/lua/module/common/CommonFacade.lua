CommonFacade = BaseClass("CommonFacade", Facade)

function CommonFacade:__Init()

end

function CommonFacade:__InitFacade()
    self:BindCtrl(TipsCtrl)
end