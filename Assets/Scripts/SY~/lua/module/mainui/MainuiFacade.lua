MainuiFacade = BaseClass("MainuiFacade",Facade)

function MainuiFacade:__Init()

end

function MainuiFacade:__InitFacade()
    self:BindCtrl(MainuiCtrl)
    self:BindProxy(MainuiProxy)
    self:BindProxy(MainuiAnimProxy)
end