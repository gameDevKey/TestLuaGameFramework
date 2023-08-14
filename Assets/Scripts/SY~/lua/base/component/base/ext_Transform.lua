local base = xlua.getmetatable(Transform)
local __baseindex = base.__index
local __extends = {}

--扩展
function __extends.Reset(self)
	UnityUtils.SetLocalPosition(self,0,0,0)
	UnityUtils.SetLocalEulerAngles(self,0,0,0)
	UnityUtils.SetLocalScale(self,1,1,1)
end

function __extends.SetLocalPosition(self,x,y,z)
	UnityUtils.SetLocalPosition(self,x,y,z)
end

function __extends.SetPosition(self,x,y,z)
	UnityUtils.SetPosition(self,x,y,z)
end

function __extends.SetLocalScale(self,x,y,z)
	UnityUtils.SetLocalScale(self,x,y,z)
end

function __extends.SetLocalEulerAngles(self,x,y,z)
	UnityUtils.SetLocalEulerAngles(self,x,y,z)
end

function __extends.SetRotation(self,x,y,z,w)
	UnityUtils.SetRotation(self,x,y,z,w)
end

--
base.__index = function(t,k)
	if __extends[k] then
		return __extends[k]
	else
		return __baseindex(t,k)
	end
end
xlua.setmetatable(Transform, base)