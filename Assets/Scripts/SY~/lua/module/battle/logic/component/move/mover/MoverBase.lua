MoverBase = BaseClass("MoverBase",SECBBase)

function MoverBase:__Init()
    self.entity = nil
    self.targetPos = FPVector3(0,0,0)
    self.onComplete = nil
    self.params = nil
    self.onUpdate = nil
    self.updateArgs = nil
    self.onAbort = nil
    self.abortArgs = nil
end

function MoverBase:__Delete()
    
end

function MoverBase:SetEntity(entity)
    self.entity = entity
end

function MoverBase:Init()
    self:OnInit()
end

function MoverBase:SetParams(params)
    self.params = params
end

function MoverBase:MoveToPos(x,y,z,onComplete)
    self.targetPos:Set(x,y,z)
    self.onComplete = onComplete
    self:OnMove()
end

function MoverBase:SetTargetPos(x,y,z)
    self.targetPos:Set(x,y,z)
end

function MoverBase:CallComplete()
    if self.onComplete then
        local completeFunc = self.onComplete
        self.onComplete = nil
        completeFunc()
    end
end

function MoverBase:SetUpdateCallback(func,args)
    self.onUpdate = func
    self.updateArgs = args
end

function MoverBase:CallUpdate(lerp)
    if self.onUpdate then
        self.onUpdate(lerp,self.updateArgs)
    end
end

function MoverBase:Update()
    self:OnUpdate()
end

---

function MoverBase:OnMove()

end

function MoverBase:OnInit()
end

function MoverBase:OnUpdate()
end