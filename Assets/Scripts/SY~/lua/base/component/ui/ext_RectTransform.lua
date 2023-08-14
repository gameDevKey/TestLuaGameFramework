local base = xlua.getmetatable(RectTransform)
local __baseindex = base.__index
local __extends = {}

--扩展
function __extends.Reset(self)
	UnityUtils.SetAnchoredPosition(self,0,0)
	UnityUtils.SetLocalEulerAngles(self,0,0,0)
	UnityUtils.SetLocalScale(self,1,1,1)
end


function __extends.SetAnchoredPosition(self,x,y)
	UnityUtils.SetAnchoredPosition(self,x,y)
end


function __extends.SetAnchoredPosition3D(self,x,y)
	UnityUtils.SetAnchoredPosition(self,x,y)
end

function __extends.SetLocalScale(self,x,y,z)
	UnityUtils.SetLocalScale(self,x,y,z)
end

function __extends.SetLocalEulerAngles(self,x,y,z)
	UnityUtils.SetLocalEulerAngles(self,x,y,z)
end

function __extends.SetSizeDelata(self,width,height)
	UnityUtils.SetSizeDelata(self,width,height)
end


--
base.__index = function(t,k)
	if __extends[k] then
		return __extends[k]
	else
		return __baseindex(t,k)
	end
end
xlua.setmetatable(RectTransform, base)