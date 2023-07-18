EGamePlayModule = {}

EGamePlayModule.LogicEvent = Enum.New({
    StartGame = Enum.Index,
    GameOver = Enum.Index,
})

EGamePlayModule.ViewEvent = Enum.New({

})

EGamePlayModule.PlayerType = Enum.New({
    Player = 1,
    NPC = 2,
})

return EGamePlayModule