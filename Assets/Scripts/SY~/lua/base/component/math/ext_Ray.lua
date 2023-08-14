local get = xlua.getmetatable(CS.UnityEngine.Ray)
local __baseindex = get.__index
local __extends = {}
---------------------------------------------

local rawget = rawget
local setmetatable = setmetatable
local Vector3 = Vector3

local Ray = 
{
	direction = Vector3.zero,
	origin = Vector3.zero,
}

Ray.__index = function(t,k)
	local var = rawget(Ray, k)
	
	if var == nil then
		if __extends[k] then
            return __extends[k](t)
        else
            return __baseindex(t,k)
        end
	end
	
	return var
end

Ray.__call = function(t, direction, origin)
	return Ray.New(direction, origin)
end

function Ray.New(direction, origin)
	local ray = {}	
	ray.direction 	= direction:Normalize()
	ray.origin 		= origin
	setmetatable(ray, Ray)	
	return ray
end

function Ray:GetPoint(distance)
	local dir = self.direction * distance
	dir:Add(self.origin)
	return dir
end

function Ray:Get()		
	local o = self.origin
	local d = self.direction
	return o.x, o.y, o.z, d.x, d.y, d.z
end

Ray.__tostring = function(self)
	return string.format("Origin:(%f,%f,%f),Dir:(%f,%f, %f)", self.origin.x, self.origin.y, self.origin.z, self.direction.x, self.direction.y, self.direction.z)
end

setmetatable(Ray, Ray)

---------------------------------------------------------
xlua.setmetatable(CS.UnityEngine.Ray, Ray)
xlua.setclass(CS.UnityEngine, 'Ray', Ray)