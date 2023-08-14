BackstabHitEntityBehavior = BaseClass("BackstabHitEntityBehavior",SkillBehavior)
--TODO:缓存清理
function BackstabHitEntityBehavior:__Init()
end

function BackstabHitEntityBehavior:__Delete()
    
end

function BackstabHitEntityBehavior:OnInit(targetUid)
    self.skill:AddRefNum(1)

    local selectTargetEntity = self.world.EntitySystem:GetEntity(targetUid)
    local selectTargetEntityPos = selectTargetEntity.TransformComponent:GetPos()
    local forward = selectTargetEntity.TransformComponent:GetForward()

    --
    local searchParams = self.world.BattleCastSkillSystem.skillSearchParams
    searchParams.entity = self.entity
    searchParams.range = self.skill:GetHitRange()
    searchParams.transInfo = {}
    searchParams.transInfo.posX = selectTargetEntityPos.x
    searchParams.transInfo.posZ = selectTargetEntityPos.z
    searchParams.transInfo.dirX = forward.x
    searchParams.transInfo.dirZ = forward.z
    searchParams.targetNum = 1
    searchParams.priorityType1 = BattleDefine.SearchPriority.min_to_enemy_home_dis
    searchParams.isLock = true
    local hitEntitys,_ = self.world.BattleCastSkillSystem:SkillSearchEntity(self.skill,searchParams)
    targetUid = hitEntitys[1]
    if not targetUid then
        self:SetRemove(true)
        return
    end


    local ownerEntity = self.world.EntitySystem:GetEntity(self.entity.ownerUid)
    local targetEntity = self.world.EntitySystem:GetEntity(targetUid)
    local targetEntityPos = targetEntity.TransformComponent:GetPos()
    local fromDiff = -targetEntity.TransformComponent:GetForward()

    local targetRadius = targetEntity.CollistionComponent:GetRadius()
    local offsetDir = fromDiff * (self.actionParam.distance+targetRadius)
    local targetPos = targetEntityPos + offsetDir

    ownerEntity.TransformComponent:SetFixedPos(targetPos.x,targetPos.y,targetPos.z)
    ownerEntity.RotateComponent:LookAtPos(targetEntityPos.x,targetEntityPos.z)

    ownerEntity.AnimComponent:PlayAnim(self.actionParam.animName)

    -- local hitArgs = {skillId = self.skill.skillId,skillLev = self.skill.skillLev,hitUid = self.actionParam.hitUid}
    -- local hitResultId = self.skill:GetHitResultId(self.actionParam.hitUid)
    -- self.world.BattleAssetsSystem:PlayHitEffect(targetUid,self.actionParam.hitEffectId)
    -- self.world.BattleHitSystem:HitResult(BattleDefine.HitFrom.skill,self.entity.ownerUid,targetUid,hitResultId,hitArgs)
    self:HitEntitys({targetUid})

    self:SetRemove(true)
end