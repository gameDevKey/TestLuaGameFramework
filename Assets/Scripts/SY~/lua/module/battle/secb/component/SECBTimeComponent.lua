SECBTimeComponent = BaseClass("SECBTimeComponent",SECBComponent)

function SECBTimeComponent:__Init()
	self.timeScale = 1000
    self.unParentScale = true
	self.time = 0
	self.frame = 0
end

function SECBTimeComponent:__Delete()
end

function SECBTimeComponent:SetUnParentScale(flag)
    self.unParentScale = flag
end

function SECBTimeComponent:SetTimeScale(timeScale)
	self.timeScale = timeScale
	self:UpdateTimeScale()

    for iter in self.entity.childEntitys:Items() do
        local entity = iter.value
        if entity.TimeComponent and not entity.TimeComponent.unParentScale then
            entity:UpdateTimeScale()
        end
    end
end

function SECBTimeComponent:OnUpdate()
    local timeScale = self:GetTimeScale()
    --TODO：除法用定点数进行优化
	self.time = self.time + (self.world.opts.deltaTime * timeScale / 1000)
	if self.time > (self.frame + 1) * self.world.opts.deltaTime then
		self.frame = self.frame + 1
		return true
	end
	return false
end

function SECBTimeComponent:GetTimeScale()
	if self.unParentScale and self.entity.parentEntity 
        and self.entity.parentEntity.TimeComponent then
        --TODO：除法用定点数进行优化
		return self.timeScale * self.entity.TimeComponent.timeScale / 1000
	else
		return self.timeScale
	end
end

function SECBTimeComponent:GetClientTimeScale()
    local timeScale = self:GetTimeScale()
    return timeScale * 0.001
end

function SECBTimeComponent:UpdateTimeScale()
    local timeScale = self:GetClientTimeScale()
    self:OnUpdateTimeScale(timeScale)
end

--实现具体表现缩放效果，比如设置动作变慢
function SECBTimeComponent:OnUpdateTimeScale(timeScale)
end