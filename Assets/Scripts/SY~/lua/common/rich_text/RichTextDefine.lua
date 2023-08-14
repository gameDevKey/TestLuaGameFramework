RichTextDefine = StaticClass("RichTextDefine")


RichTextDefine.StartCorner = 
{
    left_top = 1,
    right_top = 2,
    left_bottom = 3,
    right_bottom = 4,
}


RichTextDefine.Element =
{
    ["none_text"] = "none_text",
    ["rich_text"] = "rich_text",
    ["click_text"] = "click_text",
}

RichTextDefine.ElementMapping =
{
    [RichTextDefine.Element.none_text] = {class = "RichTextNoneText"},
    [RichTextDefine.Element.rich_text] = {class = "RichTextNormalText"},
    [RichTextDefine.Element.click_text] = {class = "RichTextClickText"},
}

RichTextDefine.LogicElementType =
{
    ["summon_unit"] = "summon_unit",  -- 召唤物
    ["terminology"] = "terminology",  -- 名词解释
}

RichTextDefine.LogicElementTypeMapping =
{
    ["summon_unit"] = "click_text",
    ["terminology"] = "click_text",
}