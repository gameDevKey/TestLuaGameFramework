SceneEffect = BaseClass("SceneEffect",EffectBase)
SceneEffect.poolKey = "battle_scene_effect"

function SceneEffect:__Init()

end

function SceneEffect:__Delete()

end

function SceneEffect:OnInit()
    local parent = self.setting.parent or BattleDefine.nodeObjs["effect"]
    self:SetParent(parent)

    if self.setting.pos then
        self:SetPos(self.setting.pos.x,self.setting.pos.y,self.setting.pos.z)
    end
end

function SceneEffect:OnCreate()
    self.effect.transform:SetLocalEulerAngles(0,self.effectManager.world.BattleTerrainSystem.angleDir * 180, 0)
end