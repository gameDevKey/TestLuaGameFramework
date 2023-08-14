FSM = BaseClass("FSM",SECBBase)

function FSM:__Init()
	self.entity = nil
	self.states = SECBList.New()
	self.curState = nil
	self.statesMachine = nil
end

function FSM:__Delete()
	for iter in self.states:Items() do
		iter.value:Delete()
	end
	self.states:Delete()
end

function FSM:Init(entity,...)
	self.entity = entity
	self:OnInit(...)
end

function FSM:LateInit()
	self:OnLateInit()
end

function FSM:InitState(entity,ownerFSM,...)
	for iter in self.states:Items() do
		iter.value:Init(entity,ownerFSM,...)
	end
end

function FSM:LateInitState()
	for iter in self.states:Items() do
		iter.value:LateInit()
	end
end

function FSM:AddState(state,stateMachineType)
	local stateMachine = stateMachineType.New()
	stateMachine:SetWorld(self.world)
	stateMachine:OnCreate()
	self.states:Push(stateMachine,state)
end

function FSM:EnterState(state)
	self.curState = state
	self.statesMachine = self:GetStateMachine(self.curState)
	self.statesMachine:OnEnter()
end

function FSM:SwitchState(state,...)
	local newStatesMachine = self:GetStateMachine(state)
	assert(newStatesMachine, string.format("不存在的状态机[%s]",tostring(state)))
	if self.curState == state and not newStatesMachine.REPEAT then
		return
	end

	local lastState = self:GetStateMachine(self.curState)
	if lastState and state ~= self.curState then
		lastState:OnExit()
	end
	
	self.curState = state
	self.statesMachine = newStatesMachine
	self.statesMachine:OnEnter(...)
end

function FSM:Update()
	if self.statesMachine then
		self.statesMachine:Update()
	end
end

function FSM:IsState(state)
	return self.curState == state
end

function FSM:GetState()
	return self.curState
end

function FSM:GetStateMachine(state)
	local stateIter = self.states:GetIterByIndex(state)
	return stateIter and stateIter.value or nil
end

--
function FSM:OnInit()
end

function FSM:OnLateInit()
end