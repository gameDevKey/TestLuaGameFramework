--- 实体系统负责更新实体, 全部实体InitComplete之后再AfterInit
EntitySystem = Class("EntitySystem",ECSLSystem)

function EntitySystem:OnInit()
    self.initFinish = false
    self.entitys = ListMap.New()
end

function EntitySystem:OnDelete()
    if self.entitys then
        self.entitys:Delete()
        self.entitys = nil
    end
end

function EntitySystem:GetEntitys()
    return self.entitys
end

function EntitySystem:GetEntity(uid)
    local iter = self.entitys:Get(uid)
    return iter and iter.value
end

function EntitySystem:AddEntity(entity)
    entity:SetWorld(self.world)
    self.entitys:Add(entity:GetUid(),entity)
    --某些实体会在系统初始化结束后动态新增，这里补充触发
    if self.initFinish then
        entity:InitComplete()
        entity:AfterInit()
    end
end

function EntitySystem:RemoveEntity(entity)
    self.entitys:Remove(entity:GetUid())
end

function EntitySystem:OnUpdate(deltaTime)
    self.deltaTime = deltaTime
    self.entitys:Range(self.UpdateEntity,self)
end

function EntitySystem:UpdateEntity(entityIter)
    entityIter.value:Update(self.deltaTime)
end

function EntitySystem:OnAfterInit()
    self.entitys:Range(self.InitEntity,self)
    self.entitys:Range(self.AfterInitEntity,self)
    self.initFinish = true
end

function EntitySystem:InitEntity(entityIter)
    entityIter.value:InitComplete()
end

function EntitySystem:AfterInitEntity(entityIter)
    entityIter.value:AfterInit()
end

return EntitySystem