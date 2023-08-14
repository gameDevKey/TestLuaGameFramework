FPAxis2D = {}

FPAxis2D.__call = function(t,x,y)
	local t = {x = x or FPVector3(0,0,0), y = y or FPVector3(0,0,0)}
	setmetatable(t, FPAxis2D)
	return t
end

function FPAxis2D.New(x,y)
    local t = {x = x or FPVector3(0,0,0), y = y or FPVector3(0,0,0)}
    setmetatable(t, FPAxis2D)
    return t
end

FPAxis2D.identity = FPAxis2D.New(FPVector3.right, FPVector3.up)

setmetatable(FPAxis2D, FPAxis2D)