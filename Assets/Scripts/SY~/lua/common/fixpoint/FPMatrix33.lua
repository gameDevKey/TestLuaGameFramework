local fixpoint = require("fixpoint")

FPMatrix33 = {}
FPMatrix33.key = "FPMatrix33"

local gsIndex = {"m00","m10","m20","m01","m11","m21","m02","m12","m22"}

FPMatrix33.__index = function(t, k)
	return rawget(FPMatrix33, k)
end

FPMatrix33.__call = function(t,column0,column1,column2)
	local t = {m00 = column0.x,m10 = column0.y,m20 = column0.z,m01 = column1.x,m11 = column1.y,m21 = column1.z,m02 = column2.x,m12 = column2.y,m22 = column2.z}
	setmetatable(t, FPMatrix33)
	return t
end

function FPMatrix33.New(column0,column1,column2)
    local t = {m00 = column0.x,m10 = column0.y,m20 = column0.z,m01 = column1.x,m11 = column1.y,m21 = column1.z,m02 = column2.x,m12 = column2.y,m22 = column2.z}
    setmetatable(t, FPMatrix33)
    return t
end

function FPMatrix33:GetColumn(index)
    if index == 0 then
        return FPVector3(self.m00, self.m10, self.m20)
    elseif index == 1 then
        return FPVector3(self.m01, self.m11, self.m21)
    elseif index == 2 then
        return FPVector3(self.m02, self.m12, self.m22)
    else
        assert(false,"Invalid column index!")
    end
end

function FPMatrix33:GetRow(index)
    if index == 0 then
        return FPVector3(self.m00, self.m01, self.m02)
    elseif index == 1 then
        return FPVector3(self.m10, self.m11, self.m12)
    elseif index == 2 then
        return FPVector3(self.m20, self.m21, self.m22)
    else
        assert(false,"Invalid column index!")
    end
end

function FPMatrix33:SetColumn(index,column)
    local i1 = self:GetIndex(0,index)
    self[gsIndex[i1]] = column.x

    local i2 = self:GetIndex(1,index)
    self[gsIndex[i2]] = column.y

    local i3 = self:GetIndex(2,index)
    self[gsIndex[i3]] = column.z
end

function FPMatrix33:SetRow(index,row)
    local i1 = self:GetIndex(index,0)
    self[gsIndex[i1]] = row.x

    local i2 = self:GetIndex(index,1)
    self[gsIndex[i2]] = row.y

    local i3 = self:GetIndex(index,2)
    self[gsIndex[i3]] = row.z
end

function FPMatrix33:GetIndex(row,column)
    return (row + column * 3) + 1
end

function FPMatrix33:GetByIndex(index)
    return self[gsIndex[index + 1]]
end

function FPMatrix33:SetByIndex(index,val)
    self[gsIndex[index + 1]] = val
end

function FPMatrix33:GetByRowColumn(row,column)
    local index = self:GetIndex(row,column)
    return self[gsIndex[index]]
end

function FPMatrix33:SetByRowColumn(row,column,val)
    local index = self:GetIndex(row,column)
    self[gsIndex[index]] = val
end

FPMatrix33.__eq = function(m1, m2)
    return m1.m00 == m2.m00 and m1.m10 == m2.m10 and m1.m20 == m2.m20 
        and m1.m01 == m2.m01 and m1.m11 == m2.m11 and m1.m21 == m2.m21 
        and m1.m02 == m2.m02 and m1.m12 == m2.m12 and m1.m22 == m2.m22 
end

function FPMatrix33:Equals(other)
    return self.m00 == other.m00 and self.m10 == other.m10 and self.m20 == other.m20 
        and self.m01 == other.m01 and self.m11 == other.m11 and self.m21 == other.m21 
        and self.m02 == other.m02 and self.m12 == other.m12 and self.m22 == other.m22 
end

FPMatrix33.__mul = function(a,b)
	if b.key == FPMatrix33.key then
		local m00,m10,m20,m01,m11,m21,m02,m12,m22 = fixpoint.FPMatrix33_Mul(a.m00,a.m10,a.m20,a.m01,a.m11,a.m21,a.m02,a.m12,a.m22
            ,b.m00,b.m10,b.m20,b.m01,b.m11,b.m21,b.m02,b.m12,b.m22)
        if DEBUG_FP then
            local debugMatrix33_1 = CS_FPMatrix33(CS_FPVector3(a.m00,a.m10,a.m20),CS_FPVector3(a.m01,a.m11,a.m21),CS_FPVector3(a.m02,a.m12,a.m22))
            local debugMatrix33_2 = CS_FPMatrix33(CS_FPVector3(b.m00,b.m10,b.m20),CS_FPVector3(b.m01,b.m11,b.m21),CS_FPVector3(b.m02,b.m12,b.m22))
            local debugMatrix33 = debugMatrix33_1 * debugMatrix33_2
            if m00 ~= debugMatrix33.m00 or m10 ~= debugMatrix33.m10 or m20 ~= debugMatrix33.m20 
                or m01 ~= debugMatrix33.m01 or m11 ~= debugMatrix33.m11 or m21 ~= debugMatrix33.m21 
                or m02 ~= debugMatrix33.m02 or m12 ~= debugMatrix33.m12 or m22 ~= debugMatrix33.m22 then
                assert(false,string.format("FPMatrix33.__mul,计算结果不一致[a_m00:%s][a_m10:%s][a_m20:%s][a_m01:%s][a_m11:%s][a_m21:%s][a_m02:%s][a_m12:%s][a_m22:%s][b_m00:%s][b_m10:%s][b_m20:%s][b_m01:%s][b_m11:%s][b_m21:%s][b_m02:%s][b_m12:%s][b_m22:%s]",
                    a.m00,a.m10,a.m20,a.m01,a.m11,a.m21,a.m02,a.m12,a.m22,b.m00,b.m10,b.m20,b.m01,b.m11,b.m21,b.m02,b.m12,b.m22))
            end
        end
        return FPMatrix33(FPVector3(m00,m10,m20),FPVector3(m01,m11,m21),FPVector3(m02,m12,m22))
	else
		local x,y,z = fixpoint.FPMatrix33_Mul_v(a.m00,a.m10,a.m20,a.m01,a.m11,a.m21,a.m02,a.m12,a.m22,b.x,b.y,b.z)
        if DEBUG_FP then
            local debugMatrix33_1 = CS_FPMatrix33(CS_FPVector3(a.m00,a.m10,a.m20),CS_FPVector3(a.m01,a.m11,a.m21),CS_FPVector3(a.m02,a.m12,a.m22))
            local debugFPVector3 = debugMatrix33_1 * CS_FPVector3(b.x,b.y,b.z)
            if debugFPVector3.x ~= x or debugFPVector3.y ~= y or debugFPVector3.z ~= z then
                assert(false,string.format("FPMatrix33.__mul,计算结果不一致[a_m00:%s][a_m10:%s][a_m20:%s][a_m01:%s][a_m11:%s][a_m21:%s][a_m02:%s][a_m12:%s][a_m22:%s][b_x:%s][b_y:%s][b_z:%s]",
                a.m00,a.m10,a.m20,a.m01,a.m11,a.m21,a.m02,a.m12,a.m22,b.x,b.y,b.z))
            end
        end
        return FPVector3(x,y,z)
	end
end


FPMatrix33.zero = FPMatrix33.New(FPVector3.zero,FPVector3.zero, FPVector3.zero);
FPMatrix33.identity = FPMatrix33.New(FPVector3(FPFloat.Precision,0,0),FPVector3(0,FPFloat.Precision,0),FPVector3(0,0,FPFloat.Precision));

setmetatable(FPMatrix33, FPMatrix33)