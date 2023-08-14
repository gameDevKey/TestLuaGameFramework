PlayerGuideTickCtrl = BaseClass("PlayerGuideTickCtrl",Controller)

function PlayerGuideTickCtrl:__Init()

end

function PlayerGuideTickCtrl:ResetData()

end

function PlayerGuideTickCtrl:Update(deltaTime)
    for _,v in pairs(mod.PlayerGuideProxy.guideActions) do
        v:Update(deltaTime)
    end
end