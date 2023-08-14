AreaComponent = BaseClass("AreaComponent",SECBComponent)

function AreaComponent:__Init()
    self.lastPos = FPVector3(0,0,0)
    self.areaCamp = nil
    self.roadIndex = BattleDefine.RoadIndex.none
end

function AreaComponent:__Delete()

end

function AreaComponent:OnInit()
end

function AreaComponent:OnLateUpdate()
    local pos = self.entity.TransformComponent:GetPos()
    if self.lastPos ~= pos or not self.areaCamp or self.roadIndex == BattleDefine.RoadIndex.none then
        self.lastPos:SetByFPVector3(pos)
        local areaCamp = self.world.BattleTerrainSystem:PosToCamp(self.lastPos.x,self.lastPos.z,self.entity.CampComponent.camp)
        if self.areaCamp ~= areaCamp then
            self:SetAreaCamp(areaCamp)
        end

        self.roadIndex = self.world.BattleTerrainSystem:GetRoadIndex(self.lastPos.x)
    end
end

function AreaComponent:SetAreaCamp(areaCamp)
    self.areaCamp = areaCamp
    self.world.EventTriggerSystem:Trigger(BattleEvent.enter_camp_area,self.entity.uid,self.areaCamp,self.entity.CampComponent.camp)
end
