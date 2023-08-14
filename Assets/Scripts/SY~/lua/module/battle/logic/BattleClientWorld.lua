BattleClientWorld = BaseClass("BattleClientWorld",SECBClientWorld)

function BattleClientWorld:__Init()

end

function BattleClientWorld:__Delete()
    PoolManager.Instance:CleanByType(PoolType.hero_tpose)
    PoolManager.Instance:CleanByType(PoolType.battle_effect)
end

function BattleClientWorld:OnUpdate()
    --self.world.BattleInputSystem:Update()
    self.world.ClientEntitySystem:Update()
    self.world.BattleAssetsSystem:Update()

    if BattleDefine.mainPanel and BattleDefine.mainPanel:Active() then
        BattleDefine.mainPanel:Update()
    end
end

function BattleClientWorld:OnLateUpdate()
    self.world.ClientEntitySystem:LateUpdate()
end

