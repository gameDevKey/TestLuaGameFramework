Buff = BaseClass("Buff",SECBBase)

function Buff:__Init()
    self.uid = 0
    self.entity = nil
    self.fromEntityUid = nil
    self.conf = nil
    self.args = nil

    self.duration = 0

    --效果行为
    self.behavior = nil

    self.overlay = 1

    self.execNum = 0

    --
    self.intervalNum = 0
    self.intervalIndex = 0
    self.intervalTime = 0
    self.nextIntervalTime = 0

    self.effects = {}
end

function Buff:__Delete()
    if self.behavior then
        self.behavior:ClearEvent()
        self.behavior:Delete()
    end
    self:RemoveEffect()
end

function Buff:Init(buffId,uid,entity,fromEntityUid,args)
    self.uid = uid
    self.entity = entity
    self.fromEntityUid = fromEntityUid
    self.conf = self.world.BattleConfSystem:BuffData_data_buff_info(buffId)
    self.args = args

    --
    self.intervalNum = #self.conf.interval_time
    self:SetInterval()

    --
    self:InitBehaviors()
	self:LoadEffect()
end

function Buff:Update()
    self.duration = self.duration + self.world.opts.frameDeltaTime

    self:CheckExecute(self.world.opts.frameDeltaTime)
    
    if self.behavior then
        self.behavior:Update()
    end

    if self:CheckRemove() then
        self.entity.BuffComponent:RemoveBuffByUid(self.uid)
    end
end

function Buff:DoRemove()
    if self.behavior then
        self.behavior:Destroy()
    end
end

function Buff:AddOverlay(num)
    self.overlay = self.overlay + num
    if self.behavior then
        self.behavior:OnOverlay()
    end
end

function Buff:GetOverlay()
    return self.overlay
end

function Buff:ResetTime()
    self.duration = 0
end

function Buff:CheckRemove()
	local isTimeout = self:IsTimeout()
	local isMaxNum = self.conf.duration == -1 and self:IsMaxExecNum() or false
	--local isCondRemove = BuffRemove.Instance:IsRemove(self,self.config.remove_cond)
	local flag = isTimeout or isMaxNum

    if not flag and self.behavior then
        flag = self.behavior:OnCheckRemove()
    end

	return flag
end

function Buff:InitBehaviors()
    local actionType = self.conf.action_type
    if actionType == "" then
        return
    end

    local class  = nil
    if BuffDefine.ActionIndex[actionType] then
        class = _G[BuffDefine.ActionIndex[actionType]]
    end
    if not class then
        assert(false,string.format("未实现的Buff效果[BuffId:%s][Buff效果:%s]",self.conf.id,tostring(actionType)))
    end
    
    self.behavior = self.entity.BehaviorComponent:CreateBehavior(class)
    self.behavior:SetBuff(self)
    self.behavior:Init(self.conf.action_param)
end

function Buff:CheckExecute(deltaTime)
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

    ---
	if flag then
        self:AddExecNum()
	elseif flag == nil then
		assert(false,string.format("Buff行为执行返回了nil值[id:%s][类型:%s]",self.conf.id,self.conf.action_type))
	end
end

function Buff:SetInterval()
	if self.intervalNum > 0 and self.intervalIndex < self.intervalNum then 
        self.intervalIndex = self.intervalIndex + 1
	    self.nextIntervalTime = self.conf.interval_time[self.intervalIndex]
    end
end

function Buff:IsTimeout()
	if self.conf.duration <= 0 then 
        return false
    else
        return self.duration >= self.conf.duration
    end
end

function Buff:IsMaxExecNum()
	if self.conf.max_num <= 0 then 
        return false
    else
        return self.execNum >= self.conf.max_num
    end
end

function Buff:AddExecNum()
	self.execNum = self.execNum + 1
end

function Buff:LoadEffect()
    if not self.world.opts.isClient then
        return
    end
    for i,effectId in ipairs(self.conf.effect_list) do
        local effect = self.world.BattleAssetsSystem:PlayUnitEffect(self.entity.uid,effectId)
        if effect then
            table.insert(self.effects,effect.uid)
        end
    end
end

function Buff:RemoveEffect()
    for i,uid in ipairs(self.effects) do
        self.entity.clientEntity.EffectComponent:RemoveEffect(uid)
    end
    self.effects = {}
end