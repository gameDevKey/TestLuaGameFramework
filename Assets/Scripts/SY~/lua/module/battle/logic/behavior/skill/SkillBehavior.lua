SkillBehavior = BaseClass("SkillBehavior",SECBBehavior)

function SkillBehavior:__Init()
    self.isRemove = false
    self.skill = nil
    self.actionParam = nil
    self.levParam = nil
    self.transInfo = nil
    self.timeline = nil
    self.relUid = 0
    self.events = {}
    self.markStates = {}
end

function SkillBehavior:__Delete()
    self.skill:AddRefNum(-1)
    self:ClearEvent()
end

function SkillBehavior:SetSkill(skill)
    self.skill = skill
    self.relUid = skill.relUid
end

function SkillBehavior:SetTimeline(timeline)
    self.timeline = timeline
end

function SkillBehavior:SetActionParam(actionParam)
    self.actionParam = actionParam
    if self.actionParam.levParam then
        self.levParam = self.actionParam.levParam[self.skill.skillLev] or self.actionParam.levParam[0]
    end
end

function SkillBehavior:SetTransInfo(transInfo)
    self.transInfo = transInfo
end

function SkillBehavior:SetRemove(flag)
    self.isRemove = flag
end

function SkillBehavior:Update()
    if self.isRemove then
        self.world.EntitySystem:RemoveEntity(self.entity.uid)
    else
        self:OnUpdate()
    end
end

function SkillBehavior:HitEntitys(entitys,hitUid,hitEffectId)
    local fromUid = self.entity.ownerUid or self.entity.uid
    local hitArgs = {skill = self.skill, skillId = self.skill.skillId, skillLev = self.skill.skillLev,hitUid = hitUid or self.actionParam.hitUid, relUid = self.relUid}
    local hitResultId = self.skill:GetHitResultId(hitArgs.hitUid)
    local hitEffectId = hitEffectId or self.actionParam.hitEffectId
    self.world.BattleHitSystem:HitEntitys(fromUid,entitys,hitArgs,hitResultId,hitEffectId)
end

function SkillBehavior:OnUpdate()
    for i, v in ipairs(self.behaviorPacks) do
        v:Update()
    end
end

function SkillBehavior:AddEvent(event,callBack,eventArgs)
    local uid = self.world.EventTriggerSystem:AddListener(event,self:ToFunc("_CallEvent"),eventArgs)
    self.events[uid] = callBack
    return uid
end

--禁止被重写
function SkillBehavior:_CallEvent(args,eventUid)
    if not self.events[eventUid] then
        return
    end
    return self.events[eventUid](args)
end

function SkillBehavior:RemoveEvent(uid)
	self.world.EventTriggerSystem:RemoveListener(uid)
	self.events[uid] = nil
end

function SkillBehavior:ClearEvent()
    for uid,_ in pairs(self.events) do
        self.world.EventTriggerSystem:RemoveListener(uid)
    end
    self.events = {}
end

function SkillBehavior:AddMarkState(entity,state)
    if entity and entity.StateComponent then
        local uid = entity.StateComponent:AddMarkState(state)
        if not self.markStates[entity.uid] then
            self.markStates[entity.uid] = {}
        end
        table.insert(self.markStates[entity.uid], {
            state = state,
            uid = uid,
        })
    end
end

function SkillBehavior:RemoveMarkState(entity,state)
    if entity and entity.StateComponent then
        local info = self.markStates[entity.uid]
        if info then
            for i = #info, 1, -1 do
                local data = info[i]
                if data.state == state then
                    entity.StateComponent:RemoveMarkStateByUid(data.uid)
                    table.remove(info,i)
                end
            end
        end
    end
end

function SkillBehavior:RemoveMarkStateByUid(entity,uid)
    if entity and entity.StateComponent then
        local info = self.markStates[entity.uid]
        if info then
            for i = #info, 1, -1 do
                local data = info[i]
                if data.uid == uid then
                    entity.StateComponent:RemoveMarkStateByUid(data.uid)
                    table.remove(info,i)
                end
            end
        end
    end
end