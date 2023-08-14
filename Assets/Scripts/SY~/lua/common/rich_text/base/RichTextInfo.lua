RichTextInfo = BaseClass("RichTextInfo")

function RichTextInfo:__Init()
    self.content = nil
    --self.fontName = nil
    --self.fontSize = nil
    self.lineSpacing = 0
    self.viewWidth = 0
    --self.viewHeight = 0
    self.elementTemplate = nil
    self.startCorner = RichTextDefine.StartCorner.left_top
    self.parent = nil

    self.paddingTop = 0
    self.paddingBottom = 0
    self.paddingLeft = 0
    self.paddingRight = 0

    self.onClick = nil

    self.toColor = {}
end

function RichTextInfo:__Delete()

end