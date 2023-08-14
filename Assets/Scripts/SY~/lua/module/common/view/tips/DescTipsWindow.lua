DescTipsWindow = BaseClass("DescTipsWindow",BaseWindow)
--TODO 传入父节点

function DescTipsWindow:__Init()
    self:SetAsset("ui/prefab/tips/desc_tips_window.prefab", AssetType.Prefab)
    self.notTempHide = true
end

function DescTipsWindow:__Delete()
end

function DescTipsWindow:__CacheObject()
    self.mainRectTrans = self:Find("main",RectTransform)
    self.tips = self:Find("main/tips")
    self.title = self:Find("main/tips/bg/title",Text)
    self.desc = self:Find("main/tips/bg/desc",Text)
    self.horn = self:Find("main/tips/horn")
end

function DescTipsWindow:__BindListener()
    self:Find("bg",Button):SetClick(self:ToFunc("OnCloseClick"))
end

function DescTipsWindow:OnCloseClick()
    ViewManager.Instance:CloseWindow(DescTipsWindow)
end

function DescTipsWindow:__Create()
    self.originWidth = self.tips.rect.width
    self.originHeight = self.tips.rect.height

    self.descMaxWidth = 566
end

--[[
    args = {
        parent:Transform
        tipsId:integer|nil
        title:string|nil
        content:string|nil
    }
]]--
function DescTipsWindow:__Show()
    local tipsText
    if self.args.tipsId then
        tipsText = Config.TipsTextData.data_terminology_info[self.args.tipsId]
    end

    local title = self.args.title or tipsText and tipsText.title or "请配置标题"
    local content = self.args.content or tipsText and tipsText.content or "请配置内容"
    local parent = self.args.parent or self.transParent

    self.title.text = TI18N(title)
    self.desc.text = TI18N(content)

    self.transform:SetParent(UIDefine.canvasRoot)
    self.transform:Reset()
    self.rootCanvas.sortingOrder = ViewManager.Instance:GetCurOrderLayer() + 10

    self:SetSizeAndPos(parent)
end

function DescTipsWindow:SetWidth(width)
    self.originWidth = width
    self:SetSizeAndPos(self.args.parent or self.transParent)
end

function DescTipsWindow:SetText(textId,parent)
    self.tipsText = Config.TipsTextData.data_terminology_info[textId]
    self.transParent = parent
end

function DescTipsWindow:SetSizeAndPos(parent)
    local descToWidth = self.descMaxWidth
    if self.desc.preferredWidth < self.descMaxWidth then
        descToWidth = self.desc.preferredWidth
    end

    UnityUtils.SetSizeDelata(self.desc.transform, descToWidth,0)
    local toWidth = self.originWidth - self.descMaxWidth + descToWidth
    local toHeight = self.originHeight + self.desc.preferredHeight
    UnityUtils.SetSizeDelata(self.tips, toWidth, toHeight)

    self.tips:SetParent(parent)
    self.tips:Reset()
    local transLocalPos = self.tips.localPosition
    UnityUtils.SetLocalPosition(self.tips, transLocalPos.x, 25, transLocalPos.z)

    local parentPos = parent.position
    local hornPos = self.horn.position
    UnityUtils.SetPosition(self.horn, parentPos.x, hornPos.y, hornPos.z)
    self.tips:SetParent(self.mainRectTrans)

    local anchoredPosition = self.tips.anchoredPosition
    local hornLocalPos = self.horn.localPosition
    local hornLocalAngles = self.horn.localEulerAngles

    -- 限制区域 (self.tips.rect.width/2 + 30) < x < GDefine.curScreenWidth - self.tips.rect.width/2 - 30
    local minX = self.tips.rect.width/2 + 30
    local maxX = GDefine.curScreenWidth - self.tips.rect.width/2 - 30
    local x = MathUtils.Clamp(anchoredPosition.x,minX,maxX)

    local hornOffsetX = 0
    if anchoredPosition.x < minX then
        hornOffsetX = - (minX - anchoredPosition.x)
    elseif anchoredPosition.x > maxX then
        hornOffsetX = anchoredPosition.x - maxX
    end

    local hornOffsetY = 0
    local rotateZ = hornLocalAngles.z
    local minY = - GDefine.curScreenHeight/2
    local maxY = GDefine.curScreenHeight/2 - self.tips.rect.height
    if anchoredPosition.y + self.tips.rect.height > maxY then
        maxY = anchoredPosition.y - self.tips.rect.height - 50
        rotateZ = 180
        hornOffsetY = self.tips.rect.height + 23
    elseif anchoredPosition.y < minY then
        minY = anchoredPosition.y + 50
    end
    local y = MathUtils.Clamp(anchoredPosition.y,minY,maxY)

    UnityUtils.SetAnchoredPosition(self.tips,x,y)
    UnityUtils.SetLocalPosition(self.horn, hornLocalPos.x + hornOffsetX, hornLocalPos.y + hornOffsetY, hornLocalPos.z)
    UnityUtils.SetLocalEulerAngles(self.horn, hornLocalAngles.x, hornLocalAngles.y, rotateZ)
end