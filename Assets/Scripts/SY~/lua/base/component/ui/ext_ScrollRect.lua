-- 扩展Unity ScrollRect class 方法
local base = xlua.getmetatable(ScrollRect)
local __baseindex = base.__index
local __extends = {}

function __extends.SetValueChanged(self, onValueChanged)
	self.onValueChanged:RemoveAllListeners()
    self.onValueChanged:AddListener(onValueChanged)
end

base.__index = function(t,k)
	if __extends[k] then
		return __extends[k]
	else
		return __baseindex(t,k)
	end
end
xlua.setmetatable(ScrollRect, base)
