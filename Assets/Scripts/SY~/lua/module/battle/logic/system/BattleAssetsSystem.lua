BattleAssetsSystem = BaseClass("BattleAssetsSystem",SECBSystem)

local TposeType = 
{
    unit = 1,
}

function BattleAssetsSystem:__Init()
    self.assetsPool = {}

    self.waitRoleTposes = SECBList.New()
    self.roleLoadNum = 0

    self.tposeLoads = {}

    self.effectManager = nil
end

function BattleAssetsSystem:__Delete()
    self.effectManager:Clean()
    self.effectManager:Delete()
    
    self.waitRoleTposes:Delete()
end

--
function BattleAssetsSystem:OnInitSystem()
    self.effectManager = EffectManager.New()
    self.effectManager:Init(self.world)
end

function BattleAssetsSystem:GetBound(tag)
    local poolKey = nil
    if tag == BattleDefine.EntityTag.hero 
        or tag == BattleDefine.EntityTag.commander 
        or tag == BattleDefine.EntityTag.unit then
        poolKey = "unit_bound"
    else
        poolKey = "empty_bound"
    end

    local object = PoolManager.Instance:Pop(PoolType.object,poolKey)
    if object then
        return object,poolKey
    elseif poolKey == "empty_bound" then
        object = GameObject.Instantiate(BattleDefine.nodeObjs["template/empty_bound"])
    elseif poolKey == "unit_bound" then
        object = GameObject.Instantiate(BattleDefine.nodeObjs["template/unit_bound"])
    end
    return object,poolKey
end

function BattleAssetsSystem:PushBound(poolKey,object)
    PoolManager.Instance:Push(PoolType.object,poolKey,object)
end

function BattleAssetsSystem:PushPlaceBound(object)
    PoolManager.Instance:Push(PoolType.object,"place_bound",object)
end



function BattleAssetsSystem:PushPlaceBound2d(object)
    PoolManager.Instance:Push(PoolType.object,"place_bound_2d",object)
end

function BattleAssetsSystem:AddRoleTpose(setting,callback)
    local loadInfo = {}
    loadInfo.callback = callback
    loadInfo.args = setting.args
    loadInfo.tpose = HeroTpose.New()
    setting.args = loadInfo

    self.waitRoleTposes:Push({tpose = loadInfo.tpose,setting = setting,type = TposeType.role},loadInfo.tpose)
    
    return loadInfo.tpose
end

function BattleAssetsSystem:LoadRoleTpose()
    if self.roleLoadNum > 0 or self.waitRoleTposes.length <= 0 then
        return
    end

    local info = self.waitRoleTposes:PopHead()

    self.roleLoadNum = self.roleLoadNum + 1
    self.tposeLoads[info.tpose] = info
    info.tpose:Load(info.setting,self:ToFunc("OnRoleTposeLoaded"))
end

function BattleAssetsSystem:OnRoleTposeLoaded(info)
    self.roleLoadNum = self.roleLoadNum - 1
    info.callback(info.args)
    self.tposeLoads[info.tpose] = nil
    self:LoadRoleTpose()
end

function BattleAssetsSystem:CancelTpose(tpose)
    self.waitRoleTposes:RemoveByIndex(tpose)

    local info = self.tposeLoads[tpose]

    if info then
        self.tposeLoads[tpose] = nil
        self.roleLoadNum = self.roleLoadNum - 1
        self:LoadRoleTpose()
    end
end

function BattleAssetsSystem:PlayHitEffect(entityUid,effectId)
    if DEBUG_ACTIVE_EFFECT == false then
        return
    end

    if GDefine.platform == GDefine.PlatformType.WebGLPlayer then
        return
    end

    if effectId and effectId ~= 0 then 
        self:PlayUnitEffect(entityUid,effectId) 
    end
end

function BattleAssetsSystem:PlayUnitEffect(entityUid,effectId)
    if DEBUG_ACTIVE_EFFECT == false then
        return
    end

    if not self.world.opts.isClient then
        return nil
    end

    local entity = self.world.EntitySystem:GetEntity(entityUid)
    if not entity then
        return nil
    end

    local setting = {}
    setting.entity = entity.clientEntity
    setting.confId = effectId
    local unitEffect = UnitEffect.New()
    unitEffect:Init(setting,self.effectManager)

    self.effectManager:AddEffect(unitEffect)
    entity.clientEntity.EffectComponent:AddEffect(unitEffect)

    unitEffect:Play()
    return unitEffect
end


function BattleAssetsSystem:PlayStretchEffect(entityUid,targetEntityUid,effectId)
    if DEBUG_ACTIVE_EFFECT == false then
        return
    end

    if not self.world.opts.isClient then
        return nil
    end

    local entity = self.world.EntitySystem:GetEntity(entityUid)
    if not entity then
        return nil
    end

    local setting = {}
    setting.entity = entity.clientEntity
    setting.confId = effectId
    setting.targetEntityUid = targetEntityUid
    local stretchEffect = StretchEffect.New()
    stretchEffect:Init(setting,self.effectManager)

    self.effectManager:AddEffect(stretchEffect)
    entity.clientEntity.EffectComponent:AddEffect(stretchEffect)

    stretchEffect:Play()
    return stretchEffect
end

function BattleAssetsSystem:PlaySceneEffect(effectId,x,y,z,effectType)
    if DEBUG_ACTIVE_EFFECT == false then
        return
    end

    if not self.world.opts.isClient or not effectId or effectId == 0 then
        return nil
    end

    local setting = {}
    setting.confId = effectId
    setting.pos = Vector3(x * FPFloat.PrecisionFactor,y * FPFloat.PrecisionFactor,z * FPFloat.PrecisionFactor)
    setting.effectType = effectType
    local sceneEffect = SceneEffect.New()
    sceneEffect:Init(setting,self.effectManager)
    self.effectManager:AddHosting(sceneEffect)

    sceneEffect:Play()
    return sceneEffect
end

function BattleAssetsSystem:PlaySimpleEffect(effectId,parent,isHosting)
    if DEBUG_ACTIVE_EFFECT == false then
        return
    end
    
    if not self.world.opts.isClient then
        return nil
    end

    local setting = {}
    setting.confId = effectId
    setting.parent = parent
    local simpleEffect = SimpleEffect.New()
    simpleEffect:Init(setting,self.effectManager)
    self.effectManager:AddEffect(unitEffect)

    if isHosting then
        self.effectManager:AddHosting(simpleEffect)
    else
        self.effectManager:AddEffect(simpleEffect)
    end

    simpleEffect:Play()
    return simpleEffect
end

function BattleAssetsSystem:RemoveEffect(uid)
    self.effectManager:RemoveEffect(uid)
end

function BattleAssetsSystem:GetPoolAsset(file)
    if self.assetsPool[file] then
        return table.remove(self.assetsPool[file])
    else
        return nil
    end
end

function BattleAssetsSystem:CacheAsset(file,obj)
    if not self.assetsPool[file] then
        self.assetsPool[file] = {}
    end
    local trans = go.transform
	trans:SetParent(self.assetsPoolRoot.transform)
	table.insert(self.assetsPool[file],go)
end

function BattleAssetsSystem:OnUpdate()
    self.effectManager:Update()
end