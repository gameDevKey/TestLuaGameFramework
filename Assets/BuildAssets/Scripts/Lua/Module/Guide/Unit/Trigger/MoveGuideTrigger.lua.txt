MoveGuideTrigger = Class("MoveGuideTrigger", GuideTrigger)

function MoveGuideTrigger:OnInit()
    self:AddGameListenerWithSelfFunc(EventConfig.Type.MoveInput, "OnMoveInput")
end

function MoveGuideTrigger:OnDelete()
end

function MoveGuideTrigger:OnMoveInput(h, v)
    self:Finish({ h = h, v = v })
end

return MoveGuideTrigger
