RemindCtrl = BaseClass("RemindCtrl",Controller)

function RemindCtrl:__Init()
    
end

function RemindCtrl:__Delete()

end

function RemindCtrl:__InitComplete()
    Network.Instance:SetHookRecv(self:ToFunc("OnHookRecv"))

    for remindId,info in pairs(RemindDefine.RemindInfo) do
        self:InitRemindInfo(remindId,info,nil)
    end
end

function RemindCtrl:InitRemindInfo(remindId,baseInfo,parentRemindId)
    local runInfo = RemindRunInfo.New(remindId,parentRemindId,baseInfo)
    runInfo:SetRemindId(remindId)
    runInfo:SetParentRemindId(parentRemindId)
    runInfo:SetBaseInfo(baseInfo)

    local funInfos = StringUtils.Split(baseInfo.func,".")
    runInfo:SetFunInfo(funInfos[1],funInfos[2])

    mod.RemindProxy:AddRemindInfo(remindId,runInfo)

    for childRemindId,childInfo in pairs(baseInfo.childs) do
        self:InitRemindInfo(childRemindId,childInfo,remindId)
    end
end

function RemindCtrl:OnHookRecv(protoId,data)
    local remindIds = mod.RemindProxy.protoIdToRemindId[protoId]
    for i,v in ipairs(remindIds or {}) do
        local info = mod.RemindProxy:GetRemindInfo(v)
        self:Assert(info)
        local ctrl = mod[info.ctrlName]
        local lastFlagNum = info.flagNum
        local lastChangeUid = info.changeUid
        ctrl[info.funName](ctrl,info,data,protoId)
        if lastChangeUid ~= info.changeUid then
            local changeFlagNum = info.flagNum - lastFlagNum
            --Log("更新提醒信息",info.remindId,info.flagNum,changeFlagNum,tostring(info.flag))
            EventManager.Instance:SendEvent(EventDefine.change_remind,info.remindId)
            if info.baseInfo.isChangeParent then
                local parentInfo = mod.RemindProxy:GetRemindInfo(info.parentRemindId)
                if parentInfo then
                    self:UpdateParentRemind(parentInfo,changeFlagNum)
                end
            end
        end
    end
end

function RemindCtrl:SetRemind(remindId,flag,flagKey)
    local info = mod.RemindProxy:GetRemindInfo(remindId)
    local lastFlagNum = info.flagNum
    local lastChangeUid = info.changeUid
    info:SetFlag(flag,flagKey)
    if lastChangeUid ~= info.changeUid then
        local changeFlagNum = info.flagNum - lastFlagNum
        EventManager.Instance:SendEvent(EventDefine.change_remind,remindId)
        if info.baseInfo.isChangeParent then
            local parentInfo = mod.RemindProxy:GetRemindInfo(info.parentRemindId)
            if parentInfo then
                self:UpdateParentRemind(parentInfo,changeFlagNum)
            end
        end
    end
end

function RemindCtrl:UpdateParentRemind(info,changeFlagNum)
    local lastFlag = info:IsFlag()
    info.flagNum = info.flagNum + changeFlagNum

    --Log("更新父节点提醒信息",info.remindId,info.flagNum,changeFlagNum,tostring(info.flag))

    if lastFlag ~= info:IsFlag() then
        EventManager.Instance:SendEvent(EventDefine.change_remind,info.remindId)
    end

    if info.baseInfo.isChangeParent then
        local parentInfo = mod.RemindProxy:GetRemindInfo(info.parentRemindId)
        if parentInfo then
            self:UpdateParentRemind(parentInfo,changeFlagNum)
        end
    end
end

function RemindCtrl:RemoveRemindKvData(remindId,key)
    local info = mod.RemindProxy:GetRemindInfo(remindId)
    info.kvData[key] = nil
end

function RemindCtrl:Assert(remindInfo)
    local ctrl = mod[remindInfo.ctrlName]
    if not ctrl then
        LogErrorAny("Ctrl类未注册到RemindFacade中",remindInfo.ctrlName)
        return false
    end
    if not ctrl[remindInfo.funName] then
        LogErrorAny("Ctrl类中未定义方法",remindInfo.ctrlName,remindInfo.funName)
        return false
    end
    return true
end