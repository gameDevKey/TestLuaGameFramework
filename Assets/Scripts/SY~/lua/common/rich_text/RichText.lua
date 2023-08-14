RichText = StaticClass("RichText")

--
function RichText.Create(richTextInfo)
    local richTextItem = RichTextItem.New(richTextInfo)

    local elements = {}

    local lastIdx = 1
    for tag, val in string.gmatch(richTextInfo.content, "<(.-) (.-)/>") do
        local logicElementType = RichTextDefine.LogicElementTypeMapping[tag]
        local tagStr = string.format("<%s %s/>", tag, val)
        local startIndex, endIndex = string.find(richTextInfo.content, tagStr, lastIdx, true)
        local beforeStr = string.sub(richTextInfo.content, lastIdx, startIndex - 1)
        lastIdx = lastIdx + #beforeStr + #tagStr
        

        if beforeStr ~= "" then
            local richTextNoneText = RichTextNoneText.New(richTextItem)
            richTextNoneText:ParseData({content = beforeStr})
            table.insert(elements,richTextNoneText)
        end

        local data = {}
        for str in string.gmatch(val,"([^ ]+)") do
            local kvIndex = string.find(str,"=")
            local key = string.sub(str,0,kvIndex-1)
            local val = string.sub(str,kvIndex + 1,#str)
            data[key] = val
		end

        local elementClass = _G[RichTextDefine.ElementMapping[logicElementType or tag].class]
        local element = elementClass.New(richTextItem)
        element:ParseData(data)
        if logicElementType then
            element:SetLogicElementType(tag)
        end
        table.insert(elements,element)
    end

    local lastStr = string.sub(richTextInfo.content, lastIdx, string.len(richTextInfo.content))
    if lastStr ~= "" then
        local richTextNoneText = RichTextNoneText.New(richTextItem)
        richTextNoneText:ParseData({content = lastStr})
        table.insert(elements,richTextNoneText)
    end

    
    richTextItem:Create(elements)

    return richTextItem
end

--简述：
--1.富文本格式为:<富文本类型 k1=v1 k2=v2/>
--2.富文本标签在RichTextDefine.Element中定义（当需要新增富文本类型时增加映射）
--3.扩展富文本类，需要实现OnCreate和OnParseData函数（OnCreate为创建富文本内容回调、OnParseData为解析富文本kv数据内容,自行根据富文本类型进行读取）
--4.每个使用的业务层，需要的富文本资源模板也不尽相同，比如A界面需要的正常文本大小为17、B界面需要的正常文本大小为20，因此需要各业务层制作富文本模板，创建富文本对象时，传入RichTextInfo.elementTemplate字段（可参考Assets/Temp/rich_text下的模板资源）


--测试代码
-- local richTextInfo = RichTextInfo.New()
-- richTextInfo.content = "测试测   试测试测试<click_text content=aaaaaadsa color=658d51ff lineSize=3/>测试<rich_text content=测试测试aa color=658888ff/>"
-- richTextInfo.lineSpacing = 10
-- richTextInfo.viewWidth = 300
-- richTextInfo.elementTemplate = 
-- {
--     [RichTextDefine.Element.none_text] ={original = GameObject.Find("Canvas/test_normal")
--         ,textComponent = GameObject.Find("Canvas/test_normal/text"):GetComponent(Text)},
--     [RichTextDefine.Element.rich_text] ={original = GameObject.Find("Canvas/test_normal")
--         ,textComponent = GameObject.Find("Canvas/test_normal/text"):GetComponent(Text)},
--     [RichTextDefine.Element.click_text] ={ original = GameObject.Find("Canvas/test_click_text")
--         ,textComponent = GameObject.Find("Canvas/test_click_text/text"):GetComponent(Text)}
-- }

-- richTextInfo.parent = GameObject.Find("Canvas").transform
-- richTextInfo.onClick = function() Log("点击了222222") end
-- local richTextItem = RichText.Create(richTextInfo)


--测试流程
--1.打开Assets/Temp/rich_text目录
--2.将目录中的文件拖到Canvas下面
--3.运行上方的测试代码