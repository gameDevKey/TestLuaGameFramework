RemindRunInfo = BaseClass("RemindRunInfo")

function RemindRunInfo:__Init()
    self.remindId = nil
    self.parentRemindId = nil
    self.flags = {}
    self.flagNum = 0
    self.changeUid = 0
    self.kvData = {}
    self.baseInfo = nil

    self.ctrlName = nil
    self.funName = nil
end

function RemindRunInfo:__Delete()

end

function RemindRunInfo:SetRemindId(remindId)
    self.remindId = remindId
end

function RemindRunInfo:SetParentRemindId(parentRemindId)
    self.parentRemindId = parentRemindId
end

function RemindRunInfo:SetBaseInfo(baseInfo)
    self.baseInfo = baseInfo
end

function RemindRunInfo:SetFunInfo(ctrlName,funName)
    self.ctrlName = ctrlName
    self.funName = funName
end

function RemindRunInfo:SetFlag(flag,flagKey)
    if flagKey then
        local curFlag = self.flags[flagKey] or false
        if flag ~= curFlag then
            self.flags[flagKey] = flag
            local changeNum = flag and 1 or -1
            self.flagNum = self.flagNum + changeNum
            self.changeUid = self.changeUid + 1
        end
    else
        local curFlag = self.flagNum > 0
        if flag ~= curFlag then
            local changeNum = flag and 1 or -1
            self.flagNum = self.flagNum + changeNum
            self.changeUid = self.changeUid + 1
        end
    end
end

function RemindRunInfo:IsFlag(flagKey)
    if flagKey then
        return self.flags[flagKey] or false
    else
        return self.flagNum > 0
    end
end