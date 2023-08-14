RoleProxy = BaseClass("RoleProxy",Proxy)

function RoleProxy:__Init()
    self.roles = {}
    self.roleData = {}
	self.roleDetailData = {}
end

function RoleProxy:__InitProxy()
    self:BindMsg(10100)
	self:BindMsg(10101)
	self:BindMsg(10102)
	self:BindMsg(10107)
	self:BindMsg(10111)
end

-- 初始化角色数据
function RoleProxy:InitRoleBaseData(data)
	self:UpdateRoleData(data)
end

function RoleProxy:GetRoleData()
	return self.roleData
end

function RoleProxy:GetRoleFullData()
	return {
		role_base_info = self.roleData,
		role_detail_info = self.roleDetailData
	}
end

-- 登陆或者断线重连请求角色数据
function RoleProxy:ReqRoleData()
	mod.RoleFacade:SendMsg(10100)
end

function RoleProxy:Recv_10101(data)
	LogTable("接收10101",data)
	if mod.ReconnectCtrl.reconnetFlag then
        mod.ReconnectCtrl.reconnetFlag = false
		EventManager.Instance:SendEvent(EventDefine.reconnet_init_data_complete)
	else
		EventManager.Instance:SendEvent(EventDefine.init_data_complete)
    end
end

function RoleProxy:Recv_10102(data)
	LogTable("接收10102",data)
	self:InitRoleBaseData(data.role_base_info)
	self.roleDetailData = data.role_detail_info
end

function RoleProxy:Send_10107()
	LogTable("发送10107")
	return nil
end

function RoleProxy:Recv_10107(data)
	LogTable("接收10107",data)
	Network.Instance:SetRemoteTime(data.time)
end

---玩家数据变化(增加)
---@param data table key:GDefine.RoleInfoType  val:对应的值
function RoleProxy:Recv_10111(data)
	LogTable("接收10111",data)
	self:OnRoleInfoUpdate(data.ii_list)
end

function RoleProxy:OnRoleInfoUpdate(list)
	local changeInfos = {}
	local updateKvData = {}
	for i,v in ipairs(list) do
		local name = GDefine.RoleInfoName[v.key]
		updateKvData[name] = v.val
		local lastVal = self.roleData[name] or 0
		changeInfos[name] = {lastVal = lastVal,newVal = updateKvData[name],difVal = updateKvData[name] - lastVal}
	end

	LogTable("修改角色数据",changeInfos)

	self:UpdateRoleData(updateKvData)
	EventManager.Instance:SendEvent(EventDefine.update_role_info,changeInfos)
end

function RoleProxy:UpdateRoleData(kvData)
	for k,v in pairs(kvData) do
		self.roleData[k] = v
	end
end