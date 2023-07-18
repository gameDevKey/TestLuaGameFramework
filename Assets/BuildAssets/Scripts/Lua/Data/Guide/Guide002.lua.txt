local Guide002 = {}

Guide002.Id = "Guide002"
Guide002.NextId = nil

Guide002.GroupId = 1

Guide002.Listen = {
    Type = "移动时"
}

Guide002.Clips = {
    {
        Action = {
            Type = "延迟",
            Args = { Time = 2 },
        },
    },
    {
        Find = {
            {
                Type = "屏幕位置",
                Args = { Type = "底部" },
            }
        },
        Action = {
            Type = "显示对话框",
            Args = { Role = "001", Msg = "移动了" },
        },
    },
}

return Guide002
