RichTextNoneText = BaseClass("RichTextNoneText",RichTextElement)

function RichTextNoneText:__Init()
    self.elementType = RichTextDefine.Element.none_text
    self.content = nil
end

function RichTextNoneText:__Delete()
    
end

function RichTextNoneText:OnCreate()
    local objects = self:CreateText(self.content,0)
    for i,v in ipairs(objects) do
        v.obj.transform:Find("text").gameObject:GetComponent(Text).text = v.str
    end
end

function RichTextNoneText:OnParseData(kvData)
    self.content = kvData["content"]
end