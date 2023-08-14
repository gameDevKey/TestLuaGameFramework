RichTextItem = BaseClass("RichTextItem")

function RichTextItem:__Init(richTextInfo)
    self.richTextInfo = richTextInfo
    self.elements = nil
    self.gameObject = nil
    self.transform = nil
    self.curLine = 0
    self.curX = 0
    self.curY = 0
    self.curLineHeight = 0

    --每一行的信息
    --{beginY=0,height=0,objs={}}
    self.lineInfos = {}


    self:EnterNewLine()
    self:CreateRoot()
end

function RichTextItem:__Delete()
    if self.gameObject then
        GameObject.Destroy(self.gameObject)
        self.gameObject = nil
    end
end

function RichTextItem:CreateRoot()
    local richTextItem = GameObject("rich_text_item")
    richTextItem:AddComponent(RectTransform)
    richTextItem.transform:SetParent(self.richTextInfo.parent)
    richTextItem.transform:Reset()
    UnityUtils.SetAnchorMinAndMax(
        richTextItem.transform,
        self.richTextInfo.minX or 0.5,
        self.richTextInfo.minY or 0.5,
        self.richTextInfo.maxX or 0.5,
        self.richTextInfo.maxY or 0.5)
    UnityUtils.SetPivot(richTextItem.transform,self.richTextInfo.pivotX or 0.5, self.richTextInfo.pivotY or 0.5)
    richTextItem.transform:SetSizeDelata(self.richTextInfo.viewWidth,0)

    richTextItem:AddComponent(LayoutElement)

    self.gameObject = richTextItem
    self.transform = self.gameObject.transform
end

function RichTextItem:Create(elements)
    self.elements = elements
    for i,v in ipairs(self.elements) do
        v:OnCreate()
    end

    self.gameObject:GetComponent(LayoutElement).preferredHeight = self.transform.rect.height
end

function RichTextItem:EnterNewLine()
    self.curX = self.richTextInfo.paddingLeft
    if self.lineInfos[self.curLine] then
        self.curY = self.curY + self.lineInfos[self.curLine].height + self.richTextInfo.lineSpacing
    end

    self.curLine = self.curLine + 1
    local info = {}
    info.beginY = 0
    info.height = 0
    info.objs = {}
    table.insert(self.lineInfos,info)
end

function RichTextItem:AddElementObj(elementType,width,height)
    local original = self.richTextInfo.elementTemplate[elementType].original
    local object = GameObject.Instantiate(original)
    object.transform:SetParent(self.transform)
    object.transform:Reset()

    object.transform:SetParent(self.transform)
    object.transform:SetAnchoredPosition(self.curX + width * 0.5,-(self.curY + height * 0.5))
    object.transform:SetSizeDelata(width,height)

    local info = self.lineInfos[self.curLine]
    table.insert(info.objs,object)

    self.curX = self.curX + width

    return object
end

function RichTextItem:AddCurX(val)
    self.curX = self.curX + val
end

function RichTextItem:CheckWidth(width)
    local usableWidth = self.richTextInfo.viewWidth - self.curX - self.richTextInfo.paddingLeft - self.richTextInfo.paddingRight
    return width <= usableWidth
end

function RichTextItem:UpdateLineHeight(height)
    local info = self.lineInfos[self.curLine]
    if height > info.height then
        info.height = height
        self.transform:SetSizeDelata(self.richTextInfo.viewWidth,self.curY + info.height)
    end
end