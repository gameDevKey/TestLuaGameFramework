BaseTposeComponent = BaseClass("BaseTposeComponent",SECBClientComponent)

function BaseTposeComponent:__Init()
    self.tpose = nil
	self.tempTpose = nil
    self.tposeComplete = false
	self.tempTposeComplete = nil
    self.tposeListeners = {}
end

function BaseTposeComponent:__Delete()
	self:AddColor(false)
    self:RemoveTpose()
	self:RemoveTempTpose()
end

function BaseTposeComponent:AddTposeListener(callBack,args)
	self.tposeListeners[callBack] = args or {}
end

function BaseTposeComponent:ExistTpose()
	return self.tempTposeComplete ~= nil and self.tempTposeComplete or self.tposeComplete
end

function BaseTposeComponent:TposeComplete()
    self.tposeComplete = true
    for callBack,args in pairs(self.tposeListeners) do
		callBack(args)
	end
end

function BaseTposeComponent:RemoveTposeListener(callBack)
	if self.tposeListeners[callBack] then
		self.tposeListeners[callBack] = nil
	end
end

function BaseTposeComponent:GetBone(bone)
	if bone == GDefine.BoneName.root then
		return self.clientEntity.ClientTransformComponent.transform,true
	elseif bone == GDefine.BoneName.origin then
		return self.clientEntity.ClientTransformComponent.forwardTrans or self.clientEntity.ClientTransformComponent.tposeTrans,true
	end

	local tpose = self:GetTpose()
	if not tpose then
		return self.clientEntity.ClientTransformComponent.transform,false
	end

	local boneTrans = tpose.transform:Find(bone)
	if not boneTrans then
		return self.clientEntity.ClientTransformComponent.transform,false
	else
		return boneTrans,true
	end
end

function BaseTposeComponent:GetBonePos(bone)
    local trans = self:GetBone(bone)
    return trans.position
end

function BaseTposeComponent:ExistBone(bone)
	return self:GetTpose().transform:Find(bone) ~= nil
end

function BaseTposeComponent:RemoveTpose()
    if self.tpose then
        self.world.BattleAssetsSystem:CancelTpose(self.tpose)
        self.tpose:Delete()
        self.tpose = nil
    end
    self.tposeComplete = false
end

function BaseTposeComponent:RemoveTempTpose()
	if self.tempTpose then
		self.world.BattleAssetsSystem:CancelTpose(self.tempTpose)
        self.tempTpose:Delete()
        self.tempTpose = nil
	end
	self.tempTposeComplete = nil
end

function BaseTposeComponent:AddColor(flag,color)
	local tpose = self:GetTpose()
	if not tpose or not tpose.mat then
		return
	end

	if flag then
		tpose.mat:SetColor("_AddColor",ColorUtils.HexToColor(color))
	else
		tpose.mat:SetColor("_AddColor",Color(0,0,0,1))
	end
end

function BaseTposeComponent:SetTempTposeComplete(flag)
	self.tempTposeComplete = flag
end

function BaseTposeComponent:SetTempTpose(tempTpose)
	if tempTpose == nil then
		self:RemoveTempTpose()
		return
	end
	if self.tempTpose then
		self:RemoveTempTpose()
	end
	self.tempTpose = tempTpose
end

function BaseTposeComponent:GetTpose()
	return self.tempTpose or self.tpose
end

function BaseTposeComponent:ShowTpose()
	if self.tpose == nil and self.tempTpose == nil then
		return
	end
	if self.tempTpose then
		self.tempTpose.gameObject:SetActive(true)
		self.tpose.gameObject:SetActive(false)
	else
		self.tpose.gameObject:SetActive(true)
	end
end