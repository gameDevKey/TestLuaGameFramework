TryToDodgeHitResultBehavior = BaseClass("TryToDodgeHitResultBehavior",BuffBehavior)

function TryToDodgeHitResultBehavior:__Init()
end

function TryToDodgeHitResultBehavior:__Delete()
end

function TryToDodgeHitResultBehavior:OnInit()
    local eventParam = {}
    eventParam.entityUid = self.entity.uid

    self.baseProb = self.actionParam.baseProb
    self.failed = self.actionParam.failed
    self.succeed= self.actionParam.succeed
    self.reset = self.actionParam.reset
    self.curProb = self.actionParam.baseProb

    self:AddEvent(BattleEvent.unit_try_to_dodge_hit_result,self:ToFunc("OnEvent"),eventParam)
end

function TryToDodgeHitResultBehavior:OnEvent(args)
    -- Log(args.targetEntityUids[1].."尝试闪避"..args.fromEntityUid.."的命中结算"..args.hitResultId)
    local probArgs = {prob = self.curProb}
    local dodgeFlag = self.world.PluginSystem.CheckCond:Prob(nil,probArgs)
    if dodgeFlag then
        -- Log("闪避成功 effectId"..self.actionParam.effectId)
        self.world.BattleAssetsSystem:PlayUnitEffect(self.entity.uid, self.actionParam.effectId)
        if self.reset then
            self.curProb = self.baseProb
        else
            self.curProb = self.curProb + self.succeed
        end
        self.world.ClientIFacdeSystem:Call("SendEvent","FlyingTextView","ShowFlyingText",BattleDefine.FlyingText.state,
        {state = BattleDefine.FlyingTextState.dodge,uid = self.entity.uid})
    else
        -- Log("闪避失败")
        self.curProb = self.curProb + self.failed
    end
    -- Log("当前概率：",self.curProb )
    return dodgeFlag
end