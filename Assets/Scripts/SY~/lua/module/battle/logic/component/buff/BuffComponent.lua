BuffComponent = BaseClass("BuffComponent",SECBComponent)

function BuffComponent:__Init()
    self.buffs = {}
	self.buffList = SECBList.New()

	
	self.buffByGroup = {}
	self.buffByKind = {}
	self.buffStates = {}
end

function BuffComponent:__Delete()
	for iter in self.buffList:Items() do
        local buff = self.buffs[iter.value]
        buff:Delete()
    end
	self.buffList:Delete()

	for k,v in pairs(self.buffByGroup) do
		v:Delete()
	end

	for k,v in pairs(self.buffByKind) do
		v:Delete()
	end
end

function BuffComponent:OnInit()
	
end

function BuffComponent:OnUpdate()
    for iter in self.buffList:Items() do
        local buff = self.buffs[iter.value]
        buff:Update()
    end
end

function BuffComponent:OnDestroy()
	for iter in self.buffList:Items() do
        local buff = self.buffs[iter.value]
        self:DoRemoveBuff(buff)
    end
	self.buffList:Clear()

end

function BuffComponent:AddBuff(fromEntityUid,buffId,args)
	local conf = self.world.BattleConfSystem:BuffData_data_buff_info(buffId)
	if not conf then
		assert(false,string.format("不存在Buff配置[BuffId:%s]",tostring(buffId)))
	end
	
	if conf.result_type == BuffDefine.ResultType.deBuffer and self:HasBuffState(BattleDefine.BuffState.exempt_debuff) then
		return
	end

	local buff = self:GetBuffById(buffId)
	if buff then
		self:OverlayBuff(buff)
		return buff
	end

	if self:IsBeMutex(conf) or self:IsBeDispel(conf) then
		return
	end

	self:MutexBuff(conf)
	self:DispelBuff(conf)

	local uid = self.world:GetUid(BattleDefine.UidType.buff)
	local buff = Buff.New()
	buff:SetWorld(self.world)
	buff:Init(buffId,uid,self.entity,fromEntityUid,args)
	self:DoAddBuff(buff)

	buff:CheckExecute(0)

	if buff:CheckRemove() then
        self:RemoveBuffByUid(buff.uid)
		return nil
	else
		return buff
    end
end

function BuffComponent:OverlayBuff(buff)
	if buff.conf.overlay_action == BuffDefine.OverlayAction.reset_time then
		buff:ResetTime()
	end

	if buff.overlay < buff.conf.max_overlay then
		buff:AddOverlay(1)
		--TODO:发送buff层数发生变化的战斗事件

		if buff.conf.result_type == BuffDefine.ResultType.deBuffer then
			local args = {}
			args.camp = self.entity.CampComponent:GetCamp()
			args.groupKey = self.entity.uid.."_"..buff.conf.group[1]
			args.buffKey = buff.conf.id.."_"..buff.uid
			args.overlay = buff.overlay
			self.world.PluginSystem.KeyDataCount:AddCount(BattleDefine.CountKey.debuff_all_entity,args)
		end
	end
end

--是否被排斥
function BuffComponent:IsBeMutex(conf)
	for i,buffId in ipairs(conf.mutex_list) do
		local buff = self:GetBuffById(buffId)
		if buff and buff.conf.mutex_lev > conf.mutex_lev then
			return true
		end
	end
	return false
end

--排斥已有Buff
function BuffComponent:MutexBuff(conf)
	for i,buffId in ipairs(conf.mutex_list) do
		local buff = self:GetBuffById(buffId)
		if buff and buff.conf.mutex_lev < conf.mutex_lev then
			self:DoRemoveBuff(buff)
		end
	end
end

--是否被驱散
function BuffComponent:IsBeDispel(conf)
	if conf.dispel_type == BuffDefine.DispelType.doDispel_notBeDispel 
		or conf.dispel_type == BuffDefine.DispelType.notDoDispel_notBeDispel
		or not self.buffByKind[conf.kind] then
		return false
	end

	for iter in self.buffByKind[conf.kind]:Items() do
		local buff = self.buffs[iter.value]
		if (buff.conf.dispel_type == BuffDefine.DispelType.doDispel_beDispel 
			or buff.conf.dispel_type == BuffDefine.DispelType.doDispel_notBeDispel) 
			and buff.conf.dispel_lev > conf.dispel_lev then
			return true
		end
	end
	return false
end

--驱散已有Buff
function BuffComponent:DispelBuff(conf)
	if conf.dispel_type == BuffDefine.DispelType.notDoDispel_beDispel 
		or conf.dispel_type == BuffDefine.DispelType.notDoDispel_notBeDispel
		or not self.buffByKind[conf.kind] then
		return
	end

	for iter in self.buffByKind[conf.kind]:Items() do
		local buff = self.buffs[iter.value]
		if (buff.conf.dispel_type == BuffDefine.DispelType.doDispel_beDispel 
			or buff.conf.dispel_type == BuffDefine.DispelType.notDoDispel_beDispel) 
			and buff.conf.dispel_lev < conf.dispel_lev then
			self:DoRemoveBuff(buff)
		end
	end
end

function BuffComponent:GetBuffByUid(uid)
	return self.buffs[uid]
end

function BuffComponent:GetBuffById(buffId)
	local iter = self.buffList:GetIterByIndex(buffId)
	if iter then
		return self:GetBuffByUid(iter.value)
	end
end

function BuffComponent:HasBuffId(buffId)
	return self.buffList:ExistIndex(buffId)
end

function BuffComponent:HasBuffKind(kind)
	if not self.buffByKind[kind] then
		return false,0
	else
		return self.buffByKind[kind].length > 0,self.buffByKind[kind].length
	end
end

function BuffComponent:RemoveBuffByUid(uid)
	local buff = self.buffs[uid]
	if buff then
		self:DoRemoveBuff(buff)
	end
end

function BuffComponent:RemoveBuffById(buffId)
	local buff = self:GetBuffById(buffId)
	if buff then
		self:DoRemoveBuff(buff)
	end
end

function BuffComponent:RemoveBuffByGroup(group)
	if not self.buffByGroup[group] then
		return
	end

	for iter in self.buffByGroup[group]:Items() do
		local buff = self.buffs[iter.value]
		self:DoRemoveBuff(buff)
	end
end

function BuffComponent:DoAddBuff(buff)
	local buffId = buff.conf.id
	local buffUid = buff.uid

	self.buffs[buffUid] = buff

	self.buffList:Push(buff.uid,buffId)

	--组
	for i,group in ipairs(buff.conf.group) do
		if not self.buffByGroup[group] then
			self.buffByGroup[group] = SECBList.New()
		end
		self.buffByGroup[group]:Push(buff.uid,buffId)
	end

	--类别
	local kind = buff.conf.kind
	if not self.buffByKind[kind] then
		self.buffByKind[kind] = SECBList.New()
	end
	self.buffByKind[kind]:Push(buff.uid,buffId)

	if buff.conf.result_type == BuffDefine.ResultType.deBuffer then
		local args = {}
		args.camp = self.entity.CampComponent:GetCamp()
		args.groupKey = self.entity.uid.."_"..buff.conf.group[1]
		args.buffKey = buffId.."_"..buffUid
		args.overlay = buff.overlay
		self.world.PluginSystem.KeyDataCount:AddCount(BattleDefine.CountKey.debuff_all_entity,args)
	end
end


function BuffComponent:DoRemoveBuff(buff)
	local buffId = buff.conf.id
	local buffUid = buff.uid

	self.buffs[buffUid] = nil

	self.buffList:RemoveByIndex(buffId)

	--组
	for i,group in ipairs(buff.conf.group) do
		self.buffByGroup[group]:RemoveByIndex(buffId)
	end

	--类别
	local kind = buff.conf.kind
	self.buffByKind[kind]:RemoveByIndex(buffId)
	
	if buff.conf.result_type == BuffDefine.ResultType.deBuffer then
		local args = {}
		args.camp = self.entity.CampComponent:GetCamp()
		args.groupKey = self.entity.uid.."_"..buff.conf.group[1]
		args.buffKey = buffId.."_"..buffUid

		self.world.PluginSystem.KeyDataCount:ReduceCount(BattleDefine.CountKey.debuff_all_entity,args)
	end

	buff:DoRemove()
	buff:Delete()
end

function BuffComponent:AddState(state)
	if not self.buffStates[state] then self.buffStates[state] = 0 end
	self.buffStates[state] = self.buffStates[state] + 1

	if self.buffStates[state] == 1 then
		self:ActiveBuffState(state,true)
		self:ActiveClientBuffState(state,true)
	end

	local stateInfo = BattleDefine.BuffStateInfo[state]
	if stateInfo and stateInfo.isControl then
		self.entity.StateComponent:AddMarkState(BattleDefine.MarkState.control)
	end
end

function BuffComponent:RemoveState(state)
	self.buffStates[state] = self.buffStates[state] - 1

	if self.buffStates[state] == 0 then
		self:ActiveBuffState(state,false)
		self:ActiveClientBuffState(state,false)
	end

	local stateInfo = BattleDefine.BuffStateInfo[state]
	if stateInfo and stateInfo.isControl then
		self.entity.StateComponent:RemoveMarkState(BattleDefine.MarkState.control)
	end
end

function BuffComponent:HasBuffState(state)
	return self.buffStates[state] and self.buffStates[state] > 0
end

function BuffComponent:ActiveClientBuffState(state,flag)
	if self.entity.clientEntity and self.entity.clientEntity.ClientBuffComponent then
		self.entity.clientEntity.ClientBuffComponent:ActiveBuffState(state,flag)
	end
end

function BuffComponent:ActiveBuffState(state,flag)
	self.world.PluginSystem.BuffComp:ActiveBuffState(self.entity,state,flag)
end

function BuffComponent:RefreshBuffEffect()
	for iter in self.buffList:Items() do
        local buff = self.buffs[iter.value]
		buff:RemoveEffect()
		buff:LoadEffect()
    end
end