OpenFuncProxy = BaseClass("OpenFuncProxy",Proxy)

function OpenFuncProxy:__Init()
    self.unOpenFuncs = {}   --TODO 已废弃，后面移除
    self.openList = {}
    self.toShowList = {}
end

function OpenFuncProxy:__InitProxy()
    self:BindMsg(10800)
    self:BindMsg(10801)
    self:BindMsg(10802)
end

function OpenFuncProxy:__InitComplete()
end

---@deprecated
function OpenFuncProxy:AddUnOpenFunc(id)
    self.unOpenFuncs[id] = true
end

---@deprecated
function OpenFuncProxy:RemoveUnOpenFunc(id)
    self.unOpenFuncs[id] = nil
end

---@deprecated
function OpenFuncProxy:IsOpenFunc(id)
    return not self.unOpenFuncs[id]
end

function OpenFuncProxy:Recv_10800(data)
    LogTable("接收10800",data)
    for _, id in ipairs(data.open_list) do
        self.openList[id] = true
    end
end

function OpenFuncProxy:Recv_10801(data)
    LogTable("接收10801",data)
    local changeList = {}   --map[funcId]bool
    for _, id in ipairs(data.new_list) do
        if not self.openList[id] then
            changeList[id] = true
        end
        self.openList[id] = true
    end
    if not TableUtils.IsEmpty(changeList) then
        EventManager.Instance:SendEvent(EventDefine.on_func_unlock, changeList)
        self:SetToShowList(changeList)
    end
end

function OpenFuncProxy:Recv_10802(data)
    LogTable("接收10802",data)
    local changeList = {}   --map[funcId]bool
    for _, id in ipairs(data.close_list) do
        if self.openList[id] then
            changeList[id] = true
        end
        self.openList[id] = nil
    end
    if not TableUtils.IsEmpty(changeList) then
        EventManager.Instance:SendEvent(EventDefine.on_func_lock, changeList)
    end
end

---功能是否解锁
function OpenFuncProxy:IsFuncUnlock(funcId)
    return self.openList[funcId] ~= nil
end

function OpenFuncProxy:ShowLockTips(funcId)
    local conf = Config.FuncOpenData.data_func_open_info[funcId]
    if not conf then
        return
    end
    SystemMessage.Show(conf.lock_tips)
end

function OpenFuncProxy:JudgeFuncUnlockAndMsg(funcId)
    if not mod.OpenFuncProxy:IsFuncUnlock(funcId) then
        mod.OpenFuncProxy:ShowLockTips(funcId)
        return false
    end
    return true
end

function OpenFuncProxy:SetToShowList(changeList)
    local showList = {}
    for k, v in pairs(changeList) do
        local conf = Config.FuncOpenData.data_func_open_info[k]
        if conf.open_window == 1 then
            table.insert(showList,{funcName = conf.name, funcIcon = conf.icon, content = conf.desc})
        end
    end
    self.toShowList = showList
end
