ShaderEffectComponent = BaseClass("ShaderEffectComponent",SECBClientComponent)

function ShaderEffectComponent:__Init()
    self.effectInfos = {}
    self.timers = {}
end

function ShaderEffectComponent:__Delete()
    if self.clientEntity.TposeComponent:ExistTpose() then
        local tpose = self.clientEntity.TposeComponent:GetTpose()
        tpose.renderer.materials = tpose.materials
    end

    for k,v in pairs(self.effectInfos) do
        if v.shaderAnim then
            v.shaderAnim:Destroy()
        end
    end

    for k,v in pairs(self.timers) do
        self:RemoveTimer(k)
    end
    self.timers = {}
end

function ShaderEffectComponent:OnInit()
end

function ShaderEffectComponent:GetTimerKey(effectType)
    return self.clientEntity.entity.uid .. '_' .. tostring(effectType)
end

function ShaderEffectComponent:AddTimer(key,count,time,func)
    self:RemoveTimer(key)
    self.timers[key] = TimerManager.Instance:AddTimer(count,time,func)
    self.timers[key]:SetComplete(self:ToFunc("OnTimerComplete"),key)
    return self.timers[key]
end

function ShaderEffectComponent:OnTimerComplete(args,id)
    self:RemoveTimer(args)
end

function ShaderEffectComponent:RemoveTimer(key)
    if self.timers[key] then
        TimerManager.Instance:RemoveTimer(self.timers[key])
        self.timers[key] = nil
    end
end

function ShaderEffectComponent:OnLateInit()
    self.clientEntity.TposeComponent:AddTposeListener(self:ToFunc("TposeFinish"))
end

function ShaderEffectComponent:TposeFinish()
    for k,v in pairs(self.effectInfos) do
        self:ActiveEffect(k,v.flag)
    end
end

function ShaderEffectComponent:ActiveEffect(effectType,flag,duration)
    local info = self.effectInfos[effectType]
    if info then
        if flag == info.flag then
            return
        end
    else
        if not flag then
            return
        end
    end

    self:PlayEffect(effectType,flag,duration)
end

function ShaderEffectComponent:RemoveEffectMat(info)
    if not info.isAddMat then
        return
    end
    info.isAddMat = false
    local tpose = self.clientEntity.TposeComponent:GetTpose()
    local len = tpose.renderer.materials.Length
    local matArray = CS.System.Array.CreateInstance(typeof(CS.UnityEngine.Material),len - 1)
    local index = -1
    for i=0,len - 1 do
        if tpose.renderer.materials[i].shader.name ~= info.mat.shader.name then
            index = index + 1
            matArray[index] = tpose.renderer.materials[i]
        end
    end
    if index ~= -1 then
        tpose.renderer.materials = matArray
    end
end

function ShaderEffectComponent:AddEffectMat(info)
    if info.isAddMat then
        return
    end
    info.isAddMat = true
    local tpose = self.clientEntity.TposeComponent:GetTpose()
    local len = tpose.renderer.materials.Length
    local matArray = CS.System.Array.CreateInstance(typeof(CS.UnityEngine.Material),len + 1)
    for i=0,len - 1 do matArray[i] = tpose.renderer.materials[i] end
    matArray[len] = info.mat
    tpose.renderer.materials = matArray
end

function ShaderEffectComponent:PlayEffect(effectType,flag,duration)
    local info = self.effectInfos[effectType]

    if not info then
        info = {}
        info.value = 0
        info.isAddMat = false
        info.mat = GameObject.Instantiate(self:GetEffectMat(effectType))
        self.effectInfos[effectType] = info
    end

    info.flag = flag

    if not self.clientEntity.TposeComponent:ExistTpose() then
        return
    end

    self:AddEffectMat(info)

    if info.flag then
        info.shaderAnim = self:GetEffectAnimTween(effectType)
        if info.shaderAnim then
            info.shaderAnim:SetComplete(self:ToFunc("OnAnimComplete"),effectType)
            info.shaderAnim:Clean()
            info.shaderAnim:Play()
        end
        if duration and duration > 0 then
            local timer = self:AddTimer(self:GetTimerKey(effectType),1,duration,self:ToFunc("OnAnimComplete"))
            timer:SetArgs(effectType)
        end
    else
        self:OnAnimComplete(effectType)
    end
end

function ShaderEffectComponent:OnAnimComplete(effectType)
    local info = self.effectInfos[effectType]
    if info then
        info.flag = false
        self:RemoveEffectMat(info)
        if info.shaderAnim then
            info.shaderAnim:Clean()
            info.shaderAnim = nil
        end
    end
    self:RemoveTimer(self:GetTimerKey(effectType))
end

function ShaderEffectComponent:GetEffectMat(effectType)
    if effectType == BattleDefine.ShaderEffect.frozen then
        return PreloadManager.Instance:GetAsset(AssetPath.unitFrozenMat)
    end
    if effectType == BattleDefine.ShaderEffect.petrifying then
        return PreloadManager.Instance:GetAsset(AssetPath.unitPetrifyingMat)
    end
    if effectType == BattleDefine.ShaderEffect.flash then
        return PreloadManager.Instance:GetAsset(AssetPath.unitFlashMat)
    end
    error(string.format("请设置特效类型[%s]对应的Shader材质",tostring(effectType)))
end

function ShaderEffectComponent:GetEffectAnimTween(effectType)
    if effectType == BattleDefine.ShaderEffect.frozen then
        return self:GetFrozenAnimTween()
    end
    if effectType == BattleDefine.ShaderEffect.petrifying then
        return self:GetPetrifyingAnimTween()
    end
end

function ShaderEffectComponent:GetFrozenAnimTween()
    local info = self.effectInfos[BattleDefine.ShaderEffect.frozen]
    if not info.shaderAnim then
        info.shaderAnim = ToFloatValueAnim.New(0,5,0,function(value)
            info.value = value
            info.mat:SetFloat("_LerpHeight",value)
        end)
    end
    local toValue = 0
    local needTime = 0
    if info.flag then
        toValue = 5
        needTime = math.abs(info.value - 5) * (0.2 / 5)
    else
        toValue = 0
        needTime = math.abs(info.value) * (0.1 / 5)
    end
    info.shaderAnim["fromValue"] = info.value
    info.shaderAnim["toValue"] = toValue
    info.shaderAnim["time"] = needTime
    return info.shaderAnim
end

function ShaderEffectComponent:GetPetrifyingAnimTween()
    local info = self.effectInfos[BattleDefine.ShaderEffect.petrifying]
    if not info.shaderAnim then
        info.shaderAnim = ToFloatValueAnim.New(0,5,0,function(value)
            info.value = value
            info.mat:SetFloat("_LerpHeight",value)
        end)
    end
    local toValue = 0
    local needTime = 0
    if info.flag then
        toValue = 5
        needTime = math.abs(info.value - 5) * (0.2 / 5)
    else
        toValue = 0
        needTime = math.abs(info.value) * (0.1 / 5)
    end
    info.shaderAnim["fromValue"] = info.value
    info.shaderAnim["toValue"] = toValue
    info.shaderAnim["time"] = needTime
    return info.shaderAnim
end