EffectBase = BaseClass("EffectBase")
EffectBase.NOT_CLEAR = true

local uid = 0
local function GetUid()
    uid = uid + 1
    return uid
end
function EffectBase.ResetUid()
    uid = 0
end

function EffectBase:__Init()
    self.uid = 0
    self.gameObject = nil
    self.transform = nil
    self.effect = nil
    self.setting = nil

    self.effectManager = nil

    self.isActive = true
    self.isPool = true
    self.isLoad = false
    self.isPlay = false

    self.assetLoader = nil

    self.playTimer = nil
    self.delayTimer = nil

    self.layer = nil

    self.effectType = nil

    self.createUid = nil

    self.isAutoDel = true

    self.onComplete = nil

    self.conf = nil
    self.effectPath = nil

    self.posX = 0
    self.posY = 0
    self.posZ = 0
end

function EffectBase:__Delete()
    if self.effect then
        if self.isPool then
            PoolManager.Instance:Push(PoolType.battle_effect,self.effectPath,self.effect)
        else
            GameObject.Destroy(self.effect)
        end
        self.effect = nil
    end

    if self.gameObject then
        PoolManager.Instance:Push(PoolType.object,PoolDefine.PoolKey.empty_object,self.gameObject)
        self.gameObject = nil
        self.transform = nil
    end

    self:RemoveTimer()
    self:RemoveLoader()

    if self.createUid then
        self.effectManager:Remove(self.createUid)
        self.createUid = nil
    end

    self:ChangeEffectTypeInfo(-1)
end

function EffectBase:Init(setting,effectManager)
    self.setting = setting
    self.effectType = setting.effectType
    self.effectManager = effectManager

    self.uid = GetUid()
    self.gameObject = BaseUtils.GetEmptyObject()
    self.transform = self.gameObject.transform

    self.layer = setting.layer or GDefine.Layer.layer7

    self.order = setting.order

    self.conf = self.effectManager.world.BattleConfSystem:EffectData_data_skill_effect(self.setting.confId)
    if not self.conf then
        self.delayTime = 0
        self.lastTime = 100
        LogErrorf("战斗特效异常,不存在特效配置[%s]",tostring(self.setting.confId))
    else
        self.effectPath = string.format("effect/%s.prefab",self.conf.asset_id)
        self.delayTime = self.setting.delayTime or self.conf.delay_time
        self.lastTime = self.setting.lastTime or self.conf.last_time
        self.isPool = self.setting.isPool or true
        self.timeScale = self.setting.timeScale or true
        self.effectType = self.setting.effectType
        self.onComplete = self.setting.onComplete

        self.gameObject.name = self.setting.name or string.format("effect:%s[配置Id:%s]",self.conf.asset_id,self.setting.confId)

        self:OnInit()
    end
end


function EffectBase:GetId()
    return self.uid
end

function EffectBase:SetComplete(onComplete)
    self.onComplete = onComplete
end

function EffectBase:LoadEffect()
    if self.isLoad then
        return
    end
    self.isLoad = true

    local effect = PoolManager.Instance:Pop(PoolType.battle_effect,self.effectPath)
    if effect then
        effect.transform:SetParent(self.transform)
        self:SetEffect(effect)
    else
        self.assetLoader = AssetBatchLoader.New()
        self.assetLoader:Load({{file = self.effectPath,type = AssetType.Prefab}},self:ToFunc("EffectLoaded"))
    end
end

function EffectBase:EffectLoaded()
    self.createUid = self.effectManager:AddCreateByLoader(self.assetLoader,self.effectPath,self.transform,self:ToFunc("EffectCreate"),self.stopwatch)
end

function EffectBase:EffectCreate(effect,createType)
    self.createUid = nil
    self:RemoveLoader()
    self:SetEffect(effect)
end


function EffectBase:SetEffect(effect)
    self.effect = effect
    self.effect.transform:Reset()

    if self.conf.scale then
        local scale = self.conf.scale * 0.001
        self.effect.transform:SetLocalScale(scale,scale,scale)
    end

    self:SetOrder(self.order)

    BaseUtils.ChangeLayers(self.effect,self.layer)

    self:OnCreate()
end

function EffectBase:SetOrder(order)
    self.order = order
    if self.effect and self.order then
        UIUtils.SetEffectSortingOrder(self.effect,self.order)
    end
end

function EffectBase:SetParent(parent)
    self.transform:SetParent(parent)
    self.transform:Reset()
    self:RefreshPos()
end

function EffectBase:SetPos(x,y,z)
    self.posX = x or 0
    self.posY = y or 0
    self.posZ = z or 0
    self:RefreshPos()
end

function EffectBase:RefreshPos()
    if self.conf.offset_pos.x ~= 0 or self.conf.offset_pos.y ~= 0 or self.conf.offset_pos.z ~= 0 then
        local offsetX = self.conf.offset_pos.x or 0
        local offsetY = self.conf.offset_pos.y or 0
        local offsetZ = self.conf.offset_pos.z or 0
        self.transform:SetLocalPosition(self.posX + offsetX * 0.001,self.posY + offsetY * 0.001,self.posZ + offsetZ * 0.001)
    else
        self.transform:SetLocalPosition(self.posX,self.posY,self.posZ)
    end
end

function EffectBase:SetEffectType(effectType)
    self.effectType = effectType
end

--延迟完成
function EffectBase:DelayComplete()
    self.delayTimer = nil
    self:BeginPlay()
end

function EffectBase:BeginPlay()
    self:SetActive(true)
    if self.lastTime > 0 then
        self.playTimer = TimerManager.Instance:AddTimer(1,self.lastTime * 0.001, self:ToFunc("PlayComplete") )
        self.playTimer:SetScale(self.setting.timeScale or true)
    end
end

function EffectBase:PlayComplete()
    self.playTimer = nil
    self.isPlay = false

    if self.onComplete then
        self.onComplete(self.uid,self.setting.args)
    end

    if self:IsValid() then
        self:SetActive(false)
    end
end

function EffectBase:SetAutoDel(flag)
    self.isAutoDel = flag
end

function EffectBase:RemoveLoader()
	if self.assetLoader then 
        self.assetLoader:Destroy()
	    self.assetLoader = nil 
    end
end

function EffectBase:SetActive(flag)
    if self.isActive ~= flag then
        self.isActive = flag
        self.gameObject:SetActive(flag)
    end
end

function EffectBase:Play()
    if self.isPlay then return end

    self.isPlay = true
    self:LoadEffect()
    if self.delayTime > 0 then
        self:DelayPlay()
    else
        self:BeginPlay()
    end
    self:ChangeEffectTypeInfo(1)
    self:OnPlay()
end

function EffectBase:ChangeEffectTypeInfo(value)
    if not self.effectType then return end
    local curNum = EffectDefine.EffectNumInfo[self.effectType] or 0
    curNum = curNum + value
    EffectDefine.EffectNumInfo[self.effectType] = curNum >= 0 and curNum or 0
end

function EffectBase:Stop()
    self.isPlay = false
    self:SetActive(false)
    self:RemoveTimer()
end

function EffectBase:RemoveTimer()
    if self.delayTimer then 
        TimerManager.Instance:RemoveTimer(self.delayTimer)
        self.delayTimer = nil 
    end
    if self.playTimer then 
        TimerManager.Instance:RemoveTimer(self.playTimer)
        self.playTimer = nil 
    end
end

function EffectBase:DelayPlay()
    self:SetActive(false)
    self.delayTimer = TimerManager.Instance:AddTimer(1,self.delayTime * 0.001, self:ToFunc("DelayComplete") )
    self.delayTimer:SetScale(self.setting.timeScale or true)
end

function EffectBase:IsValid()
    return self.gameObject ~= nil
end

function EffectBase:CheckRef()
end

function EffectBase:Update()
    self:OnUpdate()
end

--虚函数

function EffectBase:OnInit()
end
function EffectBase:OnCreate()
end
function EffectBase:OnPlay() 
end
function EffectBase:OnUpdate() 
end
function EffectBase:Clear()
end