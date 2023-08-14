OpenFuncFacade = BaseClass("OpenFuncFacade",Facade)

function OpenFuncFacade:__Init()

end

function OpenFuncFacade:__InitFacade()
    self:BindProxy(OpenFuncProxy)

    self:BindCtrl(OpenFuncCtrl)
    self:BindCtrl(OpenFunMixCtrl)
    self:BindCtrl(OpenFuncShowCtrl)
end
