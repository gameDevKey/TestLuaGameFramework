RewardCtrl = BaseClass("RewardCtrl",Controller)

function RewardCtrl:__Init()
end

function RewardCtrl:__Delete()
    
end
function RewardCtrl:__InitComplete()
    --self:InitRewardPanel()
end

function RewardCtrl:InitRewardPanel()
    -- TODO:为什么要这么早初始化
    -- mod.RewardProxy.rewardPanel =  RewardPanel.New()
    -- mod.RewardProxy.rewardPanel:SetParent(UIDefine.canvasRoot)
end