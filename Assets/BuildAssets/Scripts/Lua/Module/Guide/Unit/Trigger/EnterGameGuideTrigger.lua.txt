EnterGameGuideTrigger = Class("EnterGameGuideTrigger", GuideTrigger)

function EnterGameGuideTrigger:OnInit()
    if RunWorld then
        self:OnGameStart()
    else
        self:AddGolbalListenerWithSelfFunc(EGlobalEvent.GameStart, "OnGameStart")
    end
end

function EnterGameGuideTrigger:OnDelete()
end

function EnterGameGuideTrigger:OnGameStart()
    self:Finish()
end

return EnterGameGuideTrigger
