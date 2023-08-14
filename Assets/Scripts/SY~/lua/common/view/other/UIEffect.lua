UIEffect = BaseClass("UIEffect")

local uid = 0
local function GetUid()
    uid = uid + 1
    return uid
end

function UIEffect:__Init()
    self.uid = 0
    self.gameObject = nil
    self.transform = nil
    self.effect = nil
    self.setting = nil

    self.isActive = true
    self.isPool = false
    self.isLoad = false
    self.isPlay = false

    self.assetLoader = nil

    self.playTimer = nil
    self.delayTimer = nil

    self.effectType = nil

    self.onComplete = nil

    self.conf = nil
    self.effectPath = nil

    self.order = nil

    self.posX = 0
    self.posY = 0
    self.posZ = 0

    self.scale = nil
end

function UIEffect:__Delete()
    if self.effect then
        if self.isPool then
            PoolManager.Instance:Push(PoolType.object,self.effectPath,self.effect)
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
end

--[[
    setting = {
        confId / assetId    配置ID / 资源ID
        delayTime           开始时间
        lastTime            持续时间
        pos                 位置
        scale               缩放
        isPool              是否缓存，默认true
        onLoad              加载完成回调
        onComplete          播放结束回调
        parent              挂载点
        order               层级
        timeScale   
        effectType
        name
        deleteOnComplete
    }
]]--
function UIEffect:Init(setting)
    self.setting = setting

    self.uid = GetUid()
    self.gameObject = BaseUtils.GetEmptyObject()
    self.transform = self.gameObject.transform

    if not self.setting.assetId and not self.setting.confId then
        LogErrorAny("请指定UI特效的配置表ID或者资源ID",self.setting)
        return
    end

    local isConfig = false
    local confId = self.setting.confId
    self.conf = confId and Config.EffectData.data_ui_effect[confId]
    if self.conf then
        -- 使用配置表数据，优先考虑setting数据
        self.assetId = self.setting.assetId or self.conf.asset_id
        self.delayTime = self.setting.delayTime or self.conf.delay_time
        self.lastTime = self.setting.lastTime or self.conf.last_time
        isConfig = true
    else
        -- 直接使用setting数据
        self.assetId = self.setting.assetId or self.setting.confId
        self.delayTime = self.setting.delayTime or 0
        self.lastTime = self.setting.lastTime or 100
    end

    local pos = self.setting.pos
    if pos then
        self:SetPos(pos.x or 0,pos.y or 0,pos.z or 0)
    end

    self.effectPath = string.format("effect/%s.prefab",tostring(self.assetId))
    self.isPool = self.setting.isPool or false
    self.timeScale = self.setting.timeScale or true
    self.effectType = self.setting.effectType
    self.onLoad = self.setting.onLoad
    self.onComplete = self.setting.onComplete
    self.parent = self.setting.parent
    self.order = self.setting.order

    local tips = isConfig and "Cfg" or "Res"
    self.gameObject.name = self.setting.name or string.format("effect:%s[%s]",tostring(self.assetId),tips)

    self:OnInit()
end

function UIEffect:GetId()
    return self.uid
end

function UIEffect:SetComplete(onComplete)
    self.onComplete = onComplete
end

function UIEffect:LoadEffect()
    if self.isLoad then
        return
    end
    self.isLoad = true

    local effect = PoolManager.Instance:Pop(PoolType.object,self.effectPath)
    if effect then
        effect.transform:SetParent(self.transform)
        self:SetEffect(effect)
    else
        self.assetLoader = AssetBatchLoader.New()
        self.assetLoader:Load({{file = self.effectPath,type = AssetType.Prefab}},self:ToFunc("EffectLoaded"))
    end
end

function UIEffect:EffectLoaded()
    local effect = self.assetLoader:GetAsset(self.effectPath,self.transform,false)
    self:SetEffect(effect)
    self:RemoveLoader()
end

function UIEffect:SetEffect(effect)
    self.effect = effect
    self.effect.transform:Reset()

    self:SetOrder(self.order)

    local scale = self.scale or self.setting.scale
    if not scale and self.conf then
        scale = self.conf.scale
    end

    if scale then
        self:SetScale(scale.x,scale.y,scale.z)
    end

    BaseUtils.ChangeLayers(self.effect,GDefine.Layer.ui)

    if self.onLoad then
        self.onLoad(self.setting.confId, self, self.setting.args)
    end
end


function UIEffect:SetParent(parent)
    self.transform:SetParent(parent)
    self.transform:Reset()
    self:RefreshPos()
end

function UIEffect:SetPos(x,y,z)
    self.posX = x or 0
    self.posY = y or 0
    self.posZ = z or 0
    self:RefreshPos()
end

function UIEffect:SetScale(x,y,z)
    x = x or 1000
    y = y or 1000
    z = z or 1000
    self.scale = {x=x,y=y,z=z}
    if self.effect then
        self.effect.transform:SetLocalScale(x/1000,y/1000,z/1000)
    end
end

function UIEffect:RefreshPos()
    if self.conf and (self.conf.offset_pos.x ~= 0 or self.conf.offset_pos.y ~= 0) then
        local offsetX = self.conf.offset_pos.x or 0
        local offsetY = self.conf.offset_pos.y or 0
        self.transform:SetLocalPosition(self.posX + offsetX,self.posY + offsetY,self.posZ)
    else
        self.transform:SetLocalPosition(self.posX,self.posY,self.posZ)
    end
end

function UIEffect:SetOrder(order)
    self.order = order
    if self.order and self.effect then
        UIUtils.SetEffectSortingOrder(self.effect,self.order)
    end
end

--延迟完成
function UIEffect:DelayComplete()
    self.delayTimer = nil
    self:BeginPlay()
end

function UIEffect:BeginPlay()
    self:SetActive(true)
    if self.lastTime > 0 then
        self.playTimer = TimerManager.Instance:AddTimer(1,self.lastTime * 0.001, self:ToFunc("PlayComplete") )
        self.playTimer:SetScale(self.setting.timeScale or true)
    end
end

function UIEffect:PlayComplete()
    self.playTimer = nil
    self.isPlay = false

    if self.onComplete then
        self.onComplete(self.uid,self.setting.args)
    end

    if self:IsValid() then
        self:SetActive(false)
        if self.setting.deleteOnComplete then
            self:Delete()
        end
    end
end

function UIEffect:RemoveLoader()
	if self.assetLoader then 
        self.assetLoader:Destroy()
	    self.assetLoader = nil 
    end
end

function UIEffect:SetActive(flag)
    if self.isActive ~= flag then
        self.isActive = flag
        self.gameObject:SetActive(flag)
    end
end

function UIEffect:IsActive()
    return self.isActive
end

function UIEffect:Play()
    if self.isPlay then return end

    self.isPlay = true
    self:SetParent(self.parent)
    self:LoadEffect()
    if self.delayTime > 0 then
        self:DelayPlay()
    else
        self:BeginPlay()
    end

    -- self:OnPlay()
end

function UIEffect:Stop()
    self.isPlay = false
    self:SetActive(false)
    self:RemoveTimer()
end

function UIEffect:RemoveTimer()
    if self.delayTimer then 
        TimerManager.Instance:RemoveTimer(self.delayTimer)
        self.delayTimer = nil 
    end
    if self.playTimer then 
        TimerManager.Instance:RemoveTimer(self.playTimer)
        self.playTimer = nil 
    end
end

function UIEffect:DelayPlay()
    self:SetActive(false)
    self.delayTimer = TimerManager.Instance:AddTimer(1,self.delayTime * 0.001, self:ToFunc("DelayComplete") )
    self.delayTimer:SetScale(self.setting.timeScale or true)
end

function UIEffect:IsValid()
    return self.gameObject ~= nil
end

--虚函数

function UIEffect:OnInit()
end
function UIEffect:OnPlay() 
end