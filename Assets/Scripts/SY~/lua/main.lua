require "base/setup"

function Main()
    LogInfo("当前平台:"..tostring(Application.platform))
    LogInfof("屏幕宽:%s,高:%s", Screen.width, Screen.height)
    
    InitSetting()

    InitObject()

    Hotswap()
    
    InitClass()

    GameManager.Instance:Start()
end

function InitObject()
    GameObject.DontDestroyOnLoad(GameObject.Find("EventSystem"))

    UIDefine.canvasRoot = GameObject.Find("Canvas").transform
    GameObject.DontDestroyOnLoad(UIDefine.canvasRoot.gameObject)
    local size = UIDefine.canvasRoot.sizeDelta
    GDefine.curScreenWidth  = size.x
    GDefine.curScreenHeight = size.y


    local mixedObj = GameObject("mixed")
    mixedObj:AddComponent(RectTransform)
    mixedObj.transform:SetParent(UIDefine.canvasRoot)
    mixedObj.transform:Reset()
    mixedObj.transform:SetSizeDelata(0,0)

    local calcPosNode = GameObject("calc_pos_node")
    calcPosNode:AddComponent(RectTransform)
    calcPosNode.transform:SetParent(mixedObj.transform)
    mixedObj.transform:Reset()
    mixedObj.transform:SetSizeDelata(0,0)

    UIDefine.calcPosNode = calcPosNode.transform


	UIDefine.uiCamera = GameObject.Find("UICamera"):GetComponent(Camera)
    GameObject.DontDestroyOnLoad(UIDefine.uiCamera.gameObject)

    GDefine.mainCamera = GameObject.Find("MainCamera"):GetComponent(Camera)
    GameObject.DontDestroyOnLoad(GDefine.mainCamera.gameObject)
end

function Hotswap()
    if VersionUpdater.Instance.hotswap ~= "" then
        local hotswapContent = string.format("<----------\n%s\n---------->",VersionUpdater.Instance.hotswap)
        LogInfo("hotswap内容:\n"..hotswapContent)
        require("hotswap")
    end
end

function InitClass()
    GameManager.New()
end

function ModuleSetup(module)
    local class = GetClass(module)
    if class == nil then LogErrorf("无法找到模块入口[%s]",module) return end
	local facade =  class.New(class)
end

function Update()
    GameManager.Instance:Update()
end

function LateUpdate()
    GameManager.Instance:LateUpdate()
end

function OnApplicationFocus(flag)
    GameManager.Instance:OnApplicationFocus(flag)
end

function OnApplicationQuit()
    GameManager.Instance:OnApplicationQuit()
end

function InitPlatform()
    
end

function InitSetting()
    GDefine.luaDebug = BaseSetting.debug and BaseSetting.luaDebug

    if Application.platform == RuntimePlatform.Android then
        GDefine.platform = GDefine.PlatformType.Android
    elseif Application.platform == RuntimePlatform.IPhonePlayer then
        GDefine.platform = GDefine.PlatformType.IPhonePlayer
    elseif Application.platform == RuntimePlatform.WindowsEditor then
        GDefine.platform = GDefine.PlatformType.WindowsEditor
        IS_DEBUG = true
        IS_EDITOR = true
    elseif Application.platform == RuntimePlatform.OSXEditor then
        GDefine.platform = GDefine.PlatformType.OSXEditor
        IS_DEBUG = true
        IS_EDITOR = true
    elseif Application.platform == RuntimePlatform.OSXPlayer then
        GDefine.platform = GDefine.PlatformType.OSXPlayer
        IS_DEBUG = true
    elseif Application.platform == RuntimePlatform.WindowsPlayer then
        GDefine.platform = GDefine.PlatformType.WindowsPlayer
        IS_DEBUG = true
    elseif Application.platform == RuntimePlatform.WebGLPlayer then
        GDefine.platform = GDefine.PlatformType.WebGLPlayer
        IS_DEBUG = true
    end

    if not IS_DEBUG then
        IS_DEBUG = PlayerPrefsEx.GetInt("IS_DEBUG",0) > 0
    end

    --TODO:调试阶段，先开启
    --IS_DEBUG = true
end 