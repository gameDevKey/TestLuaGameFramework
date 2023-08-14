EventAction = BaseClass("EventAction")

function EventAction:__Init()
    self.callBackDict = {}
end

function EventAction:AddListener(callBack,args)
    if self.callBackDict[callBack] then return end
    self.callBackDict[callBack] = args or {}
end

function EventAction:RemoveListener(callback)
    self.callBackDict[callback] = nil
end

function EventAction:RemoveAll()
    self.callBackDict = {}
end

function EventAction:SendEvent(...)
    for k,_ in pairs(self.callBackDict) do 
        k(...)
    end
end

function EventAction:destroy()
    self:removeAll()
end

function EventAction:__Delete()
    self:destroy()
end

function EventAction.Create()
    return EventAction.New()
end
