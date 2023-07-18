--处理一些纯业务逻辑（不涉及界面的逻辑）
GamePlayViewCtrl = SingletonClass("GamePlayViewCtrl",ViewCtrlBase)

function GamePlayViewCtrl:OnInitComplete()
    self:AddGolbalListenerWithSelfFunc(EGlobalEvent.Login, "ActiveGameMenuView", false)
    self:AddListenerWithSelfFunc(EGamePlayModule.LogicEvent.StartGame, "ActiveGameView", false)
end

function GamePlayViewCtrl:ActiveGameMenuView()
    self:EnterView(UIDefine.ViewType.GameMenuView)
end

function GamePlayViewCtrl:ActiveGameView()
    self:EnterView(UIDefine.ViewType.GameView)
end

return GamePlayViewCtrl