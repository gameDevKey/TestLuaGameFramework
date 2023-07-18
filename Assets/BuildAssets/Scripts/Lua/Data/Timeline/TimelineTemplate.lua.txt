local TimelineTemplate = {}

TimelineTemplate.Id = 1001

TimelineTemplate.Duration = 3

TimelineTemplate.Actions = {
    {
        Time = 0,
        Action = "DoSomething1",
        Args = {a=1,b=2,c=3}
    },
    {
        Time = 1,
        Action = "DoSomething2",
        Args = {a=1,b=2,c=3}
    },
    {
        Time = 3,
        Action = "DoSomething3",
        Args = {a=1,b=2,c=3}
    },
}

return TimelineTemplate