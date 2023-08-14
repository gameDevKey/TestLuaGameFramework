-- 扩展Unity InputField 方法
local base = xlua.getmetatable(InputField)
local __baseindex = base.__index
local __extends = {}

function __extends.SetEndEdit(self,cb,arg1,arg2,arg3)
	self.onEndEdit:RemoveAllListeners()
    self.onEndEdit:AddListener(function(flag) cb(flag,arg1,arg2,arg3) end)
end

function __extends.SetValueChanged(self, cb, args1,args2,args3)
	self.onValueChanged:RemoveAllListeners()
    self.onValueChanged:AddListener(function(flag) cb(flag,args1,args2,args3) end)
end

base.__index = function(t,k)
	if __extends[k] then
		return __extends[k]
	else
		return __baseindex(t,k)
	end
end
xlua.setmetatable(InputField, base)