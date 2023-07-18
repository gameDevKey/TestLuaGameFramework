VerticalLoopScrollView = Class("VerticalLoopScrollView", LoopScrollViewBase)

function VerticalLoopScrollView:OnInit()
    self.type = ELoopScrollView.Type.Vertical
end

function VerticalLoopScrollView:IsHorizontalDir()
    return false
end

function VerticalLoopScrollView:ScrollToItem(index, cbFinish, duration, ease, jumpType)
    jumpType = jumpType or ELoopScrollView.JumpType.Top
    index = index - 1
    index = MathUtil.Clamp(index, 0, #self.tbItemData)
    local y = self.setting.paddingTop
    for i = 1, index do
        y = y + self.tbItemData[i].size.h + self.setting.gapY
    end
    if index > 0 then
        if jumpType == ELoopScrollView.JumpType.Center then
            y = y - self.viewport.rect.height / 2 + self.tbItemData[index].size.h / 2
        elseif jumpType == ELoopScrollView.JumpType.Bottom then
            y = y - self.viewport.rect.height + self.tbItemData[index].size.h + self.setting.gapY
        end
    end
    self:ScrollToPosition(Vector2(self.content.localPosition.x, y), cbFinish, duration, ease)
end

function VerticalLoopScrollView:ScrollToPosition(pos, cbFinish, duration, ease)
    local x = pos.x
    local y = pos.y
    local maxH = self.content.rect.height - self.viewport.rect.height
    y = MathUtil.Clamp(y, 0, maxH)
    self:MoveTo(Vector3(x, y, 0), cbFinish, duration, ease)
end

function VerticalLoopScrollView:ScrollToPositionY(y, cbFinish, duration, ease)
    local pos = {}
    pos.x = self.content.localPosition.x
    pos.y = y
    self:ScrollToPosition(pos, cbFinish, duration, ease)
end

function VerticalLoopScrollView:UpdateContentSize()
    local h = self.setting.paddingTop
    local maxW = 0
    for i, data in ipairs(self.tbItemData or NIL_TABLE) do
        h = h + data.size.h + self.setting.gapY
        if data.size.w > maxW then
            maxW = data.size.w
        end
    end
    h = h + self.setting.paddingBottom
    local w = self.setting.paddingLeft + self.setting.paddingRight + maxW
    self:SetContentSize(w, h)
end

function VerticalLoopScrollView:UpdateList()
    --content上滑y值增大
    --Item越往下y越小
    local startPos = self.content.localPosition.y - self.setting.overflowUp --content的上界

    if startPos < 0 then startPos = 0 end

    local bottom = self.content.rect.height - self.viewport.rect.height --content的下界
    if startPos > bottom then startPos = bottom end

    local targetIndex = 1                   --起始索引
    local targetY = self.setting.paddingTop --起始坐标
    for i, data in ipairs(self.tbItemData or NIL_TABLE) do
        targetIndex = i
        local y = targetY + data.size.h
        if y >= startPos then
            break
        end
        targetY = y + self.setting.gapY
    end

    local itemX = self.setting.paddingLeft --self.content.localPosition.x
    local itemY = -targetY
    local limitHeight = self.viewport.rect.height + self.setting.overflowDown

    --先把不显示的回收，再生成
    local tempShowItems = self.tbShowingItem
    local tempDatas = {}
    self.tbShowingItem = {}

    for i = targetIndex, #self.tbItemData, 1 do
        local renderData = self.tbItemData[i]
        local insData = tempShowItems[renderData]
        if insData and insData.index == i then
            self.tbShowingItem[renderData] = tempShowItems[renderData]
            tempShowItems[renderData] = nil
        end

        local newItem = {}
        newItem.pos = Vector3(itemX, itemY, 0)
        newItem.index = i
        tempDatas[renderData] = newItem

        itemY = itemY - (renderData.size.h + self.setting.gapY)

        if -startPos - itemY >= limitHeight then
            break
        end
    end

    for _, insData in pairs(tempShowItems or NIL_TABLE) do
        self:TryRecycleItem(insData)
    end

    self:FixItemsStyleByShowingData(self.tbShowingItem, tempDatas)
end


return VerticalLoopScrollView