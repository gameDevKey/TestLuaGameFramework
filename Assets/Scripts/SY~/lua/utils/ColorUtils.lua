ColorUtils = StaticClass("ColorUtils")

ColorUtils.Default = Color(49/255, 102/255, 173/255)
ColorUtils.DefaultButton1 = Color(199/255, 249/255, 255/255)
ColorUtils.DefaultButton2 = Color.white
ColorUtils.DefaultButton3 = Color(144/255, 96/255, 20/255)
ColorUtils.DefaultButton4 = Color(224/255, 224/255, 224/255)
ColorUtils.DefaultButton5 = Color(199/255, 249/255, 255/255)
ColorUtils.DefaultButton6 = Color(144/255, 96/255, 20/255)
ColorUtils.DefaultButton7 = Color.white
ColorUtils.DefaultButton8 = Color(49/255, 102/255, 173/255)
ColorUtils.DefaultButton9 = Color(144/255, 96/255, 20/255)
ColorUtils.DefaultButton10 = Color(49/255, 102/255, 173/255)
ColorUtils.DefaultButton11 = Color(49/255, 102/255, 173/255)
ColorUtils.TabButton1Normal = Color(151/255, 202/255, 255/255)
ColorUtils.TabButton1Select = Color(39/255, 99/255, 176/255)
ColorUtils.TabButton2Normal = Color(199/255, 249/255, 255/255)
ColorUtils.TabButton2Select = Color.white
ColorUtils.ListItem = Color(12/255, 82/255, 176/255, 1) --字体颜色
ColorUtils.ListItem1 = Color(154/255, 198/255, 241/255, 1) --背景颜色
ColorUtils.ListItem2 = Color(127/255, 178/255, 235/255, 1) --背景颜色

--好友界面颜色
ColorUtils.White =  Color(255 / 255, 255 / 255, 255 / 255)
ColorUtils.Grey = Color(128 / 255, 128 / 255, 128 / 255)
ColorUtils.Grey2 = Color(100 / 255, 50 / 255, 35 / 255)
ColorUtils.NameWhite = Color(245/255, 240/255, 220/255)

--修仙颜色列表
ColorUtils.XXDefault = Color(12/255, 83/255, 97/255)
ColorUtils.XXDefaultButton1 = Color(254/255, 254/255, 254/255)
ColorUtils.XXDefaultButton2 = Color(130/255, 84/255, 4/255)

ColorUtils.ButtonColorDic = {
    ["Default"] = ColorUtils.Default
    , ["DefaultButton1"] = ColorUtils.DefaultButton1
    , ["DefaultButton2"] = ColorUtils.DefaultButton2
    , ["DefaultButton3"] = ColorUtils.DefaultButton3
    , ["DefaultButton4"] = ColorUtils.DefaultButton4
    , ["DefaultButton5"] = ColorUtils.DefaultButton5
    , ["DefaultButton6"] = ColorUtils.DefaultButton6
    , ["DefaultButton7"] = ColorUtils.DefaultButton7
    , ["DefaultButton8"] = ColorUtils.DefaultButton8
    , ["DefaultButton9"] = ColorUtils.DefaultButton9
    , ["DefaultButton10"] = ColorUtils.DefaultButton10
    , ["DefaultButton11"] = ColorUtils.DefaultButton11
}

ColorUtils.DefaultStr = "<color='#3166ad'>%s</color>"
ColorUtils.DefaultButton1Str = "<color='#c7f9ff'>%s</color>"
ColorUtils.DefaultButton2Str = "<color='#ffffff'>%s</color>"
ColorUtils.DefaultButton3Str = "<color='#906014'>%s</color>"
ColorUtils.DefaultButton4Str = "<color='#e0e0e0'>%s</color>"
ColorUtils.DefaultButton5Str = "<color='#c7f9ff'>%s</color>"
ColorUtils.DefaultButton6Str = "<color='#906014'>%s</color>"
ColorUtils.DefaultButton7Str = "<color='#ffffff'>%s</color>"
ColorUtils.DefaultButton8Str = "<color='#3166ad'>%s</color>"
ColorUtils.DefaultButton9Str = "<color='#906014'>%s</color>"
ColorUtils.DefaultButton10Str = "<color='#3166ad'>%s</color>"
ColorUtils.DefaultButton11Str = "<color='#3166ad'>%s</color>"
ColorUtils.TabButton1NormalStr = "<color='#97caff'>%s</color>"
ColorUtils.TabButton1SelectStr = "<color='#2763b0'>%s</color>"
ColorUtils.TabButton2NormalStr = "<color='#c7f9ff'>%s</color>"
ColorUtils.TabButton2SelectStr = "<color='#ffffff'>%s</color>"
ColorUtils.TabButtonRedNormal="<color='#ff0000'>%s</color>"
ColorUtils.ListItemStr = "<color='#0c52b0'>%s</color>" --字体颜色

--修仙颜色列表
ColorUtils.XXDefaultStr = "<color='#0c5361'>%s</color>"
ColorUtils.XXDefaultButton1Str = "<color='#fefefe'>%s</color>"
ColorUtils.XXDefaultButton2Str = "<color='#825404'>%s</color>"


--道具名称上色
ColorUtils.color_item_name = function(quality, name)
    local str = name
    if quality == 0 then
        str = string.format("<color='#%s'>%s</color>", ColorData.data_item_quality_color[0].light_color, name)
    elseif quality == 1 then
        str = string.format("<color='#%s'>%s</color>", ColorData.data_item_quality_color[1].light_color, name)
    elseif quality == 2 then
        str = string.format("<color='#%s'>%s</color>", ColorData.data_item_quality_color[2].light_color, name)
    elseif quality == 3 then
        str = string.format("<color='#%s'>%s</color>", ColorData.data_item_quality_color[3].light_color, name)
    elseif quality == 4 then
        str = string.format("<color='#%s'>%s</color>", ColorData.data_item_quality_color[4].light_color, name)
    elseif quality == 5 then
         str = string.format("<color='#%s'>%s</color>", ColorData.data_item_quality_color[5].light_color, name)
    elseif quality == 6 then
        str = string.format("<color='#%s'>%s</color>", ColorData.data_item_quality_color[6].light_color, name)
    end
    return str
end


--通用颜色表
ColorUtils.color = {
     [0] = "#ffffff"  --白色
    ,[1] = "#3eff1e" --绿色
    ,[2] = "#225199" --蓝色
    ,[3] = "#b031d5" --紫色
    ,[4] = "#ff6d2d" --橙色
    ,[5] = "#fff000" --黄色
    ,[6] = "#df3435" --红色
    ,[7] = "#808080" --灰色
    ,[8] = "#fe2a00"  --默认错误颜色
    ,[9] = "#60ff4b"  --默认主角名字颜色
    ,[10] = "#31f2f9" --蓝 等级突破1
    ,[11] = "#ff9e68" --橙 等级突破2
}

--通用颜色表
ColorUtils.colorObject = {
     [0] = Color.white  --白色
    ,[1] = Color(36/255, 136/255, 19/255, 1)  --绿色
    ,[2] = Color(34/255, 81/255, 153/255, 1)  --蓝色
    ,[3] = Color(176/255, 49/255, 213/255, 1)  --紫色
    ,[4] = Color(195/255, 105/255, 44/255, 1)  --橙色
    ,[5] = Color(1, 1, 0, 1)  --黄色
    ,[6] = Color(0.8, 0.129411765, 0.129411765, 1)  --红色
    ,[7] = Color(0.501960784, 0.501960784, 0.501960784, 1)  --灰色
    ,[8] = Color(0.996078431, 0.164705882, 1, 1)   --默认错误颜色
    ,[9] = Color(0.3764705882352941, 1, 0.2941176470588235, 1)   --默认主角名字颜色
    ,[10] = Color(0.192157, 0.949, 0.9765, 1)  --蓝 等级突破1
    ,[11] = Color(1, 0.6196, 0.407843, 1)  --橙 等级突破2
}

ColorUtils.colorScene = {
     [0] = "#ffffff"  --白色
    ,[1] = "#2fc823" --绿色
    ,[2] = "#225199" --蓝色
    ,[3] = "#ff00ff" --紫色
    ,[4] = "#ffa500" --橙色
    ,[5] = "#ffff00" --黄色
    ,[6] = "#df3435" --红色
    ,[7] = "#808080" --灰色
    ,[8] = "#fe2a00"  --默认错误颜色
    ,[9] = "#60ff4b"  --默认主角名字颜色
    ,[10] = "#31f2f9" --蓝 等级突破1
    ,[11] = "#ff9e68" --橙 等级突破2
}

--通用颜色表
ColorUtils.colorObjectScene = {
     [0] = Color.white  --白色
    ,[1] = Color(0.015686275, 0.866666667, 0.321568627, 1)  --绿色
    ,[2] = Color(0.003921569, 0.752941176, 1, 1)  --蓝色
    ,[3] = Color.magenta --紫色
    ,[4] = Color(1, 0.647058824, 1, 1)  --橙色
    ,[5] = Color(1, 240/255, 0, 1)  --黄色
    -- ,[6] = Color(0.8, 0.129411765, 0.129411765, 1)  --红色
    ,[6] = Color(0xFF/0xFF, 0x45/0xFF, 0x08/0xFF, 1)  --红色
    ,[7] = Color(0.501960784, 0.501960784, 0.501960784, 1)  --灰色
    ,[8] = Color(0.996078431, 0.164705882, 1, 1)   --默认错误颜色
    -- ,[9] = Color(0.3764705882352941, 1, 0.2941176470588235, 1)   --默认主角名字颜色
    ,[9] = Color(0x57/0xFF, 0xF2/0xFF, 0xFC/0xFF, 1)   --默认主角名字颜色
    ,[10] = Color(0.192157, 0.949, 0.9765, 1)  --蓝 等级突破1
    ,[11] = Color(1, 0.6196, 0.407843, 1)  --橙 等级突破2
}

function ColorUtils.GetColor(color)
    if tonumber(color) == nil then
        return color
    -- elseif ColorUtils.colorScene[tonumber(color)] ~= nil then
    --     return ColorUtils.colorScene[tonumber(color)]
    elseif ColorData.data_game_color[color] ~= nil then 
        return string.format( "#%s", ColorData.data_game_color[color].light_color)
    else
        return string.format("#%s", color)
    end
end

-- 几个颜色按钮的文字颜色设定
ColorUtils.ButtonLabelColor = {
    Blue = "#c7f9ff",
    Orange = "#906014",
    Green = "#ffffff",
    Gray = "#e0e0e0",
}

-- 消息颜色
ColorUtils.MsgType = {
    Role = 1,
    Guild = 2,
    Item = 3,
    Map = 4,
    System = 5,
    Pet = 6,
    Wing = 7,
    Unit = 8,
    Guard = 9,
    Honor = 10,
    Achievement = 11,
    Rec = 12,
    Ride = 13,
}

-- ColorUtils.MessageColor = {
--     {
--     [ColorUtils.MsgType.Role] = "#"..NoticeData.data_special_name_color(1).name,
--     [ColorUtils.MsgType.Guild] = "#"..NoticeData.data_special_name_color(2).name,
--     [ColorUtils.MsgType.Item] = ColorUtils.colorScene[1],
--     [ColorUtils.MsgType.Map] = "#"..NoticeData.data_special_name_color(3).name,
--     [ColorUtils.MsgType.System] = "#"..NoticeData.data_special_name_color(4).name,
--     [ColorUtils.MsgType.Pet] = "#"..NoticeData.data_special_name_color(5).name,
--     [ColorUtils.MsgType.Wing] = ColorUtils.colorScene[1],
--     [ColorUtils.MsgType.Unit] = "#"..NoticeData.data_special_name_color(6).name,
--     [ColorUtils.MsgType.Guard] = "#"..NoticeData.data_special_name_color(7).name,
--     [ColorUtils.MsgType.Honor] = "#"..NoticeData.data_special_name_color(8).name,
--     [ColorUtils.MsgType.Achievement] = "#"..NoticeData.data_special_name_color(9).name,
--     [ColorUtils.MsgType.Rec] = "#"..NoticeData.data_special_name_color(10).name,
--     [ColorUtils.MsgType.Ride] = "#"..NoticeData.data_special_name_color(11).name,
--     },
--     {
--         [ColorUtils.MsgType.Role] = "#"..NoticeData.data_special_name_color(1).name2,
--         [ColorUtils.MsgType.Guild] = "#"..NoticeData.data_special_name_color(2).name2,
--         [ColorUtils.MsgType.Item] = ColorUtils.colorScene[1],
--         [ColorUtils.MsgType.Map] = "#"..NoticeData.data_special_name_color(3).name2,
--         [ColorUtils.MsgType.System] = "#"..NoticeData.data_special_name_color(4).name2,
--         [ColorUtils.MsgType.Pet] = "#"..NoticeData.data_special_name_color(5).name2,
--         [ColorUtils.MsgType.Wing] = ColorUtils.colorScene[1],
--         [ColorUtils.MsgType.Unit] = "#"..NoticeData.data_special_name_color(6).name2,
--         [ColorUtils.MsgType.Guard] = "#"..NoticeData.data_special_name_color(7).name2,
--         [ColorUtils.MsgType.Honor] = "#"..NoticeData.data_special_name_color(8).name2,
--         [ColorUtils.MsgType.Achievement] = "#"..NoticeData.data_special_name_color(9).name2,
--         [ColorUtils.MsgType.Rec] = "#"..NoticeData.data_special_name_color(10).name2,
--         [ColorUtils.MsgType.Ride] = "#"..NoticeData.data_special_name_color(11).name2,

--     }
-- }

ColorUtils.PetColor = {
    [1] = "#6bd465", --"#79ff00",
    [2] = "#70b0f7", --"#00b4ff",
    [3] = "#da6dff", --"#e600ff",
    [4] = "#ea7f48", --"#ff6a00",
    [5] = "#ea5348", --"#ff0002",
}

-- 品质对应的色码
ColorUtils.QualityColor = {
    [0] = "a3a8ca",         -- 白
    [1] = "6bd465",         -- 绿
    [2] = "6fd3fe",         -- 蓝
    [3] = "c06ffe",         -- 紫
    [4] = "fecc6f",         -- 橙
    [5] = "fe6f76",         -- 红
}

-- 品质对应的色值
ColorUtils.QualityColorVal = {
    [0] = Color(163/255, 168/255, 202/255),     -- 白
    [1] = Color(111/255, 254/255, 220/255),     -- 绿
    [2] = Color(111/255, 211/255, 254/255),     -- 蓝
    [3] = Color(192/255, 111/255, 254/255),     -- 紫
    [4] = Color(254/255, 204/255, 111/255),     -- 橙
    [5] = Color(254/255, 111/255, 118/255),     -- 红
}

ColorUtils.QualityColorVal1 = {
    [0] = Color(0x74/255, 0x78/255, 0x7b/255),     -- 白
    [1] = Color(0x81/255, 0xb9/255, 0x3e/255),     -- 绿
    [2] = Color(0x4a/255, 0xb0/255, 0xda/255),     -- 蓝
    [3] = Color(0x88/255, 0x75/255, 0xfb/255),     -- 紫
    [4] = Color(0xf0/255, 0x81/255, 0x24/255),     -- 橙
    [5] = Color(0xcf/255, 0x31/255, 0x25/255),     -- 红
}



function ColorUtils.Fill(colorStr, str)
    return string.format("<color='%s'>%s</color>", colorStr, str)
end

--上面亮换暗，下面暗换亮
function ColorUtils.ChangeTxtColor(str,is_dark_bg) 
    local replaceColorTxt = "<color='#%s'>"
    local newStr = str
    if  is_dark_bg then 
        for i=1,6 do 
            local pattern = string.format(replaceColorTxt, ColorData.data_game_color[i].light_color)
            local repl = string.format(replaceColorTxt, ColorData.data_game_color[i].dark_color)
            newStr = string.gsub(newStr,pattern,repl)
        end 
        local pattern = string.format(replaceColorTxt, ColorData.data_game_color[7].light_color)
        local repl = string.format(replaceColorTxt, ColorData.data_game_color[7].dark_color)
        newStr = string.gsub(newStr,pattern,repl)
    else
        for i=1,6 do 
            local pattern = string.format(replaceColorTxt, ColorData.data_game_color[i].dark_color)
            local repl = string.format(replaceColorTxt, ColorData.data_game_color[i].light_color)
            newStr = string.gsub(newStr,pattern,repl)
        end 
        local pattern = string.format(replaceColorTxt, ColorData.data_game_color[7].dark_color)
        local repl = string.format(replaceColorTxt, ColorData.data_game_color[7].light_color)
        newStr = string.gsub(newStr,pattern,repl)
    end 
    return newStr
end 

-- 替换道具品质的颜色
-- 上面亮换暗，下面暗换亮
function ColorUtils.ChangeQualityColor(str, is_dark_bg)
    local replaceColorTxt = "<color='#%s'>"
    local newStr = str
    if  is_dark_bg then 
        for i=1,7 do 
            local pattern = string.format(replaceColorTxt, ColorData.data_item_quality_color[i-1].light_color)
            local repl = string.format(replaceColorTxt, ColorData.data_item_quality_color[i-1].dark_color)
            newStr = string.gsub(newStr,pattern,repl)
        end 
    else
        for i=1,7 do 
            local pattern = string.format(replaceColorTxt, ColorData.data_item_quality_color[i-1].dark_color)
            local repl = string.format(replaceColorTxt, ColorData.data_item_quality_color[i-1].light_color)
            newStr = string.gsub(newStr,pattern,repl)
        end 
    end 
    return newStr
end 




function ColorUtils.HexToColor(hex)
	local s
	s = string.sub(hex,1,2)
	local r = tonumber(s,16)/255
	s = string.sub(hex,3,4)
	local g = tonumber(s,16)/255
	s = string.sub(hex,5,6)
	local b = tonumber(s,16)/255
	s = string.sub(hex,7,8)
    local a = tonumber(s,16)/255
	return Color(r,b,b,a)
end

function ColorUtils.HexToColorVal(hex)
	local s
	s = string.sub(hex,1,2)
	local r = tonumber(s,16)/255
	s = string.sub(hex,3,4)
	local g = tonumber(s,16)/255
	s = string.sub(hex,5,6)
	local b = tonumber(s,16)/255
	s = string.sub(hex,7,8)
    local a = tonumber(s == "" and "ff" or s,16)/255
	return r,g,b,a
end