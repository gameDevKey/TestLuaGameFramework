LoginWindow = BaseClass("LoginWindow",BaseWindow)

LoginWindow.Event = EventEnum.New(
	"ServerListLoaded",
    "ActiveUserPanel"
)

function LoginWindow:__Init()
    self:SetAsset("ui/prefab/login/login_window.prefab",AssetType.Prefab)
    self.isLogined = false
    self.firstClickServer = true
end

function LoginWindow:__Delete()
end

function LoginWindow:__ExtendView()
	self.serverListView = self:ExtendView(ServerListView)
end

function LoginWindow:__CacheObject()
    self.curZoneName = self:Find("EnterPanel/ZoneCon/TxtCurZoneName",Text)
    self.serverListPanel = self:Find("server_list_panel").gameObject
    self.userPanel = self:Find("user_panel").gameObject
    self.accountInput = self:Find("user_panel/main/account_input",InputField)
    self.passwordInput = self:Find("user_panel/main/password_input",InputField)
    self.versionText = self:Find("Version/VerionText",Text)
end

function LoginWindow:__BindListener()
    self:Find("EnterPanel/BtnEnterGame",Button):SetClick( self:ToFunc("OnEnterClick") )

    self:Find("EnterPanel/ZoneCon",Button):SetClick( self:ToFunc("ServerListClick") )
    self:Find("server_list_panel/Panel",Button):SetClick( self:ToFunc("ServerListCloseClick") )
    self:Find("server_list_panel/Main/BtnClose",Button):SetClick( self:ToFunc("ServerListCloseClick") )


    self:Find("user_panel/main/login_btn",Button):SetClick( self:ToFunc("LoginClick") )
    self:Find("user_panel/main/create_btn",Button):SetClick( self:ToFunc("RegistAccountClick") )
    
    --self:Find("test_btn",Button):SetClick( self:ToFunc("TestClick") )
    --self:Find("test_btn2",Button):SetClick( self:ToFunc("TestClick2") )
end

function LoginWindow:__BindEvent()
    self:BindEvent(LoginWindow.Event.ServerListLoaded)
    self:BindEvent(LoginWindow.Event.ActiveUserPanel)
end

function LoginWindow:__Create()
    mod.LoginProxy.serverRequest = HttpRequest()
   -- mod.LoginCtrl:ServerListRequest()
    self.curZoneName.text = TI18N("loading...")

    if BaseSetting.checkUpdate then
        local resVersion = VersionUpdater.Instance.assetsVersion
        resVersion = string.sub(tostring(resVersion), string.len(tostring(resVersion)) - 5, string.len(tostring(resVersion)))

        local appVersion = tostring(BaseSetting.appVersion)
        local csVersion = tostring(BaseSetting.csVersion)

        self.versionText.text = TI18N(string.format("版本号：%s.%s.%s",appVersion,csVersion,resVersion))
    else
        self.versionText.text = TI18N("版本号：local")
    end

    
end

function LoginWindow:__Show()
    -- mod.BattlePreLoadCtrl:StartLoad()
    self.userPanel:SetActive(true)

    local lastAccount = self:GetPlayerPrefs("last_account")
    local lastPassword = self:GetPlayerPrefs("last_password")

    if GDefine.platform == GDefine.PlatformType.Android 
        or GDefine.platform == GDefine.PlatformType.WebGLPlayer then
        self.accountInput.text = lastAccount
        if lastAccount ~= "" then
            self.passwordInput.text = lastPassword
        end
    else
        self.accountInput.text = lastAccount == "" and self:GetRandomUid() or lastAccount
        self.passwordInput.text = lastPassword == "" and self:GetRandomUid() or lastPassword
    end

    if mod.LoginProxy.firstShow then
        mod.LoginProxy.firstShow = false
        EventManager.Instance:SendEvent(EventDefine.enter_login)
    end
end

function LoginWindow:ActiveUserPanel(flag)
    self.userPanel:SetActive(flag)
end

function LoginWindow:OnEnterClick()
    Log("点击进入游戏")

    if not PreloadManager.Instance:IsDelayLoaded() then
        --TODO:加个转圈效果
        return
    elseif not mod.LoginProxy.curServer then
        SystemMessage.Show("正在请求服务器列表")
    else
        mod.LoginCtrl:EnterGame()
    end


    
    --mod.BattleCtrl:EnterBattle({})
end

function LoginWindow:ServerListClick()
    if not mod.LoginProxy.curServer then
        SystemMessage.Show("正在请求服务器列表")
        return
    end

    if GDefine.platform == GDefine.PlatformType.Android or GDefine.platform == GDefine.PlatformType.IPhonePlayer then
        return
    end

    if self.firstClickServer then
        self.firstClickServer = false
        self.serverListView:RefreshServer()
    end
    self.serverListPanel:SetActive(true)
end

function LoginWindow:ServerListCloseClick()
    self.serverListPanel:SetActive(false)
end

function LoginWindow:ServerListLoaded()
    local serverData = mod.LoginProxy.serverData.data

    local lastServerKey = self:GetPlayerPrefs("last_server")
    local lastServer = mod.LoginProxy:GetLastServer(lastServerKey)

    local curServer = nil
    if lastServer then
        curServer = lastServer
    elseif serverData.default_zone and next(serverData.default_zone) then
        curServer = serverData.default_zone
    elseif serverData.server_list[1] then
        curServer = serverData.server_list[1]
    end

    if curServer then
        mod.LoginProxy:SetCurServer(curServer)
        self:RefreshCurZone()
    end
end

function LoginWindow:RefreshCurZone()
    local curServer = mod.LoginProxy.curServer
    self.curZoneName.text = curServer.name
end

function LoginWindow:GetRandomUid()
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local function randomUid(str)	
        local result = str
        local a = string.char(math.random(65, 90))
        local b = string.char(math.random(97, 122))
        local c = string.char(math.random(48, 57))
        if math.random(3) % 3 == 0 then
            result = result .. a
        elseif math.random(3) % 2 == 0 then
            result = result .. b
        else
            result = result .. c
        end
        if StringUtils.GetStrLen(result) < 6 then
            result = randomUid(result)
        end
        return result
    end
    return randomUid("")
end


function LoginWindow:LoginClick()
    self:BeginRequestServer()
end

function LoginWindow:RegistAccountClick()
    if GDefine.platform == GDefine.PlatformType.Android 
        or GDefine.platform == GDefine.PlatformType.WebGLPlayer then
        self.accountInput.text = self:GetRandomUid()
        self.passwordInput.text = ""
    else
        self.accountInput.text = self:GetRandomUid()
        self.passwordInput.text = self:GetRandomUid()
        self:BeginRequestServer()
    end
end

function LoginWindow:SavePlayerPrefs(key, val)
    --local origin = WWW.EscapeURL(tostring(val))
    PlayerPrefsEx.SetString(key, val)
end

function LoginWindow:GetPlayerPrefs(key)
    local str = PlayerPrefsEx.GetString(key)
    return str
   -- return WWW.UnEscapeURL(str)
end

function LoginWindow:SwitchServer(info)
    self.serverListPanel:SetActive(false)
    mod.LoginProxy:SetCurServer(info)
    self:RefreshCurZone()

    local serverKey = string.format("%s_%s_%s",info.platform,info.zone_id,info.server_id)
    self:SavePlayerPrefs("last_server",serverKey)
end



-- 测试环境下面的请求注册服
function LoginWindow:BeginRequestServer()
    local account = self.accountInput.text
    local password = self.passwordInput.text
    if account == "" or password == "" then
        SystemMessage.Show("请输入账号和密码")
        return
    end

    if GDefine.platform == GDefine.PlatformType.WebGLPlayer then
        password = "fh2022"
    end

    self:SavePlayerPrefs("last_account", account)
    self:SavePlayerPrefs("last_password", password)
    self.userPanel:SetActive(false)

    mod.LoginProxy:SetUserInfo({account = account, password = password})
    mod.LoginCtrl:ServerListRequest()
end

function LoginWindow:TestClick()
    --PuretsManager.Instance:StartMain()

    --BasicTest.Test()
    --FixPointTest.Test()
    BattleTest.Test(false)
end

function LoginWindow:TestClick2()
    --PuretsManager.Instance:StartMain()

    --BasicTest.Test()
    --FixPointTest.Test()
    BattleTest.Test(true)
end