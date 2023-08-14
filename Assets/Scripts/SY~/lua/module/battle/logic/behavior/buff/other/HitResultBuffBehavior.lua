HitResultBuffBehavior = BaseClass("HitResultBuffBehavior",BuffBehavior)

function HitResultBuffBehavior:__Init()

end

function HitResultBuffBehavior:__Delete()

end

function HitResultBuffBehavior:OnInit()
    self.hitUidNum = #self.actionParam.hitUid
end

function HitResultBuffBehavior:OnExecute()
    local index = self.buff.execNum + 1
    if index > self.hitUidNum then
        index = self.hitUidNum
    end

    local args = nil
    if self.buff.args and self.buff.args.calcVal then
        args = {calcVal = self.buff.args.calcVal}
    end
    
    local hitResultId = self.actionParam.hitUid[index]
    self.world.BattleHitSystem:HitResult(BattleDefine.HitFrom.buff,self.buff.fromEntityUid,self.entity.uid,hitResultId,args)
    return true
end

function HitResultBuffBehavior:OnDestroy()

end