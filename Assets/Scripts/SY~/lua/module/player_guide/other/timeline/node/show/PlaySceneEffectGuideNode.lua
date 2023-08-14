PlaySceneEffectGuideNode = BaseClass("PlaySceneEffectGuideNode",BaseGuideNode)

function PlaySceneEffectGuideNode:__Init()
    self.effect = nil
end

function PlaySceneEffectGuideNode:OnStart()
    local x,y,z = self:GetTargetObjectPos()

    local offsetOrder = self.actionParam.offsetOrder or 0

    local order = ViewDefine.Layer["PlayerGuideView_Effect"] + offsetOrder

    order = MathUtils.Clamp(order, 0, 32767)

    local effectId = self.actionParam.effectId
    local eff = RunWorld.BattleAssetsSystem:PlaySceneEffect(effectId,x,y,z)
    eff:SetOrder(order)
end

function PlaySceneEffectGuideNode:OnDestroy()
    if self.effect then
        self.effect:Delete()
        self.effect = nil
    end
end