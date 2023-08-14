BaseView = BaseClass("BaseView",BaseModule)
BaseView.debugViews = {}

function BaseView:__Init()
    self.__isCreate = true
    self.__canShow = true
    self.__firstShow = true

    self.gameObject = nil
    self.active = false
    self.viewType = nil
    self.assetList = {}
    self.isDelete = false
    self.assetPath = nil
    self.iconLoaders = {}
    self.refreshParent = false
    self.extendViewList = {}
    self.animEffectListeners = nil
    self.animDelayPlayListeners = nil
    self.enableName = true
    self.effects = {}
    self.timers = {}
    self:SuperFunc("__ExtendView",true)
    self:SuperFunc("__BindBeforeEvent",true)
    self:ExecuteExtendFun("__BindBeforeEvent",true)
    if IS_EDITOR then
        BaseView.debugViews[self] = debug.traceback()
    end
end

function BaseView:__Delete()
    --最后一步，开始删除预设了
    if not self.isDelete then LogError("base_view对象禁止直接调用Delete方法! ==> 改用(Destroy)") return end
    if not BaseUtils.IsNull(self.gameObject) then GameObject.Destroy(self.gameObject) end

    for img,_ in pairs(self.iconLoaders) do
        self:RemoveSprite(img)
    end

    self:RemoveAllEffect()

    AnimManager.Instance:RemoveEffectListener(self:GetInstanceId())

    for k,v in pairs(self.timers) do
        self:RemoveTimer(k)
    end

    self:RemoveAssetLoader()
    self:RemoveBeforeEvent()
    self.gameObject = nil

    mod.PlayerGuideUINodeCtrl:RemoveUI(self.__className)

    self:CancelDebugDestroy()
    self:RemoveShowStopwatch()
    if IS_EDITOR then
        BaseView.debugViews[self] = nil
    end
end

function BaseView:DebugDestroy()
    if IS_EDITOR then
        self.debugTimer = TimerManager.Instance:AddTimer(0,3,self:ToFunc("CheckDebug")) 
    end
end

function BaseView:CheckDebug()
    if BaseUtils.IsNull(self.gameObject) then
        LogErrorf("BaseView被异常删除[%s][创建堆栈:\n%s]",tostring(self.__className),self.debug)
    end
end

function BaseView:SetEnableName(flag)
    self.enableName = flag
end

---添加定时器
function BaseView:AddTimer(key,count,time,func)
    if self.timers[key] then
        assert(false,string.format("添加定时器失败,已存在相同key的定时器[key:%s]",tostring(key)))
    end
    self.timers[key] = TimerManager.Instance:AddTimer(count,time,func)
    self.timers[key]:SetComplete(self:ToFunc("OnTimerComplete"),key)
    return self.timers[key]
end

---添加唯一定时器, 同时只会存在一个同名定时器
---@param useOld boolean 使用现有定时器还是重新创建
function BaseView:AddUniqueTimer(key,count,time,func,useOld)
    if useOld and self.timers[key] then
        return self.timers[key]
    end
    self:RemoveTimer(key)
    return self:AddTimer(key,count,time,func)
end

function BaseView:OnTimerComplete(args,id)
    self:RemoveTimer(args)
end

function BaseView:RemoveTimer(key)
    if self.timers[key] then
        TimerManager.Instance:RemoveTimer(self.timers[key])
        self.timers[key] = nil
    end
end

function BaseView:HasTimer(key)
    return self.timers[key] ~= nil
end

function BaseView:CancelDebugDestroy()
    if self.debugTimer then
        TimerManager.Instance:RemoveTimer(self.debugTimer)
        self.debugTimer = nil
    end
end

function BaseView:Destroy()
    if self.isDelete then return end
    self.isDelete = true

    self:HideCommonHandle()
    self:RemoveLastingEvent()

    self:DeleteHandle()
end

function BaseView:DeleteHandle()
    for _,view in ipairs(self.extendViewList) do
        view:Delete()
    end
    self:Delete()
end

function BaseView:HideHandle()
    self:HideCommonHandle()
    self:SetActive(self.transform,false,false)
    self:RemoveAllEffect()
    self.isHideing = false
end

function BaseView:HideCommonHandle()
    if not self.active then return end
    self.__firstShow = true
    self.active = false
    self:RemoveEvent()
    self:SuperFunc("__Hide",false)
    self:ExecuteExtendFun("__Hide",false)
end

function BaseView:SetObject(gameObject)
    self.gameObject = gameObject
    self.gameObject:AddComponent(AssetReleaser)
    self:InitObject()
end

function BaseView:SetParent(parent,x,y,z)
    self.refreshParent = true
    self.parent = parent
    self.x = x
    self.y = y
    self.z = z
    if self:IsValid() then self:RefreshParent() end
end

function BaseView:RefreshParent()
    if not self.refreshParent then 
        return 
    end
    self.refreshParent = false

    if self.parent and BaseUtils.IsNull(self.parent) then
        LogErrorf("BaseView设置的父节点已经被删除了,但是没有调用(Hide、Destroy)函数[%s]",tostring(self.__className))
        return
    end

    self.transform:SetParent(self.parent,false)
    UnityUtils.SetLocalPosition(self.transform,self.x or 0,self.y or 0,self.z or 0)
end

function BaseView:Show(args)
    self.args = args
    if not self.__canShow then 
        self.__canShow = true 
    end

    self.showStopwatch = CS.System.Diagnostics.Stopwatch()
    self.showStopwatch:Start()
    if not self:ShowObject() then
        self:LoadAsset() 
    end
end

function BaseView:Hide()
    self:RemoveShowStopwatch()
    self:__BaseHide()

    if self:LoadAsseting() then 
        self.__canShow = false 
        return 
    end

    if not self.active or self.isHideing then 
        return 
    end

    self.isHideing = true
    self:CloseComplete()
end

function BaseView:CloseComplete()
    self.isHideing = false
    self:HideHandle()
end

function BaseView:RemoveShowStopwatch()
    if self.showStopwatch then
        self.showStopwatch:Stop()
        self.showStopwatch = nil
    end
end

function BaseView:ShowObject()
    if BaseUtils.IsNull(self.gameObject) or not TableUtils.IsEmpty(self.assetList) then 
        return false 
    end

    self:__ShowComplete()

    self:FirstCreate()
    if not self.__canShow then
        self.__canShow = true
        self:SetActive(self.transform,false,false)
        return false
    end

    self:RepeatShow()
    self:FirstShow()

    if self.showStopwatch then
        self.showStopwatch:Stop()
        local runTime = self.showStopwatch.Elapsed.TotalMilliseconds
        self.showStopwatch = nil
        DashboardManager.Instance:Call(DashboardDefine.DashboardType.ui,"AddUIShowTime",self.__className,runTime)
    end

    return true
end

function BaseView:FirstCreate()
    if not self.__isCreate then
        return 
    end
    self.__isCreate = false
    self:RefreshParent()
    self:CreateAction(self)

    if self.viewType ~= UIDefine.ViewType.item then
        mod.PlayerGuideUINodeCtrl:CreateUI(self.__className,self.transform)
    end

    self:DebugDestroy()
end

function BaseView:CreateAction(view)
    view:__BaseCreate()
    self:SuperFunc("__CacheObject",true)
    self:ExecuteExtendFun("__CacheObject",true)
    self:SuperFunc("__Create",true)
    self:ExecuteExtendFun("__Create",true)
    self:SuperFunc("__BindListener",true)
    self:ExecuteExtendFun("__BindListener",true)
    self:SuperFunc("__BindLastingEvent",true)
    self:ExecuteExtendFun("__BindLastingEvent",true)
end

function BaseView:Active()
    return self.active
end

function BaseView:PushPool()
    if self.poolKey and not self:LoadAsseting() then
        PoolManager.Instance:Push(PoolType.base_view,self.poolKey,self)
    else
        self:Destroy()
    end
end

function BaseView:TablePushPool(table)
    if self[table] then
        for k, v in pairs(self[table]) do
            v:PushPool()
        end
    end
end

function BaseView:FirstShow()
    if not self.__firstShow then 
        return 
    end
    self.__firstShow = false
    self:RefreshParent()
    self.isHideing = false
    self:SetActive(self.transform,true,false)
    self:firstShowAction(self)
    self.active = true
end

function BaseView:firstShowAction(view)
    view:__BaseShow()
    self:SuperFunc("__BindEvent",true)
    self:ExecuteExtendFun("__BindEvent",true)
    self:SuperFunc("__Show",true)
    self:ExecuteExtendFun("__Show",true)
    self:SuperFunc("__LastShow",true)
end

function BaseView:RepeatShow()
    if self.__firstShow then 
        return 
    end
    self:SuperFunc("__RepeatShow",true)
    self:ExecuteExtendFun("__RepeatShow",true)
end

function BaseView:LoadAsset()
    if self:LoadAsseting() then 
        return 
    end
    
    if not self.assetPath and not self.gameObject then
        assert(false, "UI资源路径为空,请调用SetAsset接口设置")
    elseif self.assetPath then
        table.insert(self.assetList,{file = self.assetPath, type = AssetType.Prefab})
    end

    if not self.assetList or #self.assetList<=0 then 
        self:AssetLoaded()
    else
        self.assetLoader = AssetBatchLoader.New()
        self.assetLoader:Load(self.assetList,self:ToFunc("AssetLoaded"))
    end
end

function BaseView:AssetLoaded()
    self.assetList = nil
    self.gameObject = self.gameObject or self:GetAsset(self.assetPath)
    self:InitObject()
    self:InitAnim()

    self:ShowObject()
    self:RemoveAssetLoader()
end

function BaseView:InitAnim()
    if self.animator and self.animFile then
        self.animator.runtimeAnimatorController = self:GetAsset(self.animFile)
        AssetLoaderProxy.Instance:AddReference(self.animFile)
        self.autoReleaser:Add(self.animFile)
    end
end

function BaseView:InitObject()
    self.autoReleaser = self.gameObject:GetComponent(AssetReleaser)
    if self.enableName then self.gameObject.name = self.__className end
    
    self.instanceId = self.gameObject:GetInstanceID()
    self.transform = self.gameObject.transform
    self.rectTrans = self.gameObject:GetComponent(RectTransform)
    self.animator = self.gameObject:GetComponent(Animator)
    self.rootCanvas = self:Find(nil,Canvas)
end

function BaseView:SetAnim(animFile,anim)
    if self.animator and anim then
        self.animator.runtimeAnimatorController = anim
        AssetLoaderProxy.Instance:AddReference(animFile)
        self.autoReleaser:Remove(animFile)
        self.autoReleaser:Add(animFile)
    end
end

function BaseView:GetInstanceId()
    return self.instanceId
end

function BaseView:PlayAnim(animName,layer,callback,args)
    if self.animator then
        self.animator:Play(animName,layer or -1,0)
        if callback then
            local time = BaseUtils.GetAnimatorClipTime(self.animator,animName)
            local timer = self:AddUniqueTimer("PlayAnim_"..animName,1,time,callback,false)
            if args then
                timer:SetArgs(args)
            end
        end
    end
end

function BaseView:GetAsset(file,parent,instantiateInWorldSpace)
    if self.assetLoader then
        return self.assetLoader:GetAsset(file,parent,instantiateInWorldSpace)
    end
end

function BaseView:RemoveAssetLoader()
    if self.assetLoader then
        self.assetLoader:Destroy()
        self.assetLoader = nil
    end
end

function BaseView:SetViewType(viewType)
    self.viewType = viewType
end

function BaseView:SetAsset(file)
    if self.assetPath then
        assert(false, "禁止多次设置UI资源路径")
    end
    
    self.assetPath = file

    local fileFolder = IOUtils.GetPathDirectory(file,false)
    local fileName = IOUtils.GetFileName(fileFolder) .. "/" .. IOUtils.GetFileName(file)
    local animFile = "anim/ui/" .. fileName .. ".controller"
    if AssetLoaderProxy.Instance:HasAsset(animFile) then
        self.animFile = animFile
        self:AddAsset(self.animFile,AssetType.Object)
    end
end

function BaseView:AddAsset(file,assetType)
    table.insert(self.assetList,{file = file, type = assetType})
end

function BaseView:SetAnimAsset(animFile)
    self.animFile = animFile
    self:AddAsset(self.animFile,AssetType.Object)
end

function BaseView:Find(path,component,transform)
    if not transform then transform = self.transform end
    if path then transform = transform:Find(path) end
    if not transform then return nil end
    return component and transform:GetComponent(component) or transform
end

function BaseView:SetSprite(image,path,nativeSize,callBack)
    if string.byte(path,4) == 116 then
        if self.iconLoaders[image] then
            assert(false, string.format("设置图集图片异常,Image被设置为Icon图片[%s](解决方案:先调用RemoveSprite接口移除)",path))
        end

        local sprite = AssetLoaderProxy.Instance:GetObject(path,AssetType.Sprite)
        if not sprite then
            LogErrorf("设置图集图片异常,不存在资源[%s](解决方案:检查路径的资源是否存在)",path)
        else
            image.sprite = sprite
            if nativeSize then image:SetNativeSize() end
        end
    else
        local iconLoader = self.iconLoaders[image] or IconLoader.Create()
        self.iconLoaders[image] = iconLoader
        iconLoader:LoadIcon(image,path,nativeSize,callBack)
    end
end

function BaseView:RemoveSprite(image)
    if self.iconLoaders[image] then
        self.iconLoaders[image]:Delete()
        self.iconLoaders[image] = nil
    end
end

function BaseView:SetActive(transform,active)
    BaseUtils.SetActive(transform,active)
end

function BaseView:LoadAsseting()
    return not BaseUtils.IsNull(self.assetLoader) and self.assetLoader.isLoading
end

function BaseView:ExtendView(view)
    if not view then
        assert(false,"扩展类不存在")
    end

    local extendView = view.New(self)

    if extendView.module ~= self.module then
        assert(false,string.format("扩展类所属模块不一致[%s]",tostring(view.__className)))
    end
    
    table.insert(self.extendViewList,extendView)
    return extendView
end

function BaseView:ExecuteExtendFun(fn,flag)
    for _,view in ipairs(self.extendViewList) do
        view:SuperFunc(fn,flag)
    end
end

function BaseView:Create()
    if not self.__isCreate or self:LoadAsseting() then 
        return 
    end

    if not BaseUtils.IsNull(self.gameObject) then
        return
    end

    self.__canShow = false
    self:LoadAsset()
end

function BaseView:SetTopLayer(canvas)
    canvas.sortingOrder = ViewManager.Instance:GetMaxOrderLayer()
end

function BaseView:SetOrder()
    if self.rootCanvas then
        self.rootCanvas.sortingOrder = ViewDefine.Layer[self.__className] or 0
    end
end

function BaseView:GetOrder()
    if not self.rootCanvas then
        return 0
    end
    return self.rootCanvas.sortingOrder
end

function BaseView:BindEvent(event,extendView)
    local view = extendView or self
    self:CheckEvent(event,view)
    local func = view:ToFunc(event.value)
    self.module:BindEvent(event,func)
    if not self.events then self.events = {} end
    table.insert(self.events,{event = event,func = func})
end

function BaseView:BindLastingEvent(event,extendView)
    local view = extendView or self
    self:CheckEvent(event,view)
    local func = view:ToFunc(event.value)
    self.module:BindEvent(event,func)
    if not self.lastingEvents then self.lastingEvents = {} end
    table.insert(self.lastingEvents,{event = event,func = func})
end

function BaseView:BindBeforeEvent(event,extendView)
    local view = extendView or self
    self:CheckEvent(event,view)
    local func = view:ToFunc(event.value)
    self.module:BindEvent(event,func)
    if not self.beforeEvents then self.beforeEvents = {} end
    table.insert(self.beforeEvents,{event = event,func = func})
end

function BaseView:AddAnimEffectListener(animName,func)
    if not self.animEffectListeners then self.animEffectListeners = {} end
    AnimManager.Instance:AddEffectListener(self:GetInstanceId(),animName,func)
    self.animEffectListeners[animName] = func
end

function BaseView:RemoveAnimEffectListener(animName)
    if self.animEffectListeners and self.animEffectListeners[animName] then
        AnimManager.Instance:RemoveEffectListener(self:GetInstanceId(),animName)
    end
end

function BaseView:AddAnimDelayPlayListener(animName,func)
    if not self.animDelayPlayListeners then self.animDelayPlayListeners = {} end
    AnimManager.Instance:AddDelayPlayListener(self:GetInstanceId(),animName,func)
    self.animDelayPlayListeners[animName] = func
end

function BaseView:RemoveAnimDelayPlayListener(animName)
    if self.animDelayPlayListeners and self.animDelayPlayListeners[animName] then
        AnimManager.Instance:RemoveDelayPlayListener(self:GetInstanceId(),animName)
    end
end

function BaseView:AddEffect(effect)
    self.effects[effect.uid] = effect
end

function BaseView:AddUniqueEffect(effect)
    for uid, eff in pairs(self.effects) do
        if effect.assetId == eff.assetId then
            self:RemoveEffect(uid)
        end
    end
    self:AddEffect(effect)
end

---加载UI特效
---@param setting table 设置
---@param unique boolean true代表相同ID的特效只能存在一个
---@return table UIEffect
function BaseView:LoadUIEffect(setting,unique)
    local effect = UIEffect.New()
    effect:Init(setting)
    effect:Play()
    if unique then
        self:AddUniqueEffect(effect)
    else
        self:AddEffect(effect)
    end
    return effect
end

---加载UI特效
---@param data table 详见AnimManager:EffectPlay()
---@param unique boolean 是否允许加载多个相同ID的特效
---@return table UIEffect
function BaseView:LoadUIEffectByAnimData(data,unique)
    local effectId = data.effectId
    local nodePath = data.nodePath
    local order = self:GetOrder() + GDefine.EffectOrderAdd + data.order
    local node = self:Find(nodePath)
    if not node then
        LogErrorAny("界面",self.__className,"找不到特效",effectId,'的挂载点,路径:',nodePath)
    end
    local effect = self:LoadUIEffect({
        confId = data.effectId,
        delayTime = data.beginTime,
        lastTime = data.lastTime,
        scale = data.scale,
        pos = data.pos,
        parent = node,
        order = order,
    },unique)
    return effect
end

function BaseView:RemoveEffect(uid)
    if self.effects[uid] then
        self.effects[uid]:Delete()
        self.effects[uid]= nil
    end
end

function BaseView:RemoveAllEffect()
    for uid,_ in pairs(self.effects or {}) do
        self:RemoveEffect(uid)
    end
    self.effects = {}
end

local debugEvents = {}
function BaseView:CheckEvent(event,view)
    if not self.module then
        assert(false, "BaseView添加事件失败[error:当前类缺失所属模块]")
    end
    
    if not event then
        assert(false, "BaseView添加事件失败[error:传入了空的事件]")
    end
    
    if not event._enum then
        assert(false, "BaseView添加事件失败[error:传入的不是事件]")
    end

    if not debugEvents[event.value] then
        debugEvents[event.value] = event.id
    elseif debugEvents[event.value] ~= event.id then
        assert(false,string.format("同一模块重复定义了相同事件[模块:%s][事件:%s]",self.module.__className,event.value))
    end

    if (not view.Event or event ~= view.Event[event.value]) 
        and (not self.module.Event or event ~= self.module.Event[event.value]) then
        assert(false, "禁止传入其它模块的事件")
    end

    if not view[event.value] then
        assert(false, string.format("BaseView添加事件失败[error:未实现事件回调函数(%s)]",event.value))
    end
end

function BaseView:RemoveEvent()
    if not self.module or not self.events or #self.events<=0 then return end
    for i,v in ipairs(self.events) do self.module:RemoveEvent(v.event,v.func) end
    self.events = nil
end

function BaseView:RemoveLastingEvent()
    if not self.module or not self.lastingEvents or #self.lastingEvents<=0 then return end
    for i,v in ipairs(self.lastingEvents) do self.module:RemoveEvent(v.event,v.func) end
    self.lastingEvents = nil
end

function BaseView:RemoveBeforeEvent()
    if not self.module or not self.beforeEvents or #self.beforeEvents<=0 then return end
    for i,v in ipairs(self.beforeEvents) do self.module:RemoveEvent(v.event,v.func) end
    self.beforeEvents = nil
end

function BaseView:IsValid()
    return self.gameObject ~= nil
end

function BaseView:__ExtendView() end
function BaseView:__CacheObject() end
function BaseView:__Create() end
function BaseView:__BindListener() end
function BaseView:__BindBeforeEvent() end
function BaseView:__BindEvent() end
function BaseView:__BindLastingEvent() end
function BaseView:__Show(args) end
function BaseView:__LastShow(args) end
function BaseView:__RepeatShow(args) end
function BaseView:__Hide() end

function BaseView:__BaseCreate() end
function BaseView:__BaseShow() end
function BaseView:__ShowComplete()end
function BaseView:__BaseHide() end