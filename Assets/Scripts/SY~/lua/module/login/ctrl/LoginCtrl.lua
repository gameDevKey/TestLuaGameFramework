LoginCtrl = BaseClass("LoginCtrl",Controller)

function LoginCtrl:__Init()

end

function LoginCtrl:__Delete()

end

function LoginCtrl:__InitComplete()
    Network.Instance:SetEvent(ConnEvent.connected,self:ToFunc("OnConnected"))
    Network.Instance:SetEvent(ConnEvent.connect_fail,self:ToFunc("OnConnectFail"))
    Network.Instance:SetEvent(ConnEvent.disconnect,self:ToFunc("ConnectDisconnect"))
end

function LoginCtrl:EnterGame()
    --mod.SceneEnterCtrl:EnterScene({})
    -- ViewManager.Instance:CloseWindow(LoginWindow)
    -- mod.MainFacade:SendEvent(MainPanel.Event.MainActive,true)
    -- do return end

    local host,port = nil,nil
    if GDefine.platform == GDefine.PlatformType.WebGLPlayer then
        host = string.format("wss://%s%s",mod.LoginProxy.curServer.host,mod.LoginProxy.curServer.path)
        port = ""
    else
        host = mod.LoginProxy.curServer.host
        port = mod.LoginProxy.curServer.port
    end
    

    mod.LoginProxy.ip = host
    mod.LoginProxy.port = port

    Network.Instance:Connect(mod.LoginProxy.ip, mod.LoginProxy.port)
end

function LoginCtrl:OnConnected()
    Log("连接成功了")

    -- local protocal = {
	-- 	{key = "account", val = mod.LoginProxy.userInfo.account},
	-- 	{key = "password", val = mod.LoginProxy.userInfo.password},
	-- 	{key = "channel", val = mod.LoginProxy.curServer.platform},
	-- }
    mod.LoginFacade:SendMsg(1110,{ account = mod.LoginProxy.userInfo.account,password = mod.LoginProxy.userInfo.password,channel = mod.LoginProxy.curServer.platform})
    --self:SendMsg(1010)
end

function LoginCtrl:OnConnectFail()
    --if mod.ReconnectCtrl:IsReconneting() then return end
    SystemMessage.Show(TI18N("暂时无法连接服务器，请稍后再试~"))
end

function LoginCtrl:ConnectDisconnect()
    -- TimerManager.Instance:AddTimer(0,3,function()
    --     SystemMessage.Show("网络断开连接,暂未处理重连,请重启游戏~")
    -- end)
end

--创角
function LoginCtrl:DoCreateRole(roleName,classes,sex)
	sex = sex or 0
	classes = classes or 1
	mod.LoginFacade:SendMsg(1201, roleName,classes,sex)
end


function LoginCtrl:ServerListRequest()
    local serverRequest = mod.LoginProxy.serverRequest

    local url = "http://192.168.6.68/api/servers.php"
	if GDefine.platform == GDefine.PlatformType.Android 
        or GDefine.platform == GDefine.PlatformType.IPhonePlayer then
        url = "https://s1-release-xdqdh5.shiyuegame.com/servers_release.php"
    elseif GDefine.platform == GDefine.PlatformType.WebGLPlayer then
        url = "https://s1-release-xdqdh5.shiyuegame.com/servers_release_ws.php"
	end
    serverRequest.url = url
    serverRequest.onComplete = self:ToFunc("ServerListComplete")
    serverRequest.onFail = self:ToFunc("ServerListFail")
    serverRequest:Request()
end

function LoginCtrl:ServerListComplete(request)
    Log("服务器列表请求完成")

    local serverData = load(string.format("return %s", request.downloadResult.text))()
    mod.LoginProxy:SetServerData(serverData)
    mod.LoginFacade:SendEvent(LoginWindow.Event.ServerListLoaded)
    LogTable("服务器列表",serverData)
end

function LoginCtrl:ServerListFail(request,error)
    LogInfof("服务器列表请求失败[error:%s]",error)
    mod.LoginProxy.serverRequest:Request()
end


function LoginCtrl:ReturnLogin()
end
