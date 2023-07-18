GamePlayEntity = Class("GamePlayEntity",ECSLEntity)

function GamePlayEntity:OnInit()
end

function GamePlayEntity:OnDelete()
end

function GamePlayEntity:OnUpdate()
end

function GamePlayEntity:SetPlayerType(type)
    self.playerType = type
end

function GamePlayEntity:ToString()
    if not self.debugName then
        self.debugName = "GamePlayEntity:"..self:GetUid()
    end
    return self.debugName
end

return GamePlayEntity