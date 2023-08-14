local base = xlua.getmetatable(Image)
local __baseindex = base.__index
local __extends = {}

--
base.__index = function(t,k)
	if __extends[k] then
		return __extends[k]
	else
		return __baseindex(t,k)
	end
end
xlua.setmetatable(Image, base)