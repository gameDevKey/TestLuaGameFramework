SECBBehavior = BaseClass("SECBBehavior",SECBBase)

function SECBBehavior:__Init()
    self.uid = 0
    self.entity = nil
    self.behaviorPacks = {}
end

function SECBBehavior:__Delete()
    for i, v in ipairs(self.behaviorPacks) do
        local name = v.NAME or v.__className
        self[name]:Delete()
    end
end

function SECBBehavior:AddBehaviorPack(packType)
    local name = packType.NAME or packType.__className
    local behaviorPack = packType.New(self)
    behaviorPack:SetWorld(self.world)
    self[name] = behaviorPack
    table.insert(self.behaviorPacks,behaviorPack)
end

function SECBBehavior:SetEntity(entity)
    self.entity = entity
end

function SECBBehavior:SetUid(uid)
    self.uid = uid
end

function SECBBehavior:Init(...)
    self:OnInit(...)
    self:OnInitVariable()
    self:OnInitBehaviorPack()
end

function SECBBehavior:ExecuteFunc(funcType,...)
    return self.world.BattleFuncTriggerSystem:Trigger(funcType,...)
end


function SECBBehavior:PreUpdate()
    self:OnPreUpdate()
end

function SECBBehavior:Update()
    self:OnUpdate()
end

function SECBBehavior:LateUpdate()
    self:OnLateUpdate()
end


--初始化
function SECBBehavior:OnInit()
end

--更新回调
function SECBBehavior:OnPreUpdate()
end

--更新回调
function SECBBehavior:OnUpdate()
end

--更新回调
function SECBBehavior:OnLateUpdate()
end

--初始化行为所需变量
function SECBBehavior:OnInitVariable()
end

--扩展行为
function SECBBehavior:OnInitBehaviorPack()
end