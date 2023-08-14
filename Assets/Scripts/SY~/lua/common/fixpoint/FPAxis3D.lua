local fixpoint = require("fixpoint")

FPAxis3D = {}

FPAxis3D.__index = function(t, k)
	return rawget(FPAxis3D, k)
end

FPAxis3D.__call = function(t,right,up,forward)
	local t = {x = right or FPVector3(0,0,0), y = up or FPVector3(0,0,0),z = forward or FPVector3(0,0,0)}
	setmetatable(t, FPAxis3D)
	return t
end

function FPAxis3D.New(right,up,forward)
    local t = {x = right or FPVector3(0,0,0), y = up or FPVector3(0,0,0),z = forward or FPVector3(0,0,0)}
    setmetatable(t, FPAxis3D)
    return t
end

function FPAxis3D:WorldToLocal(v,toFPVector3)
    local x, y, z = fixpoint.FPAxis3D_WorldToLocal(self.x.x,self.x.y,self.x.z,self.y.x,self.y.y,self.y.z,self.z.x,self.z.y,self.z.z,v.x,v.y,v.z)

    if DEBUG_FP then
        local debugFPAxis3D = CS_FPAxis3D(CS_FPVector3(self.x.x,self.x.y,self.x.z),CS_FPVector3(self.y.x,self.y.y,self.y.z),CS_FPVector3(self.z.x,self.z.y,self.z.z))
        local debugFPVector3 = debugFPAxis3D:WorldToLocal(CS_FPVector3(v.x,v.y,v.z))
        if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
            assert(false,string.format("FPAxis3D.WorldToLocal,计算结果不一致[x_x:%s][x_y:%s][x_z:%s][y_x:%s][y_y:%s][y_z:%s][z_x:%s][z_y:%s][z_z:%s][v_x:%s][v_y:%s][v_z:%s]",
                tostring(self.x.x),tostring(self.x.y),tostring(self.x.z),
                tostring(self.y.x),tostring(self.y.y),tostring(self.y.z),
                tostring(self.z.x),tostring(self.z.y),tostring(self.z.z),
                tostring(v.x),tostring(v.y),tostring(v.z)))
        end
    end

    local fpVector3 = toFPVector3 or FPVector3.New(0,0,0)
    fpVector3:Set(x,y,z)
    return fpVector3
end

function FPAxis3D:LocalToWorld(v,toFPVector3)
    local x, y, z = fixpoint.FPAxis3D_LocalToWorld(self.x.x,self.x.y,self.x.z,self.y.x,self.y.y,self.y.z,self.z.x,self.z.y,self.z.z,v.x,v.y,v.z)

    if DEBUG_FP then
        local debugFPAxis3D = CS_FPAxis3D(CS_FPVector3(self.x.x,self.x.y,self.x.z),CS_FPVector3(self.y.x,self.y.y,self.y.z),CS_FPVector3(self.z.x,self.z.y,self.z.z))
        local debugFPVector3 = debugFPAxis3D:LocalToWorld(CS_FPVector3(v.x,v.y,v.z))
        if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
            assert(false,string.format("FPAxis3D.LocalToWorld,计算结果不一致[x_x:%s][x_y:%s][x_z:%s][y_x:%s][y_y:%s][y_z:%s][z_x:%s][z_y:%s][z_z:%s][v_x:%s][v_y:%s][v_z:%s]",
                tostring(self.x.x),tostring(self.x.y),tostring(self.x.z),
                tostring(self.y.x),tostring(self.y.y),tostring(self.y.z),
                tostring(self.z.x),tostring(self.z.y),tostring(self.z.z),
                tostring(v.x),tostring(v.y),tostring(v.z)))
        end
    end

    local fpVector3 = toFPVector3 or FPVector3.New(0,0,0)
    fpVector3:Set(x,y,z)
    return fpVector3
end


FPAxis3D.identity = FPAxis3D.New(FPVector3.right, FPVector3.up, FPVector3.forward)

setmetatable(FPAxis3D, FPAxis3D)