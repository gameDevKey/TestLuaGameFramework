BaseTips = BaseClass("BaseTips",BaseView)

function BaseTips:__Init()
    self.data = nil
    self.tipsParent = nil
    self.tipsParentRect = nil
end

function BaseTips:__Delete()

end

function BaseTips:__BindListener()
    self:Find("bg",Button):SetClick(self:ToFunc("CloseClick"))
end

function BaseTips:SetData(data,parent)
    self.data = data
    self.tipsParent = parent
    self.tipsParentRect = parent.gameObject:GetComponent(RectTransform)
    self.needFixed = true
end

function BaseTips:AdaptionPos(rect)
    local size = self.tipsParentRect.rect
    local offsetX = 0
    local offsetY = -size.height
    self:FixedAnchorAndPivot(rect)
    rect.transform:SetParent(self.tipsParent)
    rect:SetAnchoredPosition(offsetX,offsetY)
    rect.transform:SetParent(self.transform,true)
    UIUtils.AdaptionScreen(rect)
end

--左上角为原点
function BaseTips:FixedAnchorAndPivot(rect)
    if self.needFixed and rect then
        self.needFixed = false
        UnityUtils.SetAnchorMinAndMax(rect.transform,0,1,0,1)
        UnityUtils.SetPivot(rect.transform,0,1)
    end
end

function BaseTips:CloseClick()
    self:Destroy()
end