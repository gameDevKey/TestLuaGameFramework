ELoopScrollView = {}

---类型
ELoopScrollView.Type = {
    Unknown = 0,
    Horizontal = 1,
    Vertical = 2,
    Grid = 3,
}

---对齐模式
ELoopScrollView.AlignType = {
    Top = 1,
    Center = 2,
    Bottom = 3,
}

---跳转模式
ELoopScrollView.JumpType = {
    Top = 1,
    Center = 2,
    Bottom = 3,
}

---水平对齐锚点
ELoopScrollView.HorizontalAlignConfig = {
    [ELoopScrollView.AlignType.Top] = {
        anchors = { minX = 0, minY = 0, maxX = 0, maxY = 1 },
        pivot = { x = 0, y = 1 },
    },
    [ELoopScrollView.AlignType.Center] = {
        anchors = { minX = 0, minY = 0, maxX = 0, maxY = 1 },
        pivot = { x = 0, y = 0.5 },
    },
    [ELoopScrollView.AlignType.Bottom] = {
        anchors = { minX = 0, minY = 0, maxX = 0, maxY = 1 },
        pivot = { x = 0, y = 0 },
    }
}

---垂直对齐锚点
ELoopScrollView.VerticalAlignConfig = {
    [ELoopScrollView.AlignType.Top] = {
        anchors = { minX = 0, minY = 1, maxX = 1, maxY = 1 },
        pivot = { x = 0, y = 1 },
    },
    [ELoopScrollView.AlignType.Center] = {
        anchors = { minX = 0, minY = 1, maxX = 1, maxY = 1 },
        pivot = { x = 0.5, y = 1 },
    },
    [ELoopScrollView.AlignType.Bottom] = {
        anchors = { minX = 0, minY = 1, maxX = 1, maxY = 1 },
        pivot = { x = 1, y = 1 },
    }
}

return ELoopScrollView
