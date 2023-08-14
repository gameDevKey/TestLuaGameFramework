RichTextUtils = StaticClass("RichTextUtils")

function RichTextUtils.GetTextSize(content,textTemplate)
    textTemplate.textComponent.text = content
    return textTemplate.textComponent.preferredWidth,textTemplate.textComponent.preferredHeight
end