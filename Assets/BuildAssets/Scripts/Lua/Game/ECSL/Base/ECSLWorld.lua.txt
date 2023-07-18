--- 世界负责更新系统, 全部系统InitComplete之后再AfterInit
ECSLWorld = Class("ECSLWorld",ECSLBehaivor)
ECSLWorld.TYPE = ECSLConfig.Type.World

function ECSLWorld:OnInit()
    self.systems = ListMap.New()
end

function ECSLWorld:OnDelete()
    if self.systems then
        self.systems:Range(function (iter)
            iter.value:Delete()
        end)
        self.systems:Delete()
        self.systems = nil
    end
end

function ECSLWorld:AddSystem(system)
    system:SetWorld(self)
    self[system.NAME or system._className] = system
    self.systems:Add(system._className,system)
end

function ECSLWorld:OnUpdate(deltaTime)
    self.deltaTime = deltaTime
    self.systems:Range(self.UpdateSystem,self)
end

function ECSLWorld:UpdateSystem(iter)
    iter.value:Update(self.deltaTime)
end

function ECSLWorld:OnEnable()
end

--是否执行表现层逻辑
function ECSLWorld:SetRender(flag)
    self.isRender = flag
end

function ECSLWorld:IsRender()
    return self.isRender
end

function ECSLWorld:OnInitComplete()
    self.systems:Range(self.InitSystem,self)
    self.systems:Range(self.AfterInitSystem,self)
end

function ECSLWorld:InitSystem(iter)
    iter.value:InitComplete()
end

function ECSLWorld:AfterInitSystem(iter)
    iter.value:AfterInit()
end

return ECSLWorld