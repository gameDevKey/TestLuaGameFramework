MagicEvent = BaseClass("MagicEvent",SECBBase)

function MagicEvent:__Init()
    self.uid = 0
    self.eventId = 0
    self.from = nil

    self.conf = nil

    self.duration = 0

    --效果行为
    self.behavior = nil

    self.execNum = 0

    --
    self.intervalNum = 0
    self.intervalIndex = 0
    self.intervalTime = 0
    self.nextIntervalTime = 0

    -- self.isValid = false
end

function MagicEvent:__Delete()
    if self.behavior then
        self.behavior:Delete()
    end
end

function MagicEvent:Init(eventId,uid,from)
    self.eventId = eventId
    self.uid = uid
    self.from = from

    self.conf = self.world.BattleConfSystem:EventData_data_event_info(eventId)
    if not self.conf then
        assert(false,string.format("事件Id未配置[eventId:%s]",tostring(eventId)))
    end

    --
    self.intervalNum = #self.conf.interval_time
    self:SetInterval()

    --
    self:InitBehavior()
end

function MagicEvent:SetFrom(from)
    self.from = from
end

function MagicEvent:Update()
    self.duration = self.duration + self.world.opts.frameDeltaTime

    self:CheckExecute(self.world.opts.frameDeltaTime)
    
    if self.behavior then
        self.behavior:Update()
    end

    if self:CheckRemove() then
        RunWorld.BattleMagicEventSystem:RemoveEventByUid(self.uid)
    end
end

function MagicEvent:DoRemove()
    if self.behavior then
        self.behavior:Destroy()
    end
end

function MagicEvent:CheckRemove()
	local isTimeout = self:IsTimeout()
	local isMaxNum = self.conf.duration == -1 and self:IsMaxExecNum() or false
	--local isCondRemove = MagicEventRemove.Instance:IsRemove(self,self.config.remove_cond)
	local flag = isTimeout or isMaxNum

    if not flag and self.behavior then
        flag = self.behavior:OnCheckRemove()
    end

	return flag
end

function MagicEvent:InitBehavior()
    if self.conf.action_type == "" then
        return
    end

    local class  = nil
    if MagicEventDefine.BehaviorIndex[self.conf.action_type] then
        class = _G[MagicEventDefine.BehaviorIndex[self.conf.action_type]]
    end
    if not class then
        assert(false,string.format("未实现的MagicEvent效果[eventId:%s][Event效果:%s]",self.eventId,tostring(self.conf.action_type)))
    end


    local uid = self.world:GetUid(SECBBehaviorComponent)
    self.behavior = class.New()
	self.behavior:SetWorld(self.world)
	self.behavior:SetUid(uid)
    self.behavior:SetEvent(self)
    self.behavior:Init()
end

function MagicEvent:CheckExecute(deltaTime)
	if self:IsMaxExecNum() then
        return
    end
	
	self.intervalTime = self.intervalTime + deltaTime

    ---
	if self.intervalTime < self.nextIntervalTime then 
        return
    else
        self.intervalTime = self.intervalTime - self.nextIntervalTime
    end
	self:SetInterval()

    ---
	local flag = false
    if self.behavior then
        flag = self.behavior:OnExecute()
    end

    --
	if flag then
        self:AddExecNum()
	elseif flag == nil then
		assert(false,string.format("MagicEvent行为执行返回了nil值[id:%s][类型:%s]",self.conf.id,self.conf.action_type))
    end
end

function MagicEvent:SetInterval()
	if self.intervalNum > 0 and self.intervalIndex < self.intervalNum then 
        self.intervalIndex = self.intervalIndex + 1
	    self.nextIntervalTime = self.conf.interval_time[self.intervalIndex]
    end
end

function MagicEvent:IsTimeout()
	if self.conf.duration <= 0 then 
        return false
    else
        return self.duration >= self.conf.duration
    end
end

function MagicEvent:IsMaxExecNum()
	if self.conf.max_num <= 0 then 
        return false
    else
        return self.execNum >= self.conf.max_num
    end
end

function MagicEvent:AddExecNum()
	self.execNum = self.execNum + 1
end

-- function MagicEvent:SetIsValid(flag)
--     self.isValid = flag
-- end

-- function MagicEvent:GetIsValid()
--     return self.isValid
--     -- if self.from.skill and not self.from.skill:IsEnable() then
--     --     return false
--     -- else
--     --     return self.isValid
--     -- end
-- end