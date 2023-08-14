local fixpoint = require("fixpoint")

FPRandom = {}
FPRandom.__index = FPRandom

FPRandom.__call = function(t,seed)
	local t = {seed = tostring(seed) or "1"}
    setmetatable(t, FPRandom)
    return t
end

function FPRandom.New(seed)
    local t = {seed = tostring(seed) or "1"}
    setmetatable(t, FPRandom)
    return t
end

function FPRandom:Next(max)
	local ret = 0
	local ret_seed = 0
	if max then
		if max > 0 then
			ret, ret_seed = fixpoint.FPRandom_Next_l(self.seed, max)
		else
			ret, ret_seed = fixpoint.FPRandom_Next_i(self.seed, max)
		end
	else
		ret, ret_seed = fixpoint.FPRandom_Next(self.seed)
	end

	self.seed = ret_seed

	return ret
end

function FPRandom:Range(min,max)
    if min == max then
        return min
    end

	if min > max then
        assert(false,string.format("随机异常,最小值 > 最大值[最小值:%s][最大值:%s]",min,max))
    end
    
	local ret = 0
	local ret_seed = 0
	if min > 0 and max > 0 then
		ret, ret_seed = fixpoint.FPRandom_Range_ll(self.seed, min, max + 1)
	else
		ret, ret_seed = fixpoint.FPRandom_Range_ii(self.seed, min, max + 1)
	end

	self.seed = ret_seed

	return ret
end


setmetatable(FPRandom, FPRandom)