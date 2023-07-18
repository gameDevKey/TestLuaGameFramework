EventConfig = StaticClass("EventConfig")

EventConfig.Type = Enum.New({
    MoveInput = Enum.Index,
    AttrChange = Enum.Index,
})

return EventConfig