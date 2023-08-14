RemindBase = BaseClass("RemindBase",BaseView)

function RemindBase:__Init()
    self.remindId = nil
    self.flagKey = nil

    self.checkRemindId = {}

    self.onHook = nil

    EventManager.Instance:AddEvent(EventDefine.change_remind,self:ToFunc("ChangeRemind"))
end

function RemindBase:__Delete()
    EventManager.Instance:RemoveEvent(EventDefine.change_remind,self:ToFunc("ChangeRemind"))
end

function RemindBase:__Create()
end

function RemindBase:__Show()

end

--{{{id1,key1},{id2,key2}},{{id3,key3}}}
--支持绑定多组提醒id的逻辑与、逻辑非操作(理论上可以去除红点的树形结构了)
--上面配置的意思为，id1与id2任意达成一个即可、且、id3必须达成
function RemindBase:SetRemindId(remindId,flagKey)
    if type(remindId) == "string" then
        self.checkRemindId[remindId] = true
        self.remindId = {{{remindId,flagKey}}}
    else
        self.remindId = remindId
        for _,reminds in ipairs(self.remindId) do
            for i,v in ipairs(reminds) do
                self.checkRemindId[v[1]] = true
            end
        end
    end

    self:ActiveRemind()
end

function RemindBase:SetHook(onHook)
    self.onHook = onHook
end

function RemindBase:ChangeRemind(remindId)
    if self.checkRemindId[remindId] then
        self:ActiveRemind()
    end
end

function RemindBase:ActiveRemind()
    local remindFlag = false
    for _,v in ipairs(self.remindId) do
        local checkFlag = false
        for _,info in ipairs(v) do
            local remindId = info[1]
            local flagKey = info[2]
            if mod.RemindProxy:IsRemind(remindId,flagKey) then
                checkFlag = true
                break
            end
        end

        remindFlag = checkFlag
        if not remindFlag then
            break
        end
    end

    if self.onHook then
        remindFlag = self.onHook(remindFlag)
    end

    if remindFlag then
        self:Show()
    else
        self:Hide()
    end
end