BaseGuideNode = BaseClass("BaseGuideNode")

function BaseGuideNode:__Init()
    self.timeline = nil
    self.actionParam = nil
    self.autoRunTimer = nil
end

function BaseGuideNode:Init(timeline,actionParam,...)
    self.timeline = timeline
    self.actionParam = actionParam
    self:OnInit(...)
end

function BaseGuideNode:Start()
    self:OnStart()
    self:TryAutoRun()
end

function BaseGuideNode:Update()
    self:OnUpdate()
end

function BaseGuideNode:Destroy()
    if self.autoRunTimer then
        LogGuide("行为结束，移除定时器",self.autoRunTimer.id)
        TimerManager.Instance:RemoveTimer(self.autoRunTimer)
        self.autoRunTimer = nil
    end
    self:OnDestroy()
end

function BaseGuideNode:GetTargetPos()
    local x,y
    if self.actionParam.x and self.actionParam.y then
        x = self.actionParam.x
        y = self.actionParam.y
    else
        x = self.timeline.targetArgs.targetPos.x + (self.actionParam.offsetX or 0)
        y = self.timeline.targetArgs.targetPos.y + (self.actionParam.offsetY or 0)
    end
    return x,y
end

function BaseGuideNode:GetTargetObjectPos()
    local x,y,z = 0,0,0
    local ox = self.actionParam.offsetX or 0
    local oy = self.actionParam.offsetY or 0
    local oz = self.actionParam.offsetZ or 0
    if self.actionParam.x or self.actionParam.y or self.actionParam.z then
        x = self.actionParam.x or 0
        y = self.actionParam.y or 0
        z = self.actionParam.z or 0
    else
        local obj = self.timeline.targetArgs.targetObj
        if obj then
            x = obj.transform.position.x + ox
            y = obj.transform.position.y + oy
            z = obj.transform.position.z + oz
        end
    end
    x = x / FPFloat.PrecisionFactor
    y = y / FPFloat.PrecisionFactor
    z = z / FPFloat.PrecisionFactor
    return x,y,z
end

function BaseGuideNode:GetRealTargetPos(targetPos)
    targetPos = targetPos or {}
    local x = (targetPos.x or 0) + (self.actionParam.offsetX or 0)
    local y = (targetPos.y or 0) + (self.actionParam.offsetY or 0)
    local z = targetPos.z or 0
    return {x=x,y=y,z=z}
end

-- 虚函数
function BaseGuideNode:OnInit()
end
function BaseGuideNode:OnStart()
end
function BaseGuideNode:OnUpdate()
end
function BaseGuideNode:OnDestroy()
end

function BaseGuideNode:TryAutoRun()
    if PlayerGuideDefine.AutoExecMode and self.OnAutoRun then
        local id = self.timeline.guideAction.guideId
        self.autoRunTimer = TimerManager.Instance:AddTimer(1, 0.5, self:ToFunc("OnAutoRun"))
        LogGuide("尝试自动执行引导",id,"行为:",self.actionParam,"定时器",self.autoRunTimer.id)
    end
end

function BaseGuideNode:OnAutoRunFailed(...)
    local id = self.timeline.guideAction.guideId
    LogGuide("自动执行引导",id,"失败,行为:",self.actionParam,"原因:",...)
end

function BaseGuideNode:OnAutoRunSuccess(forceFinish)
    local id = self.timeline.guideAction.guideId
    LogGuide("自动执行引导",id,"成功,行为:",self.actionParam)
    if forceFinish then
        self.timeline:SetForceFinish(true)
    end
end