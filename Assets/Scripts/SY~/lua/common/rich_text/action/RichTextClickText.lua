RichTextClickText = BaseClass("RichTextClickText",RichTextElement)

function RichTextClickText:__Init()
    self.elementType = RichTextDefine.Element.click_text
    self.content = nil
    self.color = nil
    self.lineSize = 0
end

function RichTextClickText:__Delete()

end

function RichTextClickText:OnCreate()
    local r,g,b,a = nil,nil,nil,nil
    if self.color then
        r,g,b,a =  ColorUtils.HexToColorVal(self.color)
    end

    local objects = self:CreateText(self.content,0)
    for i,v in ipairs(objects) do
        local textComponent = v.obj.transform:Find("text").gameObject:GetComponent(Text)
        textComponent.text = v.str
        v.obj.transform:Find("line"):SetSizeDelata(0,self.lineSize)
        v.obj.transform:Find("btn").gameObject:GetComponent(Button):SetClick(self:ToFunc("ClickText"),v.obj.transform)

        if self.color then
            textComponent:SetColor(r,g,b,a)
        end
    end
end

function RichTextClickText:ClickText(richTextTrans)
    if self.richTextItem.richTextInfo.onClick then
        self.richTextItem.richTextInfo.onClick(self.logicElementType,self.kvData,richTextTrans)--TODO 传obj的position用于新面板的起始位置
    end
end

function RichTextClickText:OnParseData(kvData)
    self.content = kvData["content"]
    self.color = self.richTextItem.richTextInfo.toColor[kvData["color"]] or kvData["color"]
    self.lineSize = tonumber(kvData["lineSize"] or 0)
end