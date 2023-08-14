BattleEntity = BaseClass("BattleEntity",SECBEntity)

function BattleEntity:__Init()
    self.kvData = {}
    self.isUidSingle = false
end

function BattleEntity:__Delete()
end

function BattleEntity:OnInit()
    self.isUidSingle = self.uid % 2 ~= 0
end

function BattleEntity:OnPreUpdate()
    self:PreUpdateComponent()
end

function BattleEntity:OnUpdate()
    self:UpdateComponent()
end

function BattleEntity:OnLateUpdate()
    self:LateUpdateComponent()
end