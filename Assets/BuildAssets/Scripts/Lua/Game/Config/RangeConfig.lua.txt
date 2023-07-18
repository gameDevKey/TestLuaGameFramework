RangeConfig = StaticClass("RangeConfig")

RangeConfig.Type = {
    Circle = Enum.Index,
    Rect = Enum.Index,
}

RangeConfig.Type2Res = {
    [RangeConfig.Type.Circle] = "CircleRange",
    [RangeConfig.Type.Rect] = "RectRange",
}

return RangeConfig