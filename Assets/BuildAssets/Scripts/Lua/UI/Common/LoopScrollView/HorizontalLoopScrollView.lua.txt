HorizontalLoopScrollView = Class("HorizontalLoopScrollView", LoopScrollViewBase)

function HorizontalLoopScrollView:OnInit()
    self.type = ELoopScrollView.Type.Horizontal
end

function HorizontalLoopScrollView:IsHorizontalDir()
    return true
end

function HorizontalLoopScrollView:ScrollToItem(index, cbFinish, duration, ease, jumpType)
    jumpType = jumpType or ELoopScrollView.JumpType.Top
    index = index - 1
    index = MathUtil.Clamp(index, 0, #self.tbItemData)
    local x = self.setting.paddingLeft
    for i = 1, index do
        x = x + self.tbItemData[i].size.w + self.setting.gapX
    end
    if index > 0 then
        if jumpType == ELoopScrollView.JumpType.Center then
            x = x - self.viewport.rect.width / 2 + self.tbItemData[index].size.w / 2
        elseif jumpType == ELoopScrollView.JumpType.Bottom then
            x = x - self.viewport.rect.width + self.tbItemData[index].size.w + self.setting.gapX
        end
    end
    self:ScrollToPosition(Vector2(-x, self.content.localPosition.y), cbFinish, duration, ease)
end

function HorizontalLoopScrollView:ScrollToPosition(pos, cbFinish, duration, ease)
    local x = pos.x
    local y = pos.y
    local maxW = self.viewport.rect.width - self.content.rect.width
    x = MathUtil.Clamp(x, maxW, 0)
    self:MoveTo(Vector3(x, y, 0), cbFinish, duration, ease)
end

function HorizontalLoopScrollView:UpdateContentSize()
    local w = self.setting.paddingLeft
    local maxH = 0
    for i, data in ipairs(self.tbItemData or NIL_TABLE) do
        w = w + data.size.w + self.setting.gapX
        if data.size.h > maxH then
            maxH = data.size.h
        end
    end
    w = w + self.setting.paddingRight
    local h = self.setting.paddingTop + self.setting.paddingBottom + maxH
    self:SetContentSize(w, h)
end

function HorizontalLoopScrollView:UpdateList()
    --content左滑x值减少
    --Item越往右x越大
    local startPos = -self.content.localPosition.x - self.setting.overflowUp --content的左界

    if startPos < 0 then startPos = 0 end

    local bottom = self.content.rect.width - self.viewport.rect.width --content的右界
    if startPos > bottom then startPos = bottom end

    local targetIndex = 1                    --起始索引
    local targetX = self.setting.paddingLeft --起始坐标
    for i, data in ipairs(self.tbItemData or NIL_TABLE) do
        targetIndex = i
        local x = targetX + data.size.w
        if x >= startPos then
            break
        end
        targetX = x + self.setting.gapX
    end

    local itemX = targetX
    local itemY = self.setting.paddingTop --self.content.localPosition.y
    local limitWidth = self.viewport.rect.width + self.setting.overflowDown

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

        itemX = itemX + (renderData.size.w + self.setting.gapX)

        if itemX - startPos >= limitWidth then
            break
        end
    end

    for _, insData in pairs(tempShowItems or NIL_TABLE) do
        self:TryRecycleItem(insData)
    end

    self:FixItemsStyleByShowingData(self.tbShowingItem, tempDatas)
end

return HorizontalLoopScrollView