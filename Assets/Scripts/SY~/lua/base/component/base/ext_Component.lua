local base = getmetatable(Component)
local baseMetatable = getmetatable(base)
setmetatable(base, nil)

--if ctx.Editor then
--	function base.SetActive(self,value)
--		local gameObject = self.gameObject
--		if gameObject then UnityUtils.SetActive(gameObject,value) end
--		LogError("禁止直接调用SetActive")
--	end
--end

function base.addComponent(self,component)
	return self.gameObject:AddComponent(component)
end

function base.getComponent(self, component)
	return self.gameObject:GetComponent(component)
end

function base.getComponents(self, component)
	return self:GetComponents(component)
end

function base.getComponentInChildren(self, component,includeInactive)
	return self:GetComponentInChildren(component,includeInactive==true)
end

function base.getComponentsInChildren(self, component, includeInactive)
	return self:GetComponentsInChildren(component,includeInactive==true)
end

setmetatable(base, baseMetatable)
