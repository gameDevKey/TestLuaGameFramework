BattleStateSystem = BaseClass("BattleStateSystem",SECBEntitySystem)

function BattleStateSystem:__Init()
    self.isBattle = false --客户端是否战斗中

    self.overLockNum = 0

    self.battleState = BattleDefine.BattleState.none

    self.battleResult = BattleDefine.BattleResult.none
    self.winCamp = nil

    self.isAgainCheckReconnect = false
    self.isReconnect = false

    self.localRun = false
    self.isReplay = false

    self.isSurrender = false
end

function BattleStateSystem:__Delete()

end

function BattleStateSystem:OnInitSystem()
end

function BattleStateSystem:OnLateInitSystem()
end

function BattleStateSystem:SetReplay(flag)
    self.isReplay = flag
end

function BattleStateSystem:SetLocalRun(flag)
    self.localRun = flag
end

function BattleStateSystem:SetSurrender(flag)
    self.isSurrender = flag
end

function BattleStateSystem:SetAgainCheckReconnect(flag)
    self.isAgainCheckReconnect = flag
end

function BattleStateSystem:SetBattleResult(battleResult)
    self.battleResult = battleResult
end

function BattleStateSystem:IsBattleResult(result)
    return self.battleResult == result
end

function BattleStateSystem:SetReconnect(flag)
    self.isReconnect = flag

    if self.world.checkWorld then
        self.world.checkWorld.BattleStateSystem:SetReconnect(flag)
    end
end

function BattleStateSystem:SetBattleState(state)
    Logf("设置battle状态[%s]",state)
    self.battleState = state
end

function BattleStateSystem:IsBattleState(state)
    return self.battleState == state
end

function BattleStateSystem:SetIsBattle(flag)
    self.isBattle = flag
end

function BattleStateSystem:IsBattle()
    return self.isBattle
end

function BattleStateSystem:AddOverLockNum(num)
	self.overLockNum = self.overLockNum + num
end

function BattleStateSystem:IsOverLock()
    return self.overLockNum > 0
end

function BattleStateSystem:OnLateUpdate()

end

function BattleStateSystem:CleanBattle()
    --self.world.EntitySystem:CallEntityComponent("TposeComponent","RecyclePlaceTpose")
    --self.world.EntitySystem:CleanEntitys()
end