OpenFuncCtrl = BaseClass("OpenFuncCtrl",Controller)

function OpenFuncCtrl:__Init()
end

function OpenFuncCtrl:__Delete()
end

function OpenFuncCtrl:__InitComplete()
    --监听回到主界面打开新功能开启界面
    EventManager.Instance:AddEvent(EventDefine.init_data_complete,self:ToFunc("InitDataComplete"))
    EventManager.Instance:AddEvent(EventDefine.reconnet_init_data_complete,self:ToFunc("CheckUnOpenFunc"))
    EventManager.Instance:AddEvent(EventDefine.update_role_info,self:ToFunc("CheckUnOpenFunc"))
end

function OpenFuncCtrl:InitDataComplete()
    for id,info in pairs(Config.OpenFuncData.data_open_func_info) do
        if not self:CheckOpenFunc(id) then
            mod.OpenFuncProxy:AddUnOpenFunc(id)
        end
    end
    EventManager.Instance:SendEvent(EventDefine.update_open_func)
end

function OpenFuncCtrl:CheckUnOpenFunc()
    for id,v in pairs(mod.OpenFuncProxy.unOpenFuncs) do
        if self:CheckOpenFunc(id) then
            mod.OpenFuncProxy:RemoveUnOpenFunc(id)
        end
    end
    --通知
    EventManager.Instance:SendEvent(EventDefine.update_open_func)
end

function OpenFuncCtrl:IsOpenFunc(id)
    local flag = mod.OpenFuncProxy:IsOpenFunc(id)
    if not flag then
        local conf = Config.OpenFuncData.data_open_func_info[id]
        local _,index = self:CheckOpenFunc(id)
        return false,conf[index].msg
    end
    return true,nil
end

function OpenFuncCtrl:IsOpenFuncAndMsg(id)
    local flag,msg = self:IsOpenFunc(id)
    if not flag then
        SystemMessage.Show(msg)
        return false
    end
    return true
end

function OpenFuncCtrl:CheckOpenFunc(id)
    local conf = Config.OpenFuncData.data_open_func_info[id]
    for i,v in ipairs(conf) do
        local mapping = OpenFuncDefine.CondMapping[v.open_cond.type]
        if not mapping then
            assert(false,string.format("检查开放功能异常，未知的条件类型[id:%s][条件类型:%s]",id,v.open_cond.type))
        end

        local flag = _G[mapping.class][mapping.func](v.open_cond)
        if not flag then
            return false,i
        end
    end
    return true,nil
end