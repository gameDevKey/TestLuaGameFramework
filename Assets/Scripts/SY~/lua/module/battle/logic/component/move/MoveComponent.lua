MoveComponent = BaseClass("MoveComponent",SECBComponent)

function MoveComponent:__Init()
	self.runMover = nil
	self.movers = {}
	self.onComplete = nil
	self.completeArgs = nil
	self.movePaths = nil
end

function MoveComponent:__Delete()
	for _,v in pairs(self.movers) do
		v:Delete()
	end
end

function MoveComponent:OnInit()
	local lineraMover = self:CreateMover(BattleDefine.MoverType.linera)
	self.movers[BattleDefine.MoverType.linera] = lineraMover
end

function MoveComponent:OnLateInit()

end

function MoveComponent:CreateMover(moverType)
	local mover = nil
	if moverType == BattleDefine.MoverType.linera then
		mover = LineraMover.New()
	elseif moverType == BattleDefine.MoverType.fly_hit_lock_mover then
		mover = FlyHitLockMover.New()
	elseif moverType == BattleDefine.MoverType.parabola then
		mover = ParabolicMover.New()
	else
		assert(false,string.format("未知的移动类型[%s]",tostring(moverType)))
	end
	
	mover:SetWorld(self.world)
	mover:SetEntity(self.entity)
	mover:Init()
	return mover
end

function MoveComponent:MoveToPos(x,y,z,info)
	self.onComplete = info.onComplete
	self.completeArgs = info.args

	local moverType = info.moverType or BattleDefine.MoverType.linera
	
	self.runMover = self.movers[moverType]
	if not self.runMover then
		self.runMover = self:CreateMover(moverType)
		self.movers[moverType] = self.runMover
	end

	if self.entity.StateComponent and self.entity.StateComponent:CanSwitchState() then
		self.entity.StateComponent:SetState(BattleDefine.EntityState.move)
	end

	self:SetKvTargetPos(x,y,z)
	
	self.runMover:SetParams(info.params)
	self.runMover:SetUpdateCallback(info.onUpdate,info.args)

	self.entity.RotateComponent:LookAtPos(x,z)

	self.runMover:MoveToPos(x,y,z,self:ToFunc("MoveComplete"))
end

function MoveComponent:MoveToPath(paths,info)
	self.onComplete = info.onComplete
	self.completeArgs = info.args

	local moverType = info.moverType or BattleDefine.MoverType.linera
	
	self.runMover = self.movers[moverType]
	if not self.runMover then
		self.runMover = self:CreateMover(moverType)
		self.movers[moverType] = self.runMover
	end

	if self.entity.StateComponent and self.entity.StateComponent:CanSwitchState() then
		self.entity.StateComponent:SetState(BattleDefine.EntityState.move)
	end

	self.runMover:SetParams(info.params)
	self.runMover:SetUpdateCallback(info.onUpdate,info.args)

	self.movePaths = paths

	local pos = table.remove(self.movePaths,1)

	self:SetKvTargetPos(pos.x,pos.y,pos.z)

	self.entity.RotateComponent:LookAtPos(pos.x,pos.z)
	self.runMover:MoveToPos(pos.x,pos.y,pos.z,self:ToFunc("MovePathComplete"))
end
function MoveComponent:MovePathComplete()
	local pos = table.remove(self.movePaths,1)
	if pos then
		self.entity.RotateComponent:LookAtPos(pos.x,pos.z)
		self.runMover:MoveToPos(pos.x,pos.y,pos.z,self:ToFunc("MovePathComplete"))
	else
		self:MoveComplete()
	end
end

function MoveComponent:SetKvTargetPos(x,y,z)
	if self.entity.KvDataComponent then
		local pos = self.entity.KvDataComponent:GetData(BattleDefine.EntityKvType.target_pos) or FPVector3(0,0,0)
		pos:Set(x,y,z)
		self.entity.KvDataComponent:SetData(BattleDefine.EntityKvType.target_pos,pos)
	end
end

function MoveComponent:IsSameMovePos(x,y,z)
	local pos = self.entity.KvDataComponent:GetData(BattleDefine.EntityKvType.target_pos) or FPVector3(0,0,0)
	if not self.entity.StateComponent:IsState(BattleDefine.EntityState.move) then
		return false
	else
		local pos = self.entity.KvDataComponent:GetData(BattleDefine.EntityKvType.target_pos)
		if not pos then
			return false
		else
			if pos.x == x and pos.y == y and pos.z == z then
				return true
			else
				return false
			end
		end
	end
end

function MoveComponent:GetRunMover()
	return self.runMover
end

function MoveComponent:DoMoveForward(step)
	local forward = self.entity.TransformComponent.rotation * FPVector3.forward
	forward:Normalize(step)
	self:SetPosOffset(forward.x,forward.y,forward.z)
end

function MoveComponent:OnUpdate()
	-- if self.entity.StateComponent and not self.entity.StateComponent:CanMove() then
	-- 	return
	-- end
	local flag = self.world.PluginSystem.EntityStateCheck:CanMove(self.entity)
	if not flag then
		return
	end
	
	if self.runMover then
		self.runMover:Update()
	end
end

function MoveComponent:MoveComplete()
	self.runMover = nil

	if self.entity.StateComponent and self.entity.StateComponent:IsState(BattleDefine.EntityState.move) then
		self.entity.StateComponent.stateFSM.statesMachine:StopMove()
	end

	if self.onComplete then
		local completeFunc = self.onComplete
		local completeArgs = self.completeArgs
        self.onComplete = nil
		self.completeArgs = nil
        completeFunc(completeArgs)
    end
end

function MoveComponent:SetPosOffset(x,y,z)
	self.entity.TransformComponent:AddVelocity(x,y,z)

	-- if not self.entity.CollistionComponent then
	-- 	self.entity.TransformComponent:SetPosByOffset(x,y,z)
	-- else
	-- 	local curPos = self.entity.TransformComponent:GetPos()
	-- 	local toPos = FPVector3(curPos.x + x,curPos.y,curPos.z + z)
	-- 	local newTo = self.entity.CollistionComponent:CheckCollistion(curPos,toPos)
	-- 	self.entity.TransformComponent:SetPosByOffset(newTo.x,y,newTo.z)
	-- 	-- if DBUEG_PAS then
	-- 	-- 	local debugPos = self.entity.TransformComponent:GetPos()
	-- 	-- 	self.entity.clientEntity.ClientTransformComponent:SyncPos()
	-- 	-- 	Log("调试单位",self.entity.uid,debugPos.x,debugPos.y,debugPos.z)
	-- 	-- end
	-- end
end

function MoveComponent:StopMove()
	if not self.runMover then
		return
	end

	self.runMover = nil

	if self.entity.StateComponent and self.entity.StateComponent:IsState(BattleDefine.EntityState.move) then
		self.entity.StateComponent.stateFSM.statesMachine:StopMove()
	end

	self.onComplete = nil
	self.completeArgs = nil
end