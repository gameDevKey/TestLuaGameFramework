PlayerGuideFacade = BaseClass("PlayerGuideFacade",Facade)

function PlayerGuideFacade:__Init()
    
end

function PlayerGuideFacade:__InitFacade()
    self:BindCtrl(PlayerGuideCtrl)
    self:BindCtrl(PlayerGuideTickCtrl)
    self:BindCtrl(PlayerGuideEventCtrl)
    self:BindCtrl(PlayerGuideUINodeCtrl)

    

    self:BindProxy(PlayerGuideProxy)
end