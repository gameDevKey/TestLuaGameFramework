SettingProxy = BaseClass("SettingProxy",Proxy)

function SettingProxy:__Init()
    self.deviceSetters = {}
    self.roleSetters = {}

    self:InitDeviceSetting()
end

function SettingProxy:__InitProxy()

end

function SettingProxy:InitDeviceSetting()
    local keyPrefix = "FH_DEVICE_SETTING_"
    for k,v in pairs(SettingDefine.DeviceSetterType) do
        local info = SettingDefine.SetterInfo[v]
        if not info then
            assert(false,string.format("未定义信息的设备设置器[设置器类型:%s]",info))
        end

        local class  = _G[info.class]
        if not class then
            assert(false,string.format("未实现的设备设置器[设置器类型:%s][设置器实现类:%s]",v,tostring(info.class)))
        end

        local setter = class.New()
        setter:Init(keyPrefix .. info.key)
        setter:Load()
        self.deviceSetters[v] = setter
    end
end

function SettingProxy:InitRoleSetting()
    local roleData = mod.RoleProxy.roleData
    local keyPrefix = string.format("FH_ROLE_SETTING_(%s)_",roleData.role_uid)
    for k,v in pairs(SettingDefine.RoleSetterType) do
        local info = SettingDefine.SetterInfo[v]
        if not info then
            assert(false,string.format("未定义信息的角色设置器[设置器类型:%s]",info))
        end

        local class  = _G[info.class]
        if not class then
            assert(false,string.format("未实现的角色设置器[设置器类型:%s][设置器实现类:%s]",v,tostring(info.class)))
        end

        local setter = class.New()
        setter:Init(keyPrefix .. info.key)
        setter:Load()
        self.roleSetters[v] = setter
    end
end

function SettingProxy:SetVal(t,val)
    local setter = self.deviceSetters[t] or self.roleSetters[t]
    setter:OnSetVal(val)
end

function SettingProxy:GetVal(t)
    local setter = self.deviceSetters[t] or self.roleSetters[t]
    return setter:OnGetVal()
end

function SettingProxy:Apply(t)
    local setter = self.deviceSetters[t] or self.roleSetters[t]
    return setter:Apply()
end