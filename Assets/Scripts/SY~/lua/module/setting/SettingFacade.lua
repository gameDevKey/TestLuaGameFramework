SettingFacade = BaseClass("SettingFacade",Facade)

function SettingFacade:__Init()

end

function SettingFacade:__InitFacade()
    self:BindCtrl(SettingCtrl)

    self:BindProxy(SettingProxy)
end
