RichTextNormalText = BaseClass("RichTextNormalText",RichTextElement)

function RichTextNormalText:__Init()
    self.elementType = RichTextDefine.Element.rich_text
    self.content = nil
end

function RichTextNormalText:__Delete()
    
end

function RichTextNormalText:OnCreate()
    local r,g,b,a = nil,nil,nil,nil
    if self.color then
        r,g,b,a =  ColorUtils.HexToColorVal(self.color)
    end

    local objects = self:CreateText(self.content,0)
    for i,v in ipairs(objects) do
        local textComponent = v.obj.transform:Find("text").gameObject:GetComponent(Text)
        textComponent.text = v.str
        if self.color then
            textComponent:SetColor(r,g,b,a)
        end
    end
end

function RichTextNormalText:OnParseData(kvData)
    self.content = kvData["content"]
    self.color = self.richTextItem.richTextInfo.toColor[kvData["color"]] or kvData["color"]
end