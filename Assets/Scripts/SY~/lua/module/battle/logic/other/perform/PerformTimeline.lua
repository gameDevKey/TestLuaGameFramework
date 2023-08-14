PerformTimeline = BaseClass("PerformTimeline",SECBTimeline)

function PerformTimeline:__Init()
    self.entity = nil
    self:SetHandler(BattleDefine.PerformTimelineNode)
end

function PerformTimeline:__Delete()

end

function PerformTimeline:OnInit(entity)
    self.entity = entity
end

function PerformTimeline:OnStart()
end


function PerformTimeline:PlayAnim(params)
    if not self.entity.AnimComponent then
        assert(false,string.format("实体不存在动作组件[unitId:%s]",self.entity.ObjectDataComponent.unitConf.id))
    end
    self.entity.AnimComponent:PlayAnim(params.animName)
end
--
function PerformTimeline:PlaySelfEffect(params)
    self.world.BattleAssetsSystem:PlayUnitEffect(self.entity.uid,params.effectId)
end

function PerformTimeline:PlaySceneEffect(params)
    local pos = self.entity.TransformComponent:GetPos()
    self.world.BattleAssetsSystem:PlaySceneEffect(params.effectId,pos.x,pos.y,pos.z)
end