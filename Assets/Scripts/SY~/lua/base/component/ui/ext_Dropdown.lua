-- 扩展Unity Dropdown class 方法
local base = xlua.getmetatable(Dropdown)
local __baseindex = base.__index
local __extends = {}

function __extends.SetClick(self, cb, arg1,arg2,arg3)
	self.onValueChanged:RemoveAllListeners()
    self.onValueChanged:AddListener(function(flag) cb(flag,arg1,arg2,arg3) end)
end

base.__index = function(t,k)
	if __extends[k] then
		return __extends[k]
	else
		return __baseindex(t,k)
	end
end
xlua.setmetatable(Dropdown, base)