BattlePveMixedSystem = BaseClass("BattlePveMixedSystem",SECBEntitySystem)
BattlePveMixedSystem.NAME = "BattleMixedSystem"

function BattlePveMixedSystem:__Init()
    self.mixedSystem = nil
end

function BattlePveMixedSystem:__Delete()
    self:ClearCameraShakeAnim()

    if self.mixedSystem then
        self.mixedSystem:Delete()
        self.mixedSystem = nil
    end
end

function BattlePveMixedSystem:OnInitSystem()
    self.mixedSystem = BattleMixedSystem.New()
    self.mixedSystem:SetWorld(self.world)
end

function BattlePveMixedSystem:OnLateInitSystem()
    self.world.EventTriggerSystem:AddListener(BattleEvent.unit_die,self:ToFunc("UnitDieAddChest"))
end

function BattlePveMixedSystem:UnitDieAddChest(eventParams)
    --TODO  单位死亡随机掉落逻辑
end

function BattlePveMixedSystem:GetStancePos(camp,index)
    return self.mixedSystem:GetStancePos(camp,index)
end

function BattlePveMixedSystem:GetRotateDependCamp()
    return self.mixedSystem:GetRotateDependCamp()
end

function BattlePveMixedSystem:GetSceneInfoPos(name)
    return self.mixedSystem:GetSceneInfoPos(name)
end

function BattlePveMixedSystem:GetHomeStancePos(camp)
    return self.mixedSystem:GetHomeStancePos(camp)
end

function BattlePveMixedSystem:GetInitTargetPos(camp)
    return self.mixedSystem:GetInitTargetPos(camp)
end

function BattlePveMixedSystem:GetStanceDir(camp)
    return self.mixedSystem:GetStanceDir(camp)
end

function BattlePveMixedSystem:IsSelfCamp(camp)
    return self.mixedSystem:IsSelfCamp(camp)
end

function BattlePveMixedSystem:GetReverseCamp(camp)
    return self.mixedSystem:GetReverseCamp(camp)
end

function BattlePveMixedSystem:GetCampIndex(camp)
    return self.mixedSystem:GetCampIndex(camp)
end

function BattlePveMixedSystem:GetEnemyHomeUid(camp)
    return self.mixedSystem:GetEnemyHomeUid(camp)
end

function BattlePveMixedSystem:ChangeRange(fromRange,targetRange,changes)
    for k,v in pairs(fromRange) do
        targetRange[k] = v
    end 
    for iter in changes:Items() do
        local args = iter.value
        if targetRange.type == BattleDefine.RangeType.circle then
            local val = self.world.PluginSystem.CalcAttr:CalcVal(fromRange.radius,args)
            targetRange.radius = targetRange.radius + val
        elseif range.type == BattleDefine.RangeType.annulus then
            local val = self.world.PluginSystem.CalcAttr:CalcVal(fromRange.radius,args)
            targetRange.radius = targetRange.radius + val

            val = self.world.PluginSystem.CalcAttr:CalcVal(fromRange.inRadius,args)
            targetRange.inRadius = targetRange.inRadius + val
        end
    end
end

function BattlePveMixedSystem:ShakeCamera(time,strength,vibrato,randomness)
	if self.cameraShakeAnim then
		return
	end

	self.cameraShakeAnim = ShakePositionAnim.New(BattleDefine.nodeObjs["main_camera"].transform,time,strength,vibrato,randomness,false,true)
	self.cameraShakeAnim:SetTimeScale(true)
	self.cameraShakeAnim:SetComplete(self:ToFunc("CameraShakeAnimComplete"))
	self.cameraShakeAnim:Play()
end

function BattlePveMixedSystem:CameraShakeAnimComplete()
	self:ClearCameraShakeAnim()
end

function BattlePveMixedSystem:ClearCameraShakeAnim()
	if self.cameraShakeAnim then
		self.cameraShakeAnim:Destroy()
		self.cameraShakeAnim = nil
	end
end

function BattlePveMixedSystem:GetTargetArgs(targetCondId,inArgs)
    if not targetCondId or targetCondId == 0 then
        return nil
    end

    local targetCondConf = self.world.BattleConfSystem:SkillData_data_target_cond(targetCondId)
    local targetArgs = {}
    if not inArgs then inArgs = {} end

	targetArgs.targetCamp = inArgs.targetCamp or targetCondConf.target_camp
	targetArgs.targetTypes = inArgs.targetTypes or targetCondConf.unit_type
	targetArgs.walkType = inArgs.walkType or targetCondConf.walk_type
	targetArgs.targetLifeTypes = inArgs.targetLifeTypes or targetCondConf.life_type
	targetArgs.raceTypes = inArgs.raceTypes or targetCondConf.race_type
	targetArgs.targetConds = inArgs.targetConds or targetCondConf.target_cond

    return targetArgs
end

function BattlePveMixedSystem:BattlePause(flag)
    if flag then
        Time.timeScale = 0.0
    else
        Time.timeScale = 1.0
    end
end