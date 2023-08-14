LoopScrollViewDefine = SingleClass("LoopScrollViewDefine")

---类型
LoopScrollViewDefine.Type = {
    Unknown = 0,
    Horizontal = 1,
    Vertical = 2,
    Grid = 3,
}

---对齐模式
LoopScrollViewDefine.AlignType = {
    Top = 1,
    Center = 2,
    Bottom = 3,
}

---跳转模式
LoopScrollViewDefine.JumpType = {
    Top = 1,
    Center = 2,
    Bottom = 3,
}

---水平对齐锚点
LoopScrollViewDefine.HorizontalAlignConfig = {
    [LoopScrollViewDefine.AlignType.Top] = {
        anchors = {minX = 0,minY = 0,maxX = 0,maxY = 1},
        pivot = {x = 0, y = 1},
    },
    [LoopScrollViewDefine.AlignType.Center] = {
        anchors = {minX = 0,minY = 0,maxX = 0,maxY = 1},
        pivot = {x = 0, y = 0.5},
    },
    [LoopScrollViewDefine.AlignType.Bottom] = {
        anchors = {minX = 0,minY = 0,maxX = 0,maxY = 1},
        pivot = {x = 0, y = 0},
    }
}

---垂直对齐锚点
LoopScrollViewDefine.VerticalAlignConfig = {
    [LoopScrollViewDefine.AlignType.Top] = {
        anchors = {minX = 0,minY = 1,maxX = 1,maxY = 1},
        pivot = {x = 0, y = 1},
    },
    [LoopScrollViewDefine.AlignType.Center] = {
        anchors = {minX = 0,minY = 1,maxX = 1,maxY = 1},
        pivot = {x = 0.5, y = 1},
    },
    [LoopScrollViewDefine.AlignType.Bottom] = {
        anchors = {minX = 0,minY = 1,maxX = 1,maxY = 1},
        pivot = {x = 1, y = 1},
    }
}