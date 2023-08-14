BattleGuideView = BaseClass("BattleGuideView",BaseView)

function BattleGuideView:__Init()
    
end

function BattleGuideView:__BindEvent()
    self:BindEvent(PlayerGuideFacade.FunEvent)
end