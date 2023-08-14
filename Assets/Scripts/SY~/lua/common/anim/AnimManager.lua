AnimManager = SingleClass("AnimManager")
AnimManager.Type = {
    Effect = 1,
    DelayPlay = 2,
}

function AnimManager:__Init()
    self.OnEffectPlay = self:ToFunc("EffectPlay")
    self.OnDelayAnimPlay = self:ToFunc("DelayAnimPlay")
    self.listenerInfos = {}
end

function AnimManager:__Delete()
    self.listenerInfos = {}
end

function AnimManager:AddListener(instanceId,animName,type,func)
    if not self.listenerInfos[instanceId] then
        self.listenerInfos[instanceId] = {}
    end
    local nameHash = Animator.StringToHash(animName)
    if not self.listenerInfos[instanceId][nameHash] then
        self.listenerInfos[instanceId][nameHash] = {}
    end
    self.listenerInfos[instanceId][nameHash][type] = {animName = animName,func = func}
end

function AnimManager:RemoveListener(instanceId,animName,type)
    if instanceId then
        if animName then
            local nameHash = Animator.StringToHash(animName)
            if type then
                local info = self.listenerInfos[instanceId]
                if info and info[instanceId][nameHash] and info[instanceId][nameHash][type] then
                    info[instanceId][nameHash][type] = nil
                end
            else
                local info = self.listenerInfos[instanceId]
                if info and info[instanceId][nameHash] then
                    info[instanceId][nameHash] = nil
                end
            end
        else
            self.listenerInfos[instanceId] = nil
        end
    end
end

function AnimManager:AddEffectListener(instanceId,animName,func)
    self:AddListener(instanceId,animName,AnimManager.Type.Effect,func)
end

function AnimManager:RemoveEffectListener(instanceId,animName)
    self:RemoveListener(instanceId,animName,AnimManager.Type.Effect)
end

function AnimManager:AddDelayPlayListener(instanceId,animName,func)
    self:AddListener(instanceId,animName,AnimManager.Type.DelayPlay,func)
end

function AnimManager:RemoveDelayPlayListener(instanceId,animName)
    self:RemoveListener(instanceId,animName,AnimManager.Type.DelayPlay)
end

function AnimManager:EffectPlay(instanceId,nameHash,data)
    local listener = self.listenerInfos[instanceId]
    local tpe = AnimManager.Type.Effect
    if listener and listener[nameHash] and listener[nameHash][tpe] then
        local info = listener[nameHash][tpe]

        local args = {}
        args.effectId = tonumber(data.effectId)
        args.nodePath = data.path
        args.beginTime = data.beginTime * 1000
        args.lastTime = data.lastTime * 1000
        args.order = data.order
        args.scale = data.scale * 1000
        args.pos = data.pos

        info.func(info.animName,args)
    end
end

function AnimManager:DelayAnimPlay(instanceId,nameHash,eventId,animName)
    local listener = self.listenerInfos[instanceId]
    local tpe = AnimManager.Type.DelayPlay
    if listener and listener[nameHash] and listener[nameHash][tpe] then
        local info = listener[nameHash][tpe]

        local args = {}
        args.eventId = eventId
        args.animName = animName

        info.func(args)
    end
end