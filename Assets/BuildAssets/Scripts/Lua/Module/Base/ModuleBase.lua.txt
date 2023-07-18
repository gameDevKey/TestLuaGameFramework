--MVC基类，只提供最通用的函数
--函数OnInitComplete()会在Facade安装完成后自顶向下被调用
ModuleBase = Class("ModuleBase")

function ModuleBase:OnInit()
    self.facade = nil
    self.tbEventKey = {}
    self.tbEventGlobalKey = {}
    self.tbTimerId = {}
end

function ModuleBase:OnDelete()
    self:RemoveAllListener()
    self:RemoveAllGolbalListener()
    self:RemoveAllTimer()
end

function ModuleBase:SetFacade(facade)
    self.facade = facade
    if self.facade then
        self.eventDispatcher = self.facade.eventDispatcher
    end
end

function ModuleBase:InitComplete()
    self:CallFuncDeeply("OnInitComplete",true)
end

local function addListener(tbEventKey, eventDispatcher, eventId, callObject, callonce)
    if not eventDispatcher then return end
    local eventKey = eventDispatcher:AddListener(eventId, callObject, callonce)
    tbEventKey[eventKey] = eventId
    return eventKey
end

local function removeListener(tbEventKey, eventDispatcher, eventKey)
    if not eventDispatcher then return end
    if tbEventKey[eventKey] then
        eventDispatcher:RemoveListener(tbEventKey[eventKey], eventKey)
        tbEventKey[eventKey] = nil
    end
end

local function removeAllListener(tbEventKey, eventDispatcher)
    if not eventDispatcher then return end
    for eventKey, eventId in pairs(tbEventKey or NIL_TABLE) do
        eventDispatcher:RemoveListener(eventId, eventKey)
    end
    tbEventKey = {}
end

function ModuleBase:AddListener(eventId, callback, caller, callonce)
    return addListener(self.tbEventKey, self.eventDispatcher, eventId, CallObject.New(callback, caller), callonce)
end

function ModuleBase:AddListenerWithSelfFunc(eventId, fnName, callonce)
    return self:AddListener(eventId, self:ToFunc(fnName), nil, callonce)
end

function ModuleBase:RemoveListener(eventKey)
    removeListener(self.tbEventKey, self.eventDispatcher, eventKey)
end

function ModuleBase:RemoveAllListener()
    removeAllListener(self.tbEventKey, self.eventDispatcher)
end

function ModuleBase:AddGolbalListener(eventId, callback, caller, callonce)
    return addListener(self.tbEventGlobalKey, EventDispatcher.Global, eventId, CallObject.New(callback, caller), callonce)
end

function ModuleBase:AddGolbalListenerWithSelfFunc(eventId, fnName, callonce)
    return self:AddGolbalListener(eventId, self:ToFunc(fnName), nil, callonce)
end

function ModuleBase:RemoveGolbalListener(eventKey)
    removeListener(self.tbEventGlobalKey, EventDispatcher.Global, eventKey)
end

function ModuleBase:RemoveAllGolbalListener()
    removeAllListener(self.tbEventGlobalKey, EventDispatcher.Global)
end

--模块内部广播,只有Facade会拥有eventDispatcher对象，因此广播方向是自顶向下的
function ModuleBase:Broadcast(id,...)
    if not self.eventDispatcher then
        PrintError("广播失败",id)
        return
    end
    self.eventDispatcher:Broadcast(id,...)
end

function ModuleBase:AddTimer(callback, tickTime)
    local timerId = TimerManager.Instance:AddTimer(callback, tickTime)
    self.tbTimerId[timerId] = true
    return timerId
end

function ModuleBase:RemoveTimer(timerId)
    TimerManager.Instance:RemoveTimer(timerId)
    self.tbTimerId[timerId] = nil
end

function ModuleBase:RemoveAllTimer()
    for timerId, _ in pairs(self.tbTimerId or NIL_TABLE) do
        self:RemoveTimer(timerId)
    end
    self.tbTimerId = {}
end

--#region 虚函数

function ModuleBase:OnInitComplete() end

--#endregion

return ModuleBase
