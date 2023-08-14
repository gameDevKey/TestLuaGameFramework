LoginProxy = BaseClass("LoginProxy",Proxy)

function LoginProxy:__Init()
    self.ip = nil
    self.port = nil
    self.account = nil
    self.isLogin = false

    self.enterData = nil

    self.serverRequest = nil

    self.serverData = nil
    self.curServer = nil

    self.userInfo = nil

    self.firstShow = true
end


--初始化，可以执行自己想要的逻辑
function LoginProxy:__InitProxy()
    self:BindMsg(1110)

    self:BindMsg(1201) --创角
    self:BindMsg(1202) --选角
    self:BindMsg(1203) --角色重连

    self:BindMsg(1199) --心跳
    
    self:BindMsg(10108) --断开连接
    
    -- self:BindMsg(1100)
    -- self:BindMsg(1110)
end

function LoginProxy:__InitComplete()

end

function LoginProxy:SetLogin(flag)
    self.isLogin = flag
    if not flag then
        mod.EnterProcessCtrl:SetFirstUnlock(true)
    end
end

function LoginProxy:IsLogin()
    return self.isLogin
end

function LoginProxy:SetServerData(data)
    self.serverData = data
end

function LoginProxy:SetCurServer(data)
    self.curServer = data
end

function LoginProxy:Send_1110(args)
    LogTable("发送1110",args)
    local data = {}
    data.args = args
    return data
end

function LoginProxy:Recv_1110(data)
    LogTable("接收1110",data)

    if data.code ~= 1 then 
        SystemMessage.Show(data.msg)
        mod.LoginFacade:SendEvent(LoginWindow.Event.ActiveUserPanel,true)
        Network.Instance:Disconnect()
        return
    end

    Network.Instance:StartTick()

	-- 如果是在游戏中，则请求角色信息,否侧判断是否有角色，没有角色，则打开创角界面，否则使用第一个角色进入游戏
	local roleData = mod.RoleProxy:GetRoleData()
	if roleData.role_id then
        mod.LoginFacade:SendMsg(1203,roleData.role_id, roleData.server_id)
	else
		self.enterData = data
		self:RequestLoginByGameInit()
	end
end

-- 处理登陆
function LoginProxy:RequestLoginByGameInit()
	if not self.enterData or not self.enterData.roles then
        self:Request1110Role()
        return
    end

    local role_list = self.enterData.roles
    if not next(role_list) then
        mod.LoginCtrl:DoCreateRole(mod.LoginProxy.userInfo.account,1,1)
    else
        local firstData = self.enterData.roles[1] -- 取出第一个用于登陆吧
        mod.LoginFacade:SendMsg(1202, firstData.role_id, firstData.server_id)
    end
end

function LoginProxy:Send_1201(name,classes,sex)
    local data = {}
    data.name = name
    data.classes = classes
    data.sex = sex
    LogTable("发送1201",data)
    return data
end


function LoginProxy:Recv_1201(data)
    LogTable("接收1201",data)

    if data.code == 1 then
        mod.LoginFacade:SendMsg(1202, data.role_id, data.server_id)
    else
        Logf("创建角色异常[%s]",data.msg)
    end
end

function LoginProxy:Recv_10108(data)
    LogTable("接收10108",data)

    local msg = TI18N("你的角色在另一个地方登录")
    if data.code == 1 then
        local data = {}
        data.content = TI18N("你的角色在另一个地方登录")
        data.onCancel = self:ToFunc("ExitGame")
        data.onConfirm = self:ToFunc("ExitGame")
        SystemDialog.Show(data)
    elseif data.code == 2 then
        local data = {}
        data.content = TI18N("服务器进行维护")
        data.onCancel = self:ToFunc("ExitGame")
        data.onConfirm = self:ToFunc("ExitGame")
        SystemDialog.Show(data)
    end
end

--TODO:
function LoginProxy:ExitGame()
    Application.Quit()
end

function LoginProxy:Send_1202(roleId, srvId)
    local data = {}
    data.role_id = roleId
	data.server_id = srvId
    LogTable("发送1202",data)
    return data
end

function LoginProxy:Recv_1202(data)
    LogTable("接收1202",data)
    if data.code == 1 then
        mod.EnterProcessCtrl:LoginComplete()
	end
end


function LoginProxy:Send_1203(roleId, srvId)
    local data = {}
    data.role_id = roleId
	data.server_id = srvId
    LogTable("发送1203",data)
    return data
end

function LoginProxy:Recv_1203(data)
    LogTable("接收1203",data)
    if data.code == 1 then
        mod.EnterProcessCtrl:LoginComplete()
	end
end

function LoginProxy:Recv_1199(data)
    --LogTable("接收1199",data)
    -- local tb = {}
    --     local nowtTime = data.time
    --     tb.year = tonumber(os.date("%Y",nowtTime))
    --     tb.month =tonumber(os.date("%m",nowtTime))
    --     tb.day = tonumber(os.date("%d",nowtTime))
    --     tb.hour = tonumber(os.date("%H",nowtTime))
    --     tb.minute = tonumber(os.date("%M",nowtTime))
    --     tb.second = tonumber(os.date("%S",nowtTime))
    --     LogTable("da",tb)
    Network.Instance:SetRemoteTime(data.time)
end


function LoginProxy:GetServerList(zoneId)
    --通过zone_id 或其他属性进行划分
    local serverList = {}
    for i, v in ipairs(self.serverData.data.server_list) do
        if v.zone_id == zoneId then
            table.insert(serverList,v)
        end
    end
    return serverList
end

function LoginProxy:GetLastServer(lastServerKey)
    for i, v in ipairs(self.serverData.data.server_list) do
        local serverKey = string.format("%s_%s_%s",v.platform,v.zone_id,v.server_id)
        if serverKey == lastServerKey then
            return v
        end
    end
    return nil
end

function LoginProxy:SetUserInfo(userInfo)
    self.userInfo = userInfo
end