EffectManager = BaseClass("EffectManager")

function EffectManager:__Init()
    self.world = nil
    self.waitCreates = SECBList.New()
    self.maxCreateNum = 1
    self.uid = 0

    self.effects = {}
end

function EffectManager:__Delete()
    self.waitCreates:Delete()
end

function EffectManager:GetUid()
    self.uid = self.uid + 1
    return self.uid
end

function EffectManager:Init(world)
    self.world = world
end

function EffectManager:AddCreateByLoader(loader,path,parent,onComplete,stopwatch)
    local uid = self:GetUid()
    local data = {}
    data.loader = loader
    data.path = path
    data.parent = parent
    data.onComplete = onComplete
    data.stopwatch = stopwatch
    data.createType = EffectDefine.CreateType.loader
    local iter = self.waitCreates:Push(data)
    self.waitCreates:SetIndex(uid,iter)
    return uid
end

function EffectManager:Remove(id)
    local iter = self.waitCreates:GetIterByIndex(id)
	if iter then
        self.waitCreates:Remove(iter)
        self.waitCreates:SetIndex(id,nil)
    end
end

function EffectManager:Update()
    for _,effect in pairs(self.effects) do
        effect:Update()
    end

    if self.waitCreates.length <= 0 then 
        return 
    end

    local createNum = 0
    for iter in self.waitCreates:Items() do
        createNum = createNum + 1
        local data = iter.value
        self.waitCreates:Remove(iter)

        local effect = nil
        if data.createType == EffectDefine.CreateType.loader then
            effect = data.loader:GetAsset(data.path,data.parent,false)
        end

        data.onComplete(effect,data.createType)

        if self.maxCreateNum > 0 and createNum >= self.maxCreateNum then
            break
        end
    end
end

function EffectManager:Clean()
    self.cacheObjects = {}
    self.waitCreates:Clear()

    for _,effect in pairs(self.effects) do
        effect:Delete()
    end
    self.effects = {}

    self.maxCreateNum = 1
    self.uid = 0

    EffectDefine.ClearEffectNumInfo()
end

function EffectManager:SetMaxCreateNum(num)
    self.maxCreateNum = num
end

function EffectManager:AddEffect(effect)
    if effect and not self.effects[effect.uid] then
        self.effects[effect.uid] = effect
    end
end

function EffectManager:RemoveEffect(uid)
    local effect = self.effects[uid]
    if effect then
        effect:Delete()
        self.effects[uid] = nil
    end
end

function EffectManager:ClearEffects(passTypes)
    for _,v in pairs(self.effects) do
        if not v.effectType or not passTypes or not passTypes[v.effectType] then
            v:Delete()
        end
    end
    self.effects = {}
end

function EffectManager:AddHosting(effect)
    if effect and not self.effects[effect.uid] then
        self.effects[effect.uid] = effect
        effect:SetComplete(self:ToFunc("HostingComplete"))
    end
end

function EffectManager:HostingComplete(uid)
    self:RemoveEffect(uid)
end