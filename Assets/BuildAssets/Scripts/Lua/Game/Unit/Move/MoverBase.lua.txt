MoverBase = Class("MoverBase")

---@param type MoveConfig.Type
---@param args table { targetPos, callback, args }
function MoverBase:OnInit(type,args)
    self.isRunning = false
    self.isFinish = false
    self.type = type
    self.args = args
end

function MoverBase:OnDelete()
    self.isRunning = false
end

function MoverBase:SetEntity(entity)
    self.entity = entity
end

function MoverBase:Start()
    self.isRunning = true
    self:CallFuncDeeply("OnStart",true)
end

function MoverBase:Stop()
    self.isRunning = false
    self:CallFuncDeeply("OnStop",false)
end

function MoverBase:Update(deltaTime)
    if not self.isRunning or self.isFinish then
        return
    end
    self:CallFuncDeeply("OnUpdate",true,deltaTime)
end

function MoverBase:Finish()
    if self.isFinish then
        return
    end
    self.isFinish = true
    if self.args.callback then
        self.args.callback(self.args.args)
    end
end

function MoverBase:OnStart()end
function MoverBase:OnStop()end
function MoverBase:OnUpdate(deltaTime)end

return MoverBase