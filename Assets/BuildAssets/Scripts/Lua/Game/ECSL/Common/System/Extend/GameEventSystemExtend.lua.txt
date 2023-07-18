GameEventSystemExtend = ExtendClass(GameEventSystem)

function GameEventSystemExtend:BindAllHandler()
    self:BindHandlerBySelfFunc(EventConfig.Type.MoveInput, "HandleInputEvent")
end

function GameEventSystemExtend:HandleInputEvent(judgeData, ...)
    -- PrintLog("HandleInputEvent judgeData=",judgeData,'args=',...)
    return true
end

return GameEventSystemExtend