PersonalInfoCtrl = BaseClass("PersonalInfoCtrl",Controller)

function PersonalInfoCtrl:__Init()
end

function PersonalInfoCtrl:OpenPersonalInfo(data)
    ViewManager.Instance:OpenWindow(PersonalInfoPanel, data)
end