BattleMixedEffectView = BaseClass("BattleMixedEffectView",ExtendView)

BattleMixedEffectView.Event = EventEnum.New(
    "UseUpCardSuccess",
    "UseDownCardSuccess",
    "UseCardFailed",
    "PlayUnitBornEffect",
    "PlayRoadEffect",
    "PlayRelRangeEffect"
)

function BattleMixedEffectView:__Init()
    self.upTrailing = nil
    self.downTrailing = nil
    self.failedEffect = nil

    self.moveAnims = {}
end

function BattleMixedEffectView:__Delete()

end

function BattleMixedEffectView:__CacheObject()

end

function BattleMixedEffectView:__BindEvent()
    self:BindEvent(BattleMixedEffectView.Event.UseUpCardSuccess)
    self:BindEvent(BattleMixedEffectView.Event.UseDownCardSuccess)
    self:BindEvent(BattleMixedEffectView.Event.UseCardFailed)
    self:BindEvent(BattleMixedEffectView.Event.PlayUnitBornEffect)
    self:BindEvent(BattleMixedEffectView.Event.PlayRoadEffect)
    self:BindEvent(BattleMixedEffectView.Event.PlayRelRangeEffect)
end

function BattleMixedEffectView:__Hide()
    if self.upTrailing then
        self.upTrailing:Delete()
        self.upTrailing = nil
    end

    if self.downTrailing then
        self.downTrailing:Delete()
        self.downTrailing = nil
    end

    if self.failedEffect then
        self.failedEffect:Delete()
        self.failedEffect = nil
    end

    for k, v in pairs(self.moveAnims) do
        v:Destroy()
    end
    self.moveAnims = {}

    self:RemoveRelRangeEffect()
end

function BattleMixedEffectView:UseUpCardSuccess(transInfo,grid)
    do
        return
    end
    local screenPos = BaseUtils.WorldToUIPoint(BattleDefine.nodeObjs["main_camera"],Vector3(transInfo.posX/1000,0,transInfo.posZ/1000))
    if not self.upTrailing then
        local setting = {}
        setting.confId = 5001010
        setting.parent = BattleDefine.uiObjs["mixed_effect"]
        local effect = UIEffect.New()
        effect:Init(setting)

        self.upTrailing = effect
    end
    self.upTrailing:SetPos(screenPos.x,screenPos.y,screenPos.z)
    self.upTrailing:Play()

    -- local worldPos = RunWorld.BattleMixedSystem:GetPlaceSlotPos(grid)--TODO BattleOperateView:GetPlaceSlotPos()
    -- local targetPos = BaseUtils.WorldToUIPoint(BattleDefine.nodeObjs["main_camera"],worldPos)
    -- local moveAnim = MoveLocalAnim.New(self.upTrailing.transform,targetPos,0.7)
    -- moveAnim:SetDelay(0.5)
    -- table.insert(self.moveAnims,moveAnim)
    -- local cb = function ()
    --     self.upTrailing:Stop()
    --     -- RunWorld.ClientIFacdeSystem:Call("SendEvent",BattleHeroOperateView.Event.ActiveUnitStar,grid,1)--TODO 转到ui特效
    -- end
    -- moveAnim:SetComplete(cb)
    -- moveAnim:Play()
end

function BattleMixedEffectView:UseDownCardSuccess(transInfo,unitId)
    local screenPos = BaseUtils.WorldToUIPoint(BattleDefine.nodeObjs["main_camera"],Vector3(transInfo.posX/1000,0,transInfo.posZ/1000))
    if not self.downTrailing then
        local setting = {}
        setting.confId = 5002010
        setting.parent = BattleDefine.uiObjs["mixed_effect"]
        local effect = UIEffect.New()
        effect:Init(setting)

        self.downTrailing = effect
    end
    self.downTrailing:SetPos(screenPos.x,screenPos.y,screenPos.z)
    self.downTrailing:Play()

    local targetTrans = {}
    RunWorld.ClientIFacdeSystem:Call("SendEvent","BattleEnemyGridView","GetUIPosByUnitId",unitId,targetTrans)

    local toPos = targetTrans.transform.position

    local moveAnim = MoveAnim.New(self.downTrailing.transform,toPos,0.7)
    -- moveAnim:SetDelay(0.3)
    table.insert(self.moveAnims,moveAnim)
    local cb = function ()
        self.downTrailing:Stop()
        RunWorld.ClientIFacdeSystem:Call("SendEvent","BattleEnemyGridView","ActiveEnemyUnitStar",unitId,-1)
    end
    moveAnim:SetComplete(cb)
    moveAnim:Play()
end

function BattleMixedEffectView:UseCardFailed(transInfo)
    local screenPos = BaseUtils.WorldToUIPoint(BattleDefine.nodeObjs["main_camera"],Vector3(transInfo.posX/1000,0,transInfo.posZ/1000))
    if not self.failedEffect then
        local setting = {}
        setting.confId = 5001014
        setting.parent = BattleDefine.uiObjs["mixed_effect"]
        local effect = UIEffect.New()
        effect:Init(setting)

        self.failedEffect = effect
    end
    self.failedEffect:SetPos(screenPos.x,screenPos.y,screenPos.z)
    self.failedEffect:Play()
end

function BattleMixedEffectView:PlayUnitBornEffect(pos)
    RunWorld.BattleAssetsSystem:PlaySceneEffect(100010,pos.x,pos.y,pos.z)
end

function BattleMixedEffectView:PlayRoadEffect(activeMid,activeSide)
    local effectId = 100013
    if activeMid then
        if activeSide then
            effectId = 100013
        else
            effectId = 100016
        end
    else
        if activeSide then
            effectId = 100015
        end
    end
    RunWorld.BattleAssetsSystem:PlaySceneEffect(effectId,0,0,0)
end

function BattleMixedEffectView:PlayRelRangeEffect(relRangeType,active,allCanNotRel)
    if active then
        if allCanNotRel then
            self.allRangeCanRelEffect = RunWorld.BattleAssetsSystem:PlaySceneEffect(100018,0,0,0,EffectDefine.EffectType.action)
        else
            if relRangeType == SkillDefine.RelRangeType.all then
                self.allRangeCanRelEffect = RunWorld.BattleAssetsSystem:PlaySceneEffect(100017,0,0,0,EffectDefine.EffectType.action)
            else
                local roleUid = RunWorld.BattleDataSystem.roleUid
                local selfCamp = RunWorld.BattleDataSystem:GetCampByRoleUid(roleUid)
                local enemyCamp = nil
                local selfAreaMidPos = {}
                local enemyAreaMidPos = {}
                if selfCamp == BattleDefine.Camp.attack then
                    enemyCamp = BattleDefine.Camp.defence
                else
                    enemyCamp = BattleDefine.Camp.attack
                end
                local terrainInfo = RunWorld.BattleTerrainSystem.terrainInfos[selfCamp]
                local midX = (terrainInfo.areaBeginX + terrainInfo.areaEndX) / 2
                local midZ = (terrainInfo.areaBeginZ + terrainInfo.areaEndZ) / 2
                selfAreaMidPos.x = midX
                selfAreaMidPos.z = midZ

                terrainInfo = RunWorld.BattleTerrainSystem.terrainInfos[enemyCamp]
                midX = (terrainInfo.areaBeginX + terrainInfo.areaEndX) / 2
                midZ = (terrainInfo.areaBeginZ + terrainInfo.areaEndZ) / 2
                enemyAreaMidPos.x = midX
                enemyAreaMidPos.z = midZ

                if relRangeType == SkillDefine.RelRangeType.self then
                    self.selfHalfCanRelEffect = RunWorld.BattleAssetsSystem:PlaySceneEffect(100019,selfAreaMidPos.x,0,selfAreaMidPos.z,EffectDefine.EffectType.action)
                    self.enemyHalfCanRelEffect = RunWorld.BattleAssetsSystem:PlaySceneEffect(100022,enemyAreaMidPos.x,0,enemyAreaMidPos.z,EffectDefine.EffectType.action)
                else
                    self.selfHalfCanRelEffect = RunWorld.BattleAssetsSystem:PlaySceneEffect(100021,selfAreaMidPos.x,0,selfAreaMidPos.z,EffectDefine.EffectType.action)
                    self.enemyHalfCanRelEffect = RunWorld.BattleAssetsSystem:PlaySceneEffect(100020,enemyAreaMidPos.x,0,enemyAreaMidPos.z,EffectDefine.EffectType.action)
                end
            end
        end
    else
        self:RemoveRelRangeEffect()
    end
end

function BattleMixedEffectView:RemoveRelRangeEffect()
    if self.allRangeCanRelEffect then
        self.allRangeCanRelEffect:Delete()
        self.allRangeCanRelEffect = nil
    end
    if self.selfHalfCanRelEffect then
        self.selfHalfCanRelEffect:Delete()
        self.selfHalfCanRelEffect = nil
    end
    if self.enemyHalfCanRelEffect then
        self.enemyHalfCanRelEffect:Delete()
        self.enemyHalfCanRelEffect = nil
    end
end