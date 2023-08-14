DialogProxy = BaseClass("DialogProxy",Proxy)

function DialogProxy:__Init()
    self.systemMessagePanel = nil
    self.notShowDialogKeys = {}
    self.systemDialogPanel = nil
end

function DialogProxy:__Delete()
    if self.systemMessagePanel then
        self.systemMessagePanel:Destroy()
        self.systemMessagePanel = nil
    end
end

function DialogProxy:__InitProxy()
    self:BindMsg(10103)
end

function DialogProxy:__InitComplete()
end


function DialogProxy:Recv_10103(data)
    LogTable("接收协议10103",data)
    if data.id == 0 then
        mod.DialogFacade:SendEvent(SystemMessagePanel.Event.ShowSystemMessage,data.msg)
    end
end

function DialogProxy:SetNotShowDialogKey(key)
    self.notShowDialogKeys[key] = true
end

function DialogProxy:HasNotShowDialogKey(key)
    return self.notShowDialogKeys[key] == true
end