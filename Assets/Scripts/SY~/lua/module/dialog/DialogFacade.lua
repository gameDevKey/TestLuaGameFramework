DialogFacade = BaseClass("DialogFacade",Facade)

function DialogFacade:__Init()

end

function DialogFacade:__InitFacade()
    self:BindCtrl(DialogCtrl)
    self:BindProxy(DialogProxy)
end