local base = xlua.getmetatable(Slider)
local __baseindex = base.__index
local __extends = {}

--扩展
function __extends.SetClick(self,cb,arg1,arg2,arg3)
    self.onValueChanged:RemoveAllListeners()
    self.onValueChanged:AddListener(function(value) cb(value,arg1,arg2,arg3) end)
end

function __extends.AddClick(self,cb,arg1,arg2,arg3)
    local addCallback = function(value) cb(value,arg1,arg2,arg3) end
    self.onValueChanged:AddListener(addCallback)
    return addCallback
end

function __extends.RemoveClick(self,cb)
    self.onValueChanged:RemoveListener(cb)
end

function __extends.RemoveAllClick(self)
    self.onValueChanged:RemoveAllListeners()
end

--
base.__index = function(t,k)
	if __extends[k] then
		return __extends[k]
	else
		return __baseindex(t,k)
	end
end
xlua.setmetatable(Slider, base)