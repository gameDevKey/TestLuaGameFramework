LTimeline = BaseClass("LTimeline",SECBBase)

function LTimeline:__Init()
    self.actionFuncs = {}

    self.lockUid = 0
    self.lockNum = 0
    self.lockInfos = {}

    self.runTime = 0
    self.runIndex = 0
    self.isFinish = true
    self.forceFinish = false

    self.conf = nil
    self.length = 0

    self.onComplete = nil

    self.nodeIndexs = nil
end

function LTimeline:__Delete()
    self.nodeIndexs = nil
end

function LTimeline:SetNodeIndexs(nodeIndexs)
    self.nodeIndexs = nodeIndexs
end

function LTimeline:BindHandle(actionType,func)
    self.actionFuncs[actionType] = func
end

function LTimeline:Init(conf,...)
    self.conf = conf
    self.length = #conf.Event

    assert(conf.Duration,"LTimeline配置不存在持续时间")

    self:OnInit(...)
end

function LTimeline:IsFinish()
    return self.isFinish
end

function LTimeline:Start(...)
    self.runTime = 0    
    self.runIndex = 1
    self.isFinish = false

    self:OnStart(...)

    self:Update(0)
end

function LTimeline:Update(deltaTime)
    if self.isFinish then
        return
    end

    self.runTime = self.runTime + deltaTime

    while self.runIndex <= self.length do
        local info = self.conf.Event[self.runIndex]
        if self.runTime < info.time then
            break
        end

        self.runIndex = self.runIndex + 1
        self:DoActions(info.action)
    end

    self:CheckFinish()
    self:OnUpdate()
end

function LTimeline:DoActions(action)
    for _,v in ipairs(action) do
        local funcName = self.nodeIndexs[v.type]
        if not funcName then
            assert(false, string.format("未知的Timeline行为类型[%s]",tostring(v.type)))
        end

        local func = self[funcName]
        if not func then
            assert(false, string.format("未实现的Timeline行为类型[%s][%s]",tostring(v.type),tostring(funcName)))
        end

        func(self,v)
    end
end

function LTimeline:SetComplete(onComplete)
    self.onComplete = onComplete
end

function LTimeline:Lock()
    self.lockUid = self.lockUid + 1
    self.lockNum = self.lockNum + 1
    self.lockInfos[self.lockUid] = {}--可记录堆栈信息
    return self.lockUid
end

function LTimeline:Unlock(lockUid)
    if self.locks[lockUid] then
        self.lockNum = self.lockNum - 1
        self.lockInfos[lockUid] = nil
        self:CheckFinish()
    end
end

function LTimeline:SetForceFinish(flag)
    self.forceFinish = flag
    self:CheckFinish()
end

function LTimeline:CheckFinish()
    if self.isFinish then
        return
    end

    local flag = false
    if self.forceFinish then
        flag = true
    elseif (self.conf.Duration ~= 0 and self.runTime >= self.conf.Duration) and self.lockNum <= 0 then
        flag = true
    end

    if flag then
        self.isFinish = true
        if self.onComplete then
            self.onComplete()
        end
    end
end

function LTimeline:Destroy()
    self:OnDestroy()
end

--
function LTimeline:OnInit() end
function LTimeline:OnStart() end
function LTimeline:OnUpdate() end
function LTimeline:OnDestroy() end
function LTimeline:OnCheckFinish() return true end