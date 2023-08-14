SoloBattleAICond = BaseClass("SoloBattleAICond",BTConditional)

function SoloBattleAICond:__Init()

end

function SoloBattleAICond:__Delete()

end

function SoloBattleAICond:OnStart()

end

function SoloBattleAICond:OnUpdate(deltaTime)
    local flag = self.owner.world.BattleStateSystem:IsBattleState(BattleDefine.BattleState.solo_battle)
    return self:CheckCond(flag)
end