ViewCtrlBase = Class("ViewCtrlBase",CtrlBase)

function ViewCtrlBase:OnInitComplete()
end

function ViewCtrlBase:EnterView(uiType, data)
    local view = UIManager.Instance:Enter(uiType, data, self)
    if view then
        EventDispatcher.Global:Broadcast(EGlobalEvent.ViewEnter,uiType,view)
    end
end

function ViewCtrlBase:ExitView(view)
    local success = UIManager.Instance:Exit(view)
    if success then
        EventDispatcher.Global:Broadcast(EGlobalEvent.ViewExit,view.uiType,view)
    end
end

function ViewCtrlBase:GetViewByType(uiType)
    return UIManager.Instance:GetViewByType(uiType)
end

function ViewCtrlBase:GoBackTo(uiType)
    UIManager.Instance:GoBackTo(uiType)
    local view = UIManager.Instance:GetTopView()
    if view then
        EventDispatcher.Global:Broadcast(EGlobalEvent.ViewEnter,view.uiType,view)
    end
end

return ViewCtrlBase