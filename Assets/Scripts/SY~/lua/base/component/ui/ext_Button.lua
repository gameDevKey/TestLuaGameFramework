local base = xlua.getmetatable(Button)
local __baseindex = base.__index
local __extends = {}

--扩展
function __extends.SetClick(self,cb,arg1,arg2,arg3)
    self.onClick:RemoveAllListeners()
    self.onClick:AddListener(function() cb(arg1,arg2,arg3) end)
end

function __extends.AddClick(self,cb,arg1,arg2,arg3)
    local addCallback = function() cb(arg1,arg2,arg3) end
    self.onClick:AddListener(addCallback)
    return addCallback
end

function __extends.RemoveClick(self,cb)
    self.onClick:RemoveListener(cb)
end

function __extends.RemoveAllClick(self)
    self.onClick:RemoveAllListeners()
end

--
base.__index = function(t,k)
	if __extends[k] then
		return __extends[k]
	else
		return __baseindex(t,k)
	end
end
xlua.setmetatable(Button, base)