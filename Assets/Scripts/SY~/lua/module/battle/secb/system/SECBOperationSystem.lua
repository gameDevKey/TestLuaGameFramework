SECBOperationSystem = BaseClass("SECBOperationSystem",SECBSystem)
--玩家输入的操作系统

function SECBOperationSystem:__Init()
	self.handlers = {}

	self.isClientInput = true

	--当客户端某一帧有输入操作时,会将输入保存在此容器内,这个输入,可上传至服务器,用于回放或后台验证
	self.clientInputs = {}

	--服务器驱动帧、回放、后台验证时，没有客户端的输入，这个是服务器下发的某场战斗的输入信息
	self.remoteInputs = {}
end

function SECBOperationSystem:__Delete()
    
end

function SECBOperationSystem:SetClientInput(flag)
	self.isClientInput = flag
end

function SECBOperationSystem:ApplyOperation()
	self:OnPreApplyOperation()
	
	local inputs = nil
	
	if self.isClientInput then
		inputs = self.world.BattleInputSystem:GetInputs() or {}
		self.clientInputs[self.world.frame] = inputs
	else
		inputs = self.remoteInputs[self.world.frame] or {}
	end

	for _,v in ipairs(inputs) do
		assert(self.handlers[v.type],string.format("不存在帧操作类型的处理[%s]",tostring(v.type)))
		self.handlers[v.type](self.world.frame,v.data)
	end
end

function SECBOperationSystem:BindOperation(type,handler)
	self.handlers[type] = handler
end

function SECBOperationSystem:AddRemoteInput(frame,data)
	if not self.remoteInputs[frame] then
		self.remoteInputs[frame] = {}
	end
	table.insert(self.remoteInputs[frame],data)
end

function SECBOperationSystem:OnPreApplyOperation()
end