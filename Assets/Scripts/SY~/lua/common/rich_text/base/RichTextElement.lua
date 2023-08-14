RichTextElement = BaseClass("RichTextElement")

function RichTextElement:__Init(richTextItem)
    self.elementType = RichTextDefine.Element.none
    self.richTextItem = richTextItem
    self.kvData = nil
end

function RichTextElement:__Delete()

end

function RichTextElement:SetKvData(kvData)
    self.kvData = kvData
end

function RichTextElement:GetTextSize(content)
    local template = self.richTextItem.richTextInfo.elementTemplate[self.elementType]
    return RichTextUtils.GetTextSize(content,template)
end

function RichTextElement:CreateText(content,appendHeight)
    local objects = {}
    local width,height = self:GetTextSize(content)
    local flag = self.richTextItem:CheckWidth(width)
    if flag then
        self.richTextItem:UpdateLineHeight(height)
        local obj = self.richTextItem:AddElementObj(self.elementType,width,height)
        table.insert(objects,{obj = obj,str = content})
    else
        local textList = StringUtils.SplitToTable(content)
        self:CreateTextList(textList,1,appendHeight,objects)
    end
    return objects
end

function RichTextElement:CreateTextList(textList,beginIndex,appendHeight,objects)
    local str = ""
    local widthTotal = 0
    local maxHeight = 0
    local flag = false

    local textListLenght = #textList
    for i = beginIndex,textListLenght do
        local curStr = textList[i]
        local width,height = self:GetTextSize(curStr)
        if self.richTextItem:CheckWidth(widthTotal + width) then
            str = str .. curStr
            widthTotal = widthTotal + width
            local heightTotal = height + appendHeight
            if heightTotal > maxHeight then
                maxHeight = heightTotal
            end

            beginIndex = i
            flag = true
        else
            break
        end
    end

    if maxHeight > 0 then
        self.richTextItem:UpdateLineHeight(maxHeight)
    end

    if str ~= "" then
        local obj = self.richTextItem:AddElementObj(self.elementType,widthTotal,maxHeight)
        table.insert(objects,{obj = obj,str = str})
    end

    if beginIndex < textListLenght or (beginIndex == textListLenght and not flag) then
        self.richTextItem:EnterNewLine()
        self:CreateTextList(textList,flag and beginIndex + 1 or beginIndex,appendHeight,objects)
    end
end

function RichTextElement:ParseData(kvData)
    self.kvData = kvData
    self:OnParseData(kvData)
end

function RichTextElement:OnParseData(kvData)
    assert(false,"解析富文本元素失败，子类未实现相应解析方法")
end

function RichTextElement:SetLogicElementType(logicElementType)
    self.logicElementType = logicElementType
end