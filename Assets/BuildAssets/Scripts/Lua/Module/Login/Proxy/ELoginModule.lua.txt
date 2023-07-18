ELoginModule = {}

ELoginModule.ViewEvent = Enum.New({
    ActiveLoginView = Enum.Index,
})

ELoginModule.LoginState = Enum.New({
    Unknown = 0,
    OK = 1,
    Fail = 2,
})

return ELoginModule