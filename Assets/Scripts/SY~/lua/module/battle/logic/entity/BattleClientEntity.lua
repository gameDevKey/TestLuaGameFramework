BattleClientEntity = BaseClass("BattleClientEntity",SECBClientEntity)

function BattleClientEntity:__Init()

end

function BattleClientEntity:__Delete()

end

function BattleClientEntity:OnUpdate()
    self:UpdateComponent()
end


function BattleClientEntity:OnLateUpdate()
    self:LateUpdateComponent()
end