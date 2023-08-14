DelayDieBehavior = BaseClass("DelayDieBehavior",SkillBehavior)

function DelayDieBehavior:__Init()
    self.timeCount = 0
end

function DelayDieBehavior:__Delete()
end

function DelayDieBehavior:OnInit()
    self.skill:AddRefNum(1)

    self:AddMarkState(self.entity,BattleDefine.MarkState.delay_die)

    local eventArgs = {}
    eventArgs.entityUid = self.entity.uid
    self:AddEvent(BattleEvent.check_miss_hit,self:ToFunc("OnCheckMissHit"),eventArgs)
end

function DelayDieBehavior:OnUpdate()
    self.timeCount = self.timeCount + self.world.opts.frameDeltaTime
    if self.timeCount >= self.levParam.delayTime then
        self:DieAction()
    end
end

function DelayDieBehavior:OnCheckMissHit(params)
    local hitConf = self.world.BattleConfSystem:HitResultData_data_hit_result(params.hitResultId)
    if self.actionParam.hitFlag == -1 then
        return false
    elseif hitConf.flag == self.actionParam.hitFlag then
        return false
    else
        return true
    end
end

function DelayDieBehavior:DieAction()
    self:RemoveMarkState(self.entity,BattleDefine.MarkState.delay_die)
    self.entity.BehaviorComponent:RemoveBehavior(self.uid)
    self.world.BattleHitSystem:CheckDie(BattleDefine.HitFrom.other,self.entity.uid,-1,self.entity,nil)
end