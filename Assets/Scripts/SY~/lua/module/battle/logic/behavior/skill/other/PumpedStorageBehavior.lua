PumpedStorageBehavior = BaseClass("PumpedStorageBehavior",SkillBehavior)

function PumpedStorageBehavior:__Init()
    self.hitResultVal = 0
end

function PumpedStorageBehavior:__Delete()
end

function PumpedStorageBehavior:OnInit(targetEntitys)
    self.targetEntitys = targetEntitys

    self.skill:AddRefNum(1)

    local eventArgs = {}
    eventArgs.entityUid = self.entity.uid
    eventArgs.beHitUnit = 1
    self:AddEvent(BattleEvent.unit_be_hit,self:ToFunc("OnBeHit"),eventArgs)

    local eventArgs = {}
    eventArgs.entityUid = self.entity.uid
    self:AddEvent(BattleEvent.do_control,self:ToFunc("OnDoControl"),eventArgs)

    local eventArgs = {}
    eventArgs.entityUid = self.entity.uid
    eventArgs.relUid = self.relUid
    self:AddEvent(BattleEvent.skill_complete,self:ToFunc("OnSkillComplete"),eventArgs)
end

function PumpedStorageBehavior:OnBeHit(params)
    self.hitResultVal = self.hitResultVal + params.beHitValue
end

function PumpedStorageBehavior:OnSkillComplete()
    self:HitAction()
end

function PumpedStorageBehavior:OnDoControl()
    self:HitAction()
end

function PumpedStorageBehavior:HitAction()
    self:ClearEvent()

    local attrType = BattleUtils.GetConfAttr(self.levParam.maxHitVal.attr)
    local mode = self.levParam.maxHitVal.mode
    local maxHitVal = self.world.PluginSystem.CalcAttr:CalcAttr(self.entity.uid,nil,mode,attrType,self.levParam.maxHitVal)

    --
    local targetEntitys = nil
    if self.skill.baseConf.lock_target == 1 then
        targetEntitys = self.targetEntitys
    else
        local searchParams = self.world.BattleCastSkillSystem.skillSearchParams
        searchParams.entity = self.entity
        searchParams.range = self.skill:GetHitRange()
        searchParams.targetNum = self.skill:GetHitNum()
        searchParams.transInfo.posX = self.transInfo.posX
        searchParams.transInfo.posZ = self.transInfo.posZ
        searchParams.transInfo.dirX = self.transInfo.dirX
        searchParams.transInfo.dirZ = self.transInfo.dirZ
        targetEntitys,_ = self.world.BattleCastSkillSystem:SkillSearchEntity(self.skill,searchParams)
    end


    local hitArgs = {skill = self.skill, skillId = self.skill.skillId,skillLev = self.skill.skillLev,hitUid = self.levParam.hitUid,relUid = self.relUid}
    hitArgs.calcVal = self.hitResultVal
    hitArgs.maxHitVal = maxHitVal
    --

    local hitResultId = self.skill:GetHitResultId(self.levParam.hitUid)
    self.world.BattleHitSystem:HitEntitys(self.entity.uid,targetEntitys,hitArgs,hitResultId,self.actionParam.hitEffectId)


    self.entity.BehaviorComponent:RemoveBehavior(self.uid)
end