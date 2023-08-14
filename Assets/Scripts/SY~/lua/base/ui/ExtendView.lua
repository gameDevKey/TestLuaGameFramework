ExtendView = BaseClass("ExtendView",BaseModule)
ExtendView._extendView = true

function ExtendView:__Init(mainView)
    self.MainView = mainView
end

function ExtendView:__Delete()

end

function ExtendView:SetSprite(image,path,nativeSize,callBack)
    self.MainView:SetSprite(image,path,nativeSize,callBack)
end

function ExtendView:RemoveSprite(image)
    self.MainView:RemoveSprite(image)
end

function ExtendView:Active()
    return self.MainView:Active()
end

function ExtendView:Find(path,component,transform)
    return self.MainView:Find(path,component,transform)
end

function ExtendView:GetAsset(file,parent,instantiateInWorldSpace)
    return self.MainView:GetAsset(file,parent,instantiateInWorldSpace)
end

function ExtendView:GetListener()
    return self.MainView:GetListener()
end

function ExtendView:PlayAnim(...)
    self.MainView:PlayAnim(...)
end

function ExtendView:GetInstanceId()
    return self.MainView:GetInstanceId()
end

function ExtendView:BindEvent(event)
    self.MainView:BindEvent(event,self)
end

function ExtendView:BindLastingEvent(event)
    self.MainView:BindLastingEvent(event,self)
end

function ExtendView:BindBeforeEvent(event)
    self.MainView:BindBeforeEvent(event,self)
end

function ExtendView:SetTopLayer(canvas)
    self.MainView:SetTopLayer(canvas)
end

function ExtendView:SetActive(transform,active,isScale,x,y,z)
    BaseUtils.SetActive(transform,active,isScale,x,y,z)
end

function ExtendView:GetOrder()
    return self.MainView:GetOrder()
end

function ExtendView:AddEffect(effect)
    self.MainView:AddEffect(effect)
end

function ExtendView:AddUniqueEffect(effect)
    self.MainView:AddUniqueEffect(effect)
end

function ExtendView:LoadUIEffect(setting,unique)
    return self.MainView:LoadUIEffect(setting,unique)
end

function ExtendView:LoadUIEffectByAnimData(data,unique)
    return self.MainView:LoadUIEffectByAnimData(data,unique)
end

function ExtendView:RemoveEffect(uid)
    self.MainView:RemoveEffect(uid)
end

function ExtendView:RemoveAllEffect()
    self.MainView:RemoveAllEffect()
end

function ExtendView:AddAnimEffectListener(animName,func)
    self.MainView:AddAnimEffectListener(animName,func)
end

function ExtendView:RemoveAnimEffectListener(animName)
    self.MainView:RemoveAnimEffectListener(animName)
end

function ExtendView:AddAnimDelayPlayListener(animName,func)
    self.MainView:AddAnimDelayPlayListener(animName,func)
end

function ExtendView:RemoveAnimDelayPlayListener(animName)
    self.MainView:RemoveAnimDelayPlayListener(animName)
end

function ExtendView:AddTimer(key,count,time,func)
    return self.MainView:AddTimer(key,count,time,func)
end

function ExtendView:AddUniqueTimer(key,count,time,func,useOld)
    return self.MainView:AddUniqueTimer(key,count,time,func,useOld)
end

function ExtendView:RemoveTimer(key)
    self.MainView:RemoveTimer(key)
end

function ExtendView:HasTimer(key)
    return self.MainView:HasTimer(key)
end

function ExtendView:__CacheObject() end
function ExtendView:__Create() end
function ExtendView:__Show(args) end
function ExtendView:__RepeatShow(args) end
function ExtendView:__BindBeforeEvent() end
function ExtendView:__BindEvent() end
function ExtendView:__BindLastingEvent() end
function ExtendView:__BindListener() end
function ExtendView:__Hide() end