MainuiCtrl = BaseClass("MainuiCtrl",Controller)

function MainuiCtrl:__Init()
end

function MainuiCtrl:__Delete()

end

function MainuiCtrl:__InitComplete()
    EventManager.Instance:AddEvent(EventDefine.preload_complete,self:ToFunc("PreloadComplete"))
end

function MainuiCtrl:PreloadComplete()
    self:InitMainPanel()
end

function MainuiCtrl:InitMainPanel()
    mod.MainuiProxy.mainuiPanel = MainuiPanel.New()
    mod.MainuiProxy.mainuiPanel:SetParent(UIDefine.canvasRoot)
end

