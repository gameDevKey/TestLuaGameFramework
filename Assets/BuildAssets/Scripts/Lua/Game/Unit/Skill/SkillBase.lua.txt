---技能基类
---流程： 满足释放条件(CD/事件/状态/范围...) --> 选择技能目标 --> 技能释放 --> 执行技能行为 --> 下一次轮询或者结束
---角色发射子弹, 击中目标
---角色绑定技能A
---满足条件 cd=1s 前置条件 监听事件 可释放技能状态 
---技能Timeline配置
---命中系统
---结算系统
SkillBase = Class("SkillBase",ECSLBase)

function SkillBase:OnInit(conf)
    self.enable = true
    self.conf = conf
    self.skillId = self.conf.Id
    self.cdTime = 0
    self.cdTimer = 0
    self:SetCD(self.conf.CD)
    self.events = {}
    self.isReleasing = false
end

function SkillBase:OnDelete()
    for eventKey, eventId in pairs(self.events or NIL_TABLE) do
        self.world.GameEventSystem:RemoveListener(eventId, eventKey)
    end
    self.events = nil
    self:ActiveAtkRange(false)
end

--技能释放
function SkillBase:Rel()
    if not self.enable then
        return false
    end
    self:ActiveAtkRange(true)
    local targetUids = self:FindTargets()
    self:Exec(targetUids)
end

--技能执行
function SkillBase:Exec(targetUids)
    if not self.enable then
        return
    end
    self:ExecTimeline({
        targetUids=targetUids
    })
end

function SkillBase:CreateTimeline()
    local data = require("Data.Skill."..self.conf.Timeline)
    local timeline = SkillTimeline.New(data,{ 
        finishFunc = self:ToFunc("FinishTimeline")
    })
    timeline:SetWorld(self.world)
    timeline:BindSkill(self)
    timeline:SetActionHandler(timeline)
    return timeline
end

function SkillBase:ExecTimeline(args)
    self.isReleasing = true
    if not self.timeline then
        self.timeline = self:CreateTimeline()
    end
    self.timeline:SetArgs(args)
    self.timeline:Start()
end

--技能结束
function SkillBase:FinishTimeline()
    self.isReleasing = false
    if self.timeline then
        self.timeline:Delete()
        self.timeline = nil
    end
    self.cdTimer = self.cdTime
    self:ActiveAtkRange(false)
end

---技能被打断
function SkillBase:Abort()
    self.cdTimer = self.cdTime
end

function SkillBase:SetEntity(entity)
    self.entity = entity
end

function SkillBase:SetCD(cdTime)
    self.cdTime = cdTime
    self.cdTimer = self.cdTime
end

function SkillBase:ResetCD()
    self.cdTimer = self.cdTime
end

function SkillBase:GetCD()
    return self.cdTime
end

function SkillBase:GetRemainCD()
    return self.cdTimer
end

function SkillBase:IsCD()
    return self.cdTimer > 0
end

function SkillBase:IsReleasing()
    return self.isReleasing
end

function SkillBase:UpdateCD(delatTime)
    if self.cdTimer > 0 then
        self.cdTimer = self.cdTimer - delatTime
    else
        self.cdTimer = 0
    end
end

function SkillBase:Update(delatTime)
    self:CallFuncDeeply("OnUpdate",true,delatTime)
end

function SkillBase:Enable(enable)
    self.enable = enable
end

function SkillBase:CheckCond(pattern)
    return self.entity.CalcComponent:IsTrue(pattern)
end

function SkillBase:FindTargets()
    local targets = self.world.SearchSystem:FindEntity({
        entityUid = self.entity:GetUid(),
        rangeData = self.conf.Range,
        matchPattern = nil,
    })
    return targets
end

function SkillBase:BindCond()
    --TODO 绑定一个SkillCondBase，当监听条件满足后，触发Exec
end

function SkillBase:OnUpdate(delatTime)
    if self.timeline then
        self.timeline:Update(delatTime)
    end
end

function SkillBase:ActiveAtkRange(active)
    if self.entity.RangeComponent then
        self.entity.RangeComponent:SetEnable(active)
        if active then
            self.entity.RangeComponent:SetRange(self.conf.Range)
        end
    end
end

return SkillBase