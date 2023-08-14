SettingCtrl = BaseClass("SettingCtrl",Controller)

function SettingCtrl:__Init()
end

function SettingCtrl:__Delete()
end

function SettingCtrl:__InitComplete()
    EventManager.Instance:AddEvent(EventDefine.init_data_complete,self:ToFunc("InitDataComplete"))
end

function SettingCtrl:InitDataComplete()
    mod.SettingProxy:InitRoleSetting()
end


function SettingCtrl:AppleBloom()
end