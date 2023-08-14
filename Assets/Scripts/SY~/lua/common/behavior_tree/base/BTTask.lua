BTTask = BaseClass("BTTask")

function BTTask:__Init()
    self.id = -1
    self.instant = true
    self.params = nil
    self.owner = nil --Behavior行为树
    self.friendlyName = ""
    self.referenceId = -1
    self.status = BTTaskStatus.Inactive
    self.realTime = 0
    self.parentNode = nil
    self.index = nil
    self.layer = 1
end

function BTTask:__Delete()
end

function BTTask:Start()
    self:OnStart()
end

function BTTask:Reset()
    self:OnReset()
end

function BTTask:Stop()
    self:OnStop()
end

function BTTask:Restart()
    self:OnRestart()
end

function BTTask:Create()
    self:OnCreate()
end

function BTTask:CanHasChild()
    return self:MaxChildren() > 0
end

function BTTask:MaxChildren()
    return 0
end

-- function BTTask:End()
-- end

function BTTask:Complete()
    self:OnComplete()
end

function BTTask:SetParams(params)
    self.params = params
end

function BTTask:GetPriority()
    return 0
end

function BTTask:Update(deltaTime)
    self.realTime = self.realTime + deltaTime

    if self.status == BTTaskStatus.Inactive then
        self.status = BTTaskStatus.Running
		self:Start()
	end

	local status = self:OnUpdate(deltaTime)
	if status ~= BTTaskStatus.Running then
        self.status = BTTaskStatus.Inactive
		self:OnEnd()
	end

    return status
end
--

--------------------------------------------------------
--构造节点时执行
function BTTask:OnAwake()
end
--节点开始执行时执行
function BTTask:OnStart()
end
--每帧执行
function BTTask:OnUpdate(deltaTime)
    return BTTaskStatus.Success
end
--行为树暂停、恢复时执行
function BTTask:OnPause(paused) 
end
--节点执行返回成功、失败时执行
function BTTask:OnEnd()
end
--当行为树完成执行时执行
function BTTask:OnComplete()
end
--行为树重启启动时执行
function BTTask:OnRestart()
end
--行为树被停止时执行
function BTTask:OnStop()
end

--行为树构造完成时调用
function BTTask:OnCreate()
end