RemindProxy = BaseClass("RemindProxy",Proxy)

function RemindProxy:__Init()
    self.remindIdToInfo = {}
    self.protoIdToRemindId = {}
end

function RemindProxy:__InitProxy()

end

function RemindProxy:__InitComplete()

end

function RemindProxy:AddRemindInfo(remindId,info)
    if self.remindIdToInfo[remindId] then
        assert(false,string.format("添加提醒信息失败,存在重复提醒Id[remindId:%s]",remindId))
    end

    self.remindIdToInfo[remindId] = info

    for i,v in ipairs(info.baseInfo.protoId) do
        if not self.protoIdToRemindId[v] then
            self.protoIdToRemindId[v] = {}
        end
        table.insert(self.protoIdToRemindId[v],remindId)
    end
end

function RemindProxy:GetRemindInfo(remindId)
    return self.remindIdToInfo[remindId]
end

function RemindProxy:IsRemind(remindId,flagKey)
    if not remindId then
        return false
    else
        return self.remindIdToInfo[remindId]:IsFlag(flagKey)
    end
end