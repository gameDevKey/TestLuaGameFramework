--游戏业务模块基类，除了ModuleBase的基础功能外，还支持游戏中的逻辑处理
GameModuleBase = Class("GameModuleBase", ModuleBase, {IWorld})

function GameModuleBase:OnInit()
    self.tbEventGameKey = {}
    self.tbWaitCall = {} --战斗外调用本类接口时会临时保存,进入战斗后会逐个重新调用
end

function GameModuleBase:OnInitComplete()
    if RunWorld then
        self:_OnGameStart()
    else
        self:AddGolbalListenerWithSelfFunc(EGlobalEvent.GameStart, "_OnGameStart")
    end
end

function GameModuleBase:OnDelete()
    self:RemoveAllGameListener()
end

function GameModuleBase:AddWaitCall(fnName, ...)
    table.insert(self.tbWaitCall, {
        fnName = fnName,
        args = { ... }
    })
end

function GameModuleBase:AddGameListener(eventId, callObject, judgeData, once)
    local world = self:GetWorld()
    if not world then
        self:AddWaitCall("AddGameListener", eventId, callObject, judgeData, once)
        return
    end
    local key = world.GameEventSystem:AddListener(eventId, callObject, judgeData, once)
    self.tbEventGameKey[key] = eventId
    return key
end

function GameModuleBase:AddGameListenerWithSelfFunc(eventId, fnName, judgeData, once)
    return self:AddGameListener(eventId, CallObject.New(self:ToFunc(fnName)), judgeData, once)
end

function GameModuleBase:RemoveGameListener(eventId, eventKey)
    local world = self:GetWorld()
    if not world then
        self:AddWaitCall("RemoveGameListener", eventId, eventKey)
        return
    end
    world.GameEventSystem:RemoveListener(eventId, eventKey)
end

function GameModuleBase:BindGameEventHandler(eventId, callObject)
    local world = self:GetWorld()
    if not world then
        self:AddWaitCall("BindGameEventHandler", eventId, callObject)
        return
    end
    world.GameEventSystem:BindHandler(eventId, callObject)
end

function GameModuleBase:RemoveAllGameListener()
    for eventKey, eventId in pairs(self.tbEventGameKey) do
        self:RemoveGameListener(eventId, eventKey)
    end
    self.tbEventGameKey = {}
end

function GameModuleBase:_OnGameStart()
    if #self.tbWaitCall > 0 then
        for _, data in ipairs(self.tbWaitCall) do
            local fn = self:ToFunc(data.fnName)
            fn(table.SafeUpack(data.args))
        end
        self.tbWaitCall = {}
    end
end

return GameModuleBase
