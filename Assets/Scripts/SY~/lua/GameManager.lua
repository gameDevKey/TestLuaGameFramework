GameManager = SingleClass("GameManager")

function GameManager:__Init()
end

function GameManager:__Delete()

end

function GameManager:InitClass()
    DevicesFpsManager.New()
    DevicesManager.New()

    DashboardManager.New()

    BitUtils.Init()
    EventManager.New()
    AssetLoaderProxy.New()

    Network.InitGpbParser()

    local connType = nil
    if GDefine.platform == GDefine.PlatformType.WebGLPlayer then
        connType = NetworkDefine.ConnType.web
    else
        connType = NetworkDefine.ConnType.tcp
    end
    Network.Instance = Network.New(connType)
    Network.Instance:SetTick(1199,30,10)

    
    
    TouchManager.New()
    PoolManager.New()
    ViewManager.New()
    TimerManager.New()
    PreloadManager.New()
    ShaderManager.New()
    AudioManager.New()
    AnimManager.New()
end

function GameManager:ModuleSetup()
    for k,_ in pairs(ModuleMapping) do
        local facadeClass = GetClass(k)
        if facadeClass then
            local _ = facadeClass.New(facadeClass)
        else
            LogErrorf("无法找到模块入口[%s]",module)
        end
    end
    Facade.InitComplete()
end

function GameManager:Start()
    self:InitClass()

    self:InitSDK()
    self:ModuleSetup()

    EventManager.Instance:AddEvent(EventDefine.delay_preload_complete,self:ToFunc("DelayPreloadComplete"))

    TransitionButton.SetSoundFunc(AudioManager.Instance,"OnPlayButtonClick")
    AEEffectBehaviour.SetAnimEffectFunc(AnimManager.Instance,"OnEffectPlay")
    AEDelayChildPlayAnimBehaviour.SetAnimPlayFunc(AnimManager.Instance,"OnDelayAnimPlay")

    PreloadManager.Instance:SetComplete(self:ToFunc("OnPreloadComplete"))
    PreloadManager.Instance:Load()

    Application.targetFrameRate = 60

    local cameraData = UIDefine.uiCamera.gameObject:GetComponent(Rendering.Universal.UniversalAdditionalCameraData)
    cameraData.UICamera = false --TODO 由于新手引导的遮罩摄像机渲染晚于UI摄像机，且勾选了isUiCamera后UI层级不再被渲染，未知原因，先取消勾选
end

function GameManager:OnPreloadComplete()
    TimerManager.Instance:AddTimerByNextFrame(1,0,self:ToFunc("EnterComplete"))
end

function GameManager:DelayPreloadComplete()
    if GDefine.platform == GDefine.PlatformType.WebGLPlayer then
        LuaManager.Instance.luaUpdater:CheckoutFullLuaZip()
    end
end

function GameManager:EnterComplete()
    collectgarbage("setpause", 120)
    collectgarbage("setstepmul", 2000)

    if jit then
        if jit.opt then      
            jit.opt.start(3)                
        end
        jit.off()
    end

    EventManager.Instance:SendEvent(EventDefine.preload_complete)
    StartWindow.Instance:CloseWindow()
    ViewManager.Instance:OpenWindow(LoginWindow)
end

function GameManager:Update()
    local deltaTime = Time.deltaTime
    GDefine.frameCount = Time.frameCount

    Network.Instance:Update()
    AssetLoaderProxy.Instance:Update(deltaTime)
	TimerManager.Instance:Update(deltaTime)
    TouchManager.Instance:Update(deltaTime)
    mod.BattleTickCtrl:Update()
    mod.PlayerGuideTickCtrl:Update(deltaTime)


    DevicesFpsManager.Instance:Update()
end

function GameManager:LateUpdate()
    
end

function GameManager:InitSDK()
    if BaseSetting.channel == "release" then
        BuglyAgent.ConfigDebugMode(true)
    else
        --开启SDK的日志打印，发布版本请务必关闭
        BuglyAgent.ConfigDebugMode(false)
    end
    
end

--只有退出到登录的逻辑，切勿加入各平台sdk判定
function GameManager:ExitLogin()
    if not mod.LoginProxy:IsLogin() then
        Network.Instance:Disconnect()
        return
    end

    mod.LoginProxy:SetLogin(false)
    ViewManager.Instance:CleanAllWindow()

    Network.Instance:Disconnect()
    Network.Instance:CleanHandler()
    Network.Instance:CleanResend()

    EventManager.Instance:Clean()
    TouchManager.Instance:Clean()

    Facade.CleanModules()
    self:ModuleSetup()

    if IS_EDITOR then
        for view,traceback in pairs(BaseView.debugViews) do
            Logf("退出登录,view未清理[%s][创建堆栈:%s]",view.__className,traceback)
        end
    end

    ViewManager.Instance:OpenWindow(LoginWindow)

    EventManager.Instance:SendEvent(EventDefine.preload_complete)
    if PreloadManager.Instance:IsDelayLoaded() then
        EventManager.Instance:SendEvent(EventDefine.delay_preload_complete)
    end
end


function GameManager:OnApplicationFocus(flag)
    if not flag then
        mod.BattleCtrl:CancelOperate()
        mod.CollectionCtrl:CancelOperate()
    end
    EventManager.Instance:SendEvent(EventDefine.on_app_focus,flag)
end

function GameManager:OnApplicationQuit()
    Network.Instance:Close()
end
