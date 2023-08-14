RewardFacade = BaseClass("RewardFacade",Facade)

function RewardFacade:__Init()
end

function RewardFacade:__InitFacade()
    self:BindCtrl(RewardCtrl)
    self:BindProxy(RewardProxy)
end