BattleRandomSystem = BaseClass("BattleRandomSystem",SECBOperationSystem)

function BattleRandomSystem:__Init()
    self.isRenderRandom = false
    self.isLogicRandom = false
    self.logicRandomNum = 0
    self.random = nil
end

function BattleRandomSystem:__Delete()
end

function BattleRandomSystem:OnInitSystem()
end

function BattleRandomSystem:InitRandom(randSeed)
    self.random = FPRandom(randSeed)
end

function BattleRandomSystem:Random(min,max)
    if self.isRenderRandom and self.isLogicRandom then
        assert(false,"随机异常,同时处在渲染和逻辑状态")
    end

    if min >= max then
		return min
	elseif self.isRenderRandom or not self.random then
        return math.random(min,max)
    elseif self.isLogicRandom then
        self.logicRandomNum = self.logicRandomNum + 1
        return self.random:Range(min,max)
    else
        assert(false,"随机异常,非法的随机调用")
	end
end

function BattleRandomSystem:SetRenderRandom(flag)
    self.isRenderRandom = flag
end

function BattleRandomSystem:SetLogicRandom(flag)
    self.isLogicRandom = flag
end