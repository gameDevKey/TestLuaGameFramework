PullEntityBehavior = BaseClass("PullEntityBehavior",SkillBehavior)

function PullEntityBehavior:__Init()

end

function PullEntityBehavior:__Delete()
    self.pullArgs:Delete()
end

function PullEntityBehavior:OnInit(targetEntitys)
    self.skill:AddRefNum(1)

    self.pullArgs = SECBList.New()
    self.targetEntitys = targetEntitys
    self:print("进入",targetEntitys)
    for _, uid in ipairs(self.targetEntitys or {}) do
        self:StartPull(uid)
    end

    local eventArgs = {}
    eventArgs.entityUid = self.entity.uid
    self:AddEvent(BattleEvent.do_control,self:ToFunc("OnDoControl"),eventArgs)
end

function PullEntityBehavior:StartPull(entityUid)
    if not self.world.EntitySystem:HasEntity(entityUid) then
        return
    end
    local entity = self.world.EntitySystem:GetEntity(entityUid)
    self:print("开始拉拢",entityUid,'->',self.entity.uid)
    self:AddOrRemoveBuff(entity,self.actionParam.buffs,true)
    self:StartJump(entity,self.entity)
end

function PullEntityBehavior:PullComplete(args)
    local entity = self.world.EntitySystem:GetEntity(args.fromUid)
    if entity then
        self:print("结束拉拢",args.fromUid,'->',args.toUid)
        self:AddOrRemoveBuff(entity,self.actionParam.buffs,false)
        self.pullArgs:RemoveByIndex(args.fromUid)
    end
    if self.pullArgs:Count() == 0 then
        self:PullAllComplete()
    end
end

function PullEntityBehavior:PullAllComplete()
    self:print("拉拢行为结束")
    self.entity.BehaviorComponent:RemoveBehavior(self.uid)
end

function PullEntityBehavior:AddOrRemoveBuff(entity,buffList,addOrRemove)
    if entity then
        for _, buffId in ipairs(buffList or {}) do
            if addOrRemove then
                self:print("添加Buff",entity.uid, buffId)
                entity.BuffComponent:AddBuff(self.entity.uid,buffId)
            else
                self:print("移除Buff",entity.uid, buffId)
                entity.BuffComponent:RemoveBuffById(buffId)
            end
        end
    end
end

function PullEntityBehavior:StartJump(fromEntity,toEntity)
    self:AddMarkState(fromEntity,BattleDefine.MarkState.force_move)

    fromEntity.SkillComponent:Break()

    local fromPos = fromEntity.TransformComponent:GetPos()
    local targetPos = toEntity.TransformComponent:GetPos()
    local fromR = fromEntity.CollistionComponent:GetRadius()
    local targetR = toEntity.CollistionComponent:GetRadius()

    local targetForwardPos = toEntity.TransformComponent:GetForwardPos(targetR+fromR)

    local fixTargetPos = {
        posX = targetForwardPos.x,
        posY = targetForwardPos.y,
        posZ = targetForwardPos.z
    }

    self:print("开始拉拢动画",fromEntity.uid,toEntity.uid)

    local info = {}
    info.onComplete = self:ToFunc("JumpComplete")
    info.params = {
        logicPos = fromPos,
        targetPos = fixTargetPos,
        speed = self.actionParam.jumpSpeed,
        maxHeight = self.actionParam.jumpMaxHeight,
        moveMaxTime = self.actionParam.jumpMaxTime,
    }
    info.args = {
        fromUid = fromEntity.uid,
        toUid = toEntity.uid,
    }
    info.moverType = BattleDefine.MoverType.parabola

    self.pullArgs:Push(info.args, fromEntity.uid)

    if fromEntity.MoveComponent then
        fromEntity.MoveComponent:MoveToPos(fixTargetPos.posX,fixTargetPos.posY,fixTargetPos.posZ,info)
    else
        self:print("!!!!!被吞单位丢失移动组件",fromEntity.uid)
    end
end

function PullEntityBehavior:JumpComplete(args)
    self:print("拉拢动画结束",args.fromUid,'-->',args.toUid)
    local fromEntity = self.world.EntitySystem:GetEntity(args.fromUid)
    if fromEntity then
        self:RemoveMarkState(fromEntity,BattleDefine.MarkState.force_move)
        if fromEntity.MoveComponent then
            fromEntity.MoveComponent:StopMove()
        end
    end
    self:PullComplete(args)
end

--被控制时打断
function PullEntityBehavior:OnDoControl()
    self:print("技能被打断")
    for iter in self.pullArgs:Items() do
        local args = iter.value
        self:JumpComplete(args)
    end
end

function PullEntityBehavior:OnUpdate()

end

--TODO 后面移除
PullEntityBehavior.LOG = false
function PullEntityBehavior:print(...)
    if not PullEntityBehavior.LOG then
        return
    end
    if self.world.isCheck then
        return
    end
    LogYqh("PullEntityBehavior",self.entity.uid,...)
end