ParabolicJumpEntityBehavior = BaseClass("ParabolicJumpEntityBehavior",SkillBehavior)
--TODO:缓存清理
function ParabolicJumpEntityBehavior:__Init()
end

function ParabolicJumpEntityBehavior:__Delete()
end

function ParabolicJumpEntityBehavior:OnInit(targetUid)
    self.skill:AddRefNum(1)

    self.targetEntityUid = targetUid
    local targetEntity = self.world.EntitySystem:GetEntity(targetUid)
    self.targetPos = targetEntity.TransformComponent:GetPos()

    self:CreateTimeline()

    self.ownerEntity = self.world.EntitySystem:GetEntity(self.entity.ownerUid)

    local info = {}
    info.onComplete = self:ToFunc("JumpComplete")
    info.params = {targetUid = self.targetEntityUid,targetPos = self.targetPos, speed = self.actionParam.speed,maxHeight = self.actionParam.maxHeight,logicPos = self.ownerEntity.TransformComponent:GetPos()}
    info.moverType = BattleDefine.MoverType.parabola

    self:AddMarkState(self.ownerEntity,BattleDefine.MarkState.move_releasing_skill)
    self.ownerEntity.MoveComponent:MoveToPos(self.targetPos.x,self.targetPos.y,self.targetPos.z,info)
    --TODO 到达后重新搜寻目标，开始子timeline
end

function ParabolicJumpEntityBehavior:CreateTimeline()
    if not self.actionParam or self.actionParam.actId == 0 then
        return
    end

    local actConf = self.skill.actConf.Child[self.actionParam.actId]
    if not actConf then
        assert(false,string.format("找不到技能行为子配置[技能ID:%s][技能等级:%s][子行为Id:%s]",self.skill.skillId,self.skill.skillLev,tostring(self.actionParam.actId)))
    end

    self:AddBehaviorPack(SkillTimelinePack)
    self.SkillTimelinePack:Init(actConf,self.ownerEntity,self.skill,self:ToFunc("TimelineComplete"))
end

function ParabolicJumpEntityBehavior:JumpComplete()
    self:RemoveMarkState(self.ownerEntity,BattleDefine.MarkState.move_releasing_skill)

    if self.SkillTimelinePack then
        local transInfo = {posX = self.targetPos.x,posZ = self.targetPos.z}
        self.SkillTimelinePack:Start({self.targetEntityUid},transInfo)
    end
end

function ParabolicJumpEntityBehavior:TimelineComplete()
    self:RemoveMarkState(self.ownerEntity,BattleDefine.MarkState.move_releasing_skill)

    LogError(self.ownerEntity.StateComponent.markState)
    self:SetRemove(true)
end