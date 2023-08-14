SECBBehaviorComponent = BaseClass("SECBBehaviorComponent",SECBComponent)

function SECBBehaviorComponent:__Init()
	self.behaviors = SECBList.New()
end

function SECBBehaviorComponent:__Delete()
	for iter in self.behaviors:Items() do
		iter.value:Delete()
    end
	self.behaviors:Delete()
end

function SECBBehaviorComponent:AddBehavior(behaviorType,...)
    local behavior = self:CreateBehavior(behaviorType,...)
	self.behaviors:Push(behavior,behavior.uid)
	return behavior
end

function SECBBehaviorComponent:CreateBehavior(behaviorType,...)
	local uid = self.world:GetUid(SECBBehaviorComponent)
    local behavior = behaviorType.New()
	behavior:SetWorld(self.world)
	behavior:SetEntity(self.entity)
	behavior:SetUid(uid)
	return behavior
end

function SECBBehaviorComponent:GetBehavior(uid)
	local iter = self.behaviors:GetIterByIndex(uid)
	if iter then
		return iter.value
	end
end

function SECBBehaviorComponent:PreUpdateBehavior()
	for iter in self.behaviors:Items() do
        iter.value:PreUpdate()
    end
end

function SECBBehaviorComponent:UpdateBehavior()
	for iter in self.behaviors:Items() do
        iter.value:Update()
    end
end

function SECBBehaviorComponent:LateUpdateBehavior()
	for iter in self.behaviors:Items() do
        iter.value:LateUpdate()
    end
end

function SECBBehaviorComponent:CallFunc(funName, ...)
	for iter in self.behaviors:Items() do
		local behavior = iter.value
		if behavior[funName] then
			behavior[funName](v,...)
		end
    end
end

function SECBBehaviorComponent:RemoveBehavior(uid)
	local iter = self.behaviors:GetIterByIndex(uid)
	iter.value:Delete()
	self.behaviors:RemoveByIndex(uid)
end