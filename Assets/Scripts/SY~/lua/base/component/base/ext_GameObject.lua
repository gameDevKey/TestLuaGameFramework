local base = xlua.getmetatable(GameObject)
local __baseindex = base.__index
local __extends = {}

--扩展

-- function __extends.AddComponent(self,component)
-- 	return CustomUnityUtils.AddComponent(self,component)
-- end

-- function __extends.SetActive(self,active)
-- 	UnityUtils.SetActive(gameObject,active)
-- end

--
base.__index = function(t,k)
	if __extends[k] then
		return __extends[k]
	else
		return __baseindex(t,k)
	end
end
xlua.setmetatable(GameObject, base)