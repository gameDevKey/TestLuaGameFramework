--处理一些纯业务逻辑（不涉及界面的逻辑）
GamePlayCtrl = SingletonClass("GamePlayCtrl",CtrlBase)

function GamePlayCtrl:OnInitComplete()
    RunWorld = nil
    self:AddListenerWithSelfFunc(EGamePlayModule.LogicEvent.StartGame,"StartGame",false)
    -- self:AddListenerWithSelfFunc(EGamePlayModule.LogicEvent.GameOver,"GameOver",false)
end

function GamePlayCtrl:StartGame()
    if RunWorld then
        PrintError("游戏已开始")
        return
    end
    RunWorld = GamePlayWorld.New()
    RunWorld:SetRender(true)
    WorldManager.Instance:AddWorld(RunWorld)
    RunWorld:InitComplete()
    EventDispatcher.Global:Broadcast(EGlobalEvent.GameStart)
end

function GamePlayCtrl:GameOver()
    if not RunWorld then
        PrintError("游戏未开始")
        return
    end
    WorldManager.Instance:RemoveWorld(RunWorld)
    RunWorld = nil
    EventDispatcher.Global:Broadcast(EGlobalEvent.GameOver)
end

return GamePlayCtrl