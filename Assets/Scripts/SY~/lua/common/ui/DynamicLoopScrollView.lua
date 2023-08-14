DynamicLoopScrollView = BaseClass("DynamicLoopScrollView")

DynamicLoopScrollView.StartCorner = 
{
    top = 1,
    bottom = 2,
    left = 3,
    right = 4,
}

local ReplaceDir =
{
    top = 1,
    bottom = 2,
}

local Axis = 
{
    Vertical = 1,
    Horizontal = 2,
}

local RectTransInfo =
{
    [DynamicLoopScrollView.StartCorner.top] = 
    {
        minX=0,minY=1,maxX=1,maxY=1,pivotX=0.5,pivotY=1
    },
    [DynamicLoopScrollView.StartCorner.bottom] = 
    {
        minX=0,minY=0,maxX=1,maxY=0,pivotX=0.5,pivotY=0
    },
    [DynamicLoopScrollView.StartCorner.left] = 
    {
        minX=0,minY=0,maxX=0,maxY=1,pivotX=0,pivotY=0.5
    },
    [DynamicLoopScrollView.StartCorner.right] = 
    {
        minX=1,minY=0,maxX=1,maxY=1,pivotX=1,pivotY=0.5
    },
}

function DynamicLoopScrollView:__Init(setting)
    self.setting = setting
    self:Init()
end

function DynamicLoopScrollView:__Delete()
    self:RecycleItem()
    for i,v in ipairs(self.loopItemPool) do
        if v.view then
            self.onClear(v.view)
        end
    end
end

function DynamicLoopScrollView:CacheObject()
    
end

function DynamicLoopScrollView:Init()
    self.startCorner =  self.setting.startCorner or DynamicLoopScrollView.StartCorner.top
    self.spacingX = self.setting.spacingX or 0
    self.spacingY = self.setting.spacingY or 0
    self.paddingLeft = self.setting.paddingLeft or 0
    self.paddingTop = self.setting.paddingTop or 0

    self.minCellSizeX = self.setting.minCellSizeX or 0
    self.minCellSizeY = self.setting.minCellSizeY or 0

    self.onReplace = self.setting.onReplace
    self.onCreate = self.setting.onCreate
    self.cloneItem = self.setting.cloneItem

    self.onClear = self.setting.onClear

    local rootTrans = self.setting.root.transform
    self.contentTrans = self.setting.content or rootTrans:Find("content")

    local transInfo = RectTransInfo[self.startCorner]
    UnityUtils.SetAnchorMinAndMax(self.contentTrans,transInfo.minX,transInfo.minY,transInfo.maxX,transInfo.maxY)
    UnityUtils.SetPivot(self.contentTrans,transInfo.pivotX,transInfo.pivotY)
    UnityUtils.SetAnchoredPosition(self.contentTrans,0,0)
    UnityUtils.SetSizeDelata(self.contentTrans,0,0)

    local scrollRect = rootTrans.gameObject:GetComponent(ScrollRect)
    scrollRect:SetValueChanged(self:ToFunc("OnValueChanged"))
    self.scrollRect = scrollRect


    self.viewSizeX = self.setting.viewSizeX or rootTrans.rect.width
    self.viewSizeY = self.setting.viewSizeY or rootTrans.rect.height

    self.axis = nil
    self:InitAxis()

    local pageItemNum = math.ceil(self.calViewSize / (self.calMinCellSize + self.calSpacing))
    self.loopItemNum = self.setting.loopItemNum or pageItemNum + 3

    self.loopItemPool = {}
    self.loopItems = {}

    self.itemNum = 0
    self.itemInfos = {}



    self:CreateLoopItems()

    self.isStart = false

    self.firstIndex = 0
    self.lastIndex = 0

    self.firstReplacePos = 0
    self.lastReplacePos = 0

    self.firstPos = 0
    self.lastPos = 0
end

function DynamicLoopScrollView:InitAxis()
    if self.startCorner == DynamicLoopScrollView.StartCorner.top then
        self.axis = Axis.Vertical
    elseif self.startCorner == DynamicLoopScrollView.StartCorner.bottom then
        self.axis = Axis.Vertical
    elseif self.startCorner == DynamicLoopScrollView.StartCorner.left then
        self.axis = Axis.Horizontal
    elseif self.startCorner == DynamicLoopScrollView.StartCorner.right then
        self.axis = Axis.Horizontal
    end

    if self.axis == Axis.Vertical then
        self.calViewSize = self.viewSizeY
        self.calMinCellSize = self.minCellSizeY
        self.calSpacing = self.spacingY
    elseif self.axis == Axis.Horizontal then
        self.calViewSize = self.viewSizeX
        self.calMinCellSize = self.minCellSizeX
        self.calSpacing = self.spacingX
    end
end

function DynamicLoopScrollView:OnValueChanged()
    if not self.isStart then return end
    if self.itemNum <= self.loopItemNum then return end

    local flag,dir,_,_ = self:IsReplace()
    if not flag then return end

    if dir == -1 then
        self:ReplaceFirst()
    elseif dir == 1 then
        self:ReplaceLast()
    end

    self:UpdateContentSize()
    self:OnValueChanged()
end

--return 是否替换,方向
function DynamicLoopScrollView:IsReplace()
    local viewPos = self.contentTrans.anchoredPosition
    local pos = self.axis == Axis.Vertical and viewPos.y or viewPos.x

    local viewFirstPos = 0
    local viewLastPos = 0

    if self.startCorner == DynamicLoopScrollView.StartCorner.top then
        viewFirstPos = pos
    elseif self.startCorner == DynamicLoopScrollView.StartCorner.bottom then
        viewFirstPos = -pos
    elseif self.startCorner == DynamicLoopScrollView.StartCorner.left then
        viewFirstPos = pos
    elseif self.startCorner == DynamicLoopScrollView.StartCorner.right then
        viewFirstPos = -pos
    end

    viewLastPos = viewFirstPos + self.calViewSize

    if self.firstIndex > 1 and viewFirstPos <= self.firstReplacePos then
        return true,-1,0,0
    elseif self.lastIndex < self.itemNum and viewLastPos >= self.lastReplacePos then
        return true,1,0,0
    else
        return false,0,self.firstReplacePos - viewFirstPos,self.lastReplacePos - viewLastPos
    end
end

function DynamicLoopScrollView:CreateLoopItems()
    local transInfo = RectTransInfo[self.startCorner]
    for i = 1,self.loopItemNum do
        local item = GameObject()
        item.name = "#item"
        item.transform:SetParent(self.contentTrans,false)

        item:AddComponent(RectTransform)
        -- item:AddComponent(Image)
        
        UnityUtils.SetAnchorMinAndMax(item.transform,transInfo.minX,transInfo.minY,transInfo.maxX,transInfo.maxY)
        UnityUtils.SetPivot(item.transform,transInfo.pivotX,transInfo.pivotY)

        UnityUtils.SetAnchoredPosition(item.transform,0,0)
        UnityUtils.SetSizeDelata(item.transform,0,0)

        item:SetActive(false)

        local itemData = {}
        itemData.node = item
        itemData.trans = item.transform
        itemData.pos = 0
        itemData.size = 0

        table.insert(self.loopItemPool,itemData)
    end
end

function DynamicLoopScrollView:Start()
    self.isStart = true

    self.firstIndex = 1
    self.lastIndex = 0

    self.firstReplacePos = 0
    self.lastReplacePos = 0

    self.firstPos = 0
    self.lastPos = 0

    local startNum = self.itemNum <= self.loopItemNum and self.itemNum or self.loopItemNum
    for i=1,startNum do self:AppendLast() end
    self:UpdateContentSize()
end

function DynamicLoopScrollView:Reset()
    self.isStart = false
    self:RecycleItem()
    UnityUtils.SetAnchoredPosition(self.contentTrans,0,0)
    self:Start()
end

function DynamicLoopScrollView:LastStart()
    self.isStart = true

    self.firstIndex = 1
    self.lastIndex = 0

    self.firstReplacePos = 0
    self.lastReplacePos = 0

    self.firstPos = 0
    self.lastPos = 0

    if self.itemNum <= 0 then return end

    local startNum = self.itemNum <= self.loopItemNum and self.itemNum or self.loopItemNum
    local firstIndex = self.itemNum - startNum + 1

    self:InitLoop(firstIndex)
    for i=1,startNum - 1 do self:AppendLast() end

    self:UpdateContentSize()

    local itemIndex = self.itemNum - self.firstIndex + 1

    local item = self.loopItems[itemIndex]

    local pos = item.pos

    if pos + self.calViewSize > self.lastPos then
        pos = self.lastPos - self.calViewSize
    end

    if pos < 0 then
        pos = 0
    end

    self:SetContentPos(pos)
end

function DynamicLoopScrollView:ReplaceFirst()
    local item = self.loopItems[self.loopItemNum]
    table.remove(self.loopItems,self.loopItemNum)

    local info = self.itemInfos[self.lastIndex]
    self.lastPos = self.lastPos - info.size - self.calSpacing

    self.firstIndex = self.firstIndex - 1
    self.lastIndex = self.lastIndex - 1

    local info = self.itemInfos[self.firstIndex]
    self.firstPos = self.firstPos - info.size - self.calSpacing

    item.pos = self.firstPos
    item.size = info.size
    self:SetItem(item,self.firstIndex,0)

    table.insert(self.loopItems,1,item)
   
    self:UpdateReplacePos()
    self:OnReplace(self.firstIndex,item)

    --Log("firstIndex",self.firstIndex)
    --Log("lastIndex",self.lastIndex)
end

function DynamicLoopScrollView:ReplaceLast()
    local item = self.loopItems[1]
    table.remove(self.loopItems,1)

    local info = self.itemInfos[self.firstIndex]
    self.firstPos = self.firstPos + self.calSpacing + info.size

    self.firstIndex = self.firstIndex + 1
    self.lastIndex = self.lastIndex + 1

    local info = self.itemInfos[self.lastIndex]
    self.lastPos = self.lastPos + self.calSpacing + info.size

    item.pos = self.lastPos - info.size
    item.size = info.size
    self:SetItem(item,self.lastIndex,-1)

    table.insert(self.loopItems,item)

    self:UpdateReplacePos()
    self:OnReplace(self.lastIndex,item)

    --Log("firstIndex",self.firstIndex)
    --Log("lastIndex",self.lastIndex)
end

function DynamicLoopScrollView:AppendFirst()
    local item = self:GetItem()
    item.node:SetActive(true)

    self.firstIndex = self.firstIndex - 1
    local info = self.itemInfos[self.firstIndex]

    local calSpacing = self.firstIndex ~= 1 and self.calSpacing or 0

    self.firstPos = self.firstPos - calSpacing - info.size

    item.pos = self.firstPos
    item.size = info.size
    self:SetItem(item,self.firstIndex,0)

    table.insert(self.loopItems,1,item)

    self:UpdateReplacePos()
    self:OnReplace(self.firstIndex,item)
end

function DynamicLoopScrollView:AppendLast()
    local item = self:GetItem()
    item.node:SetActive(true)

    self.lastIndex = self.lastIndex + 1
    local info = self.itemInfos[self.lastIndex]

    local calSpacing = self.lastIndex ~= 1 and self.calSpacing or 0

    self.lastPos = self.lastPos + calSpacing + info.size

    item.pos = self.lastPos - info.size
    item.size = info.size
    self:SetItem(item,self.lastIndex,-1)

    table.insert(self.loopItems,item)

    self:UpdateReplacePos()
    self:OnReplace(self.lastIndex,item)
end

function DynamicLoopScrollView:SetItem(item,index,siblingIndex)
    if self.startCorner == DynamicLoopScrollView.StartCorner.top then
        UnityUtils.SetAnchoredPosition(item.trans,0,-item.pos)
    elseif self.startCorner == DynamicLoopScrollView.StartCorner.bottom then
        UnityUtils.SetAnchoredPosition(item.trans,0,item.pos)
    elseif self.startCorner == DynamicLoopScrollView.StartCorner.left then
    elseif self.startCorner == DynamicLoopScrollView.StartCorner.right then
    end

    if self.axis == Axis.Vertical then
        UnityUtils.SetSizeDelata(item.trans,0,item.size)
    elseif self.axis == Axis.Horizontal then
        UnityUtils.SetSizeDelata(item.trans,item.size,0)
    end

    item.node.name = index
    item.trans:SetSiblingIndex(siblingIndex)
end

function DynamicLoopScrollView:SetContentPos(pos)
    if self.startCorner == DynamicLoopScrollView.StartCorner.top then
        UnityUtils.SetAnchoredPosition(self.contentTrans,0,pos)
    elseif self.startCorner == DynamicLoopScrollView.StartCorner.bottom then
        UnityUtils.SetAnchoredPosition(self.contentTrans,0,pos)
    elseif self.startCorner == DynamicLoopScrollView.StartCorner.left then
    elseif self.startCorner == DynamicLoopScrollView.StartCorner.right then
    end
end

function DynamicLoopScrollView:GetContentPos()
    if self.startCorner == DynamicLoopScrollView.StartCorner.top then
        return self.contentTrans.anchoredPosition.y
    elseif self.startCorner == DynamicLoopScrollView.StartCorner.bottom then
        return -self.contentTrans.anchoredPosition.y
    elseif self.startCorner == DynamicLoopScrollView.StartCorner.left then
    elseif self.startCorner == DynamicLoopScrollView.StartCorner.right then
    end
end

function DynamicLoopScrollView:UpdateReplacePos()
    if self.itemNum <= 0 then
        self.firstReplacePos = 0
        self.lastReplacePos = 0
        return
    end

    local info = self.itemInfos[self.firstIndex]
    local firstSize = info.size

    local info = self.itemInfos[self.lastIndex]
    local lastSize = info.size

    self.firstReplacePos = self.firstPos + firstSize
    self.lastReplacePos = self.lastPos - lastSize

    --Log("firstReplacePos",self.firstReplacePos)
    --Log("lastReplacePos",self.lastReplacePos)
end

function DynamicLoopScrollView:UpdateContentSize()
    if self.axis == Axis.Vertical then
        UnityUtils.SetSizeDelata(self.contentTrans,0,self.lastPos)
    elseif self.axis == Axis.Horizontal then
        UnityUtils.SetSizeDelata(self.contentTrans,self.lastPos,0)
    end
end

function DynamicLoopScrollView:OnReplace(index,item)
    if not self.onReplace then return end
    local info = self.itemInfos[index]
    self.onReplace(index,item,info.param)
end

function DynamicLoopScrollView:AddItem(itemInfo)
    table.insert(self.itemInfos,itemInfo)
    self.itemNum = self.itemNum + 1

    if not self.isStart then
        return
    end

    if self.itemNum <= self.loopItemNum then
        self:AppendLast()
        self:UpdateContentSize()
    else
        self:OnValueChanged()
    end
end

function DynamicLoopScrollView:InsertItem(index,itemInfo)

end

function DynamicLoopScrollView:RemoveItem(index)
    if index == -1 then index = #self.itemInfos end

    local info = self.itemInfos[index]
    if not info then return end

    self.itemNum = self.itemNum - 1
    table.remove(self.itemInfos,index)

    --删除的索引，超过最后的显示索引，不用管
    if index > self.lastIndex then
        return
    end

    local contentPos = self:GetContentPos()

    local maxViewSize = contentPos + self.calViewSize
    local halfViewPos = contentPos + self.calViewSize * 0.5

    local subSize = 0
    
    local itemIndex = index - self.firstIndex + 1
    local removeItem = self.loopItems[itemIndex]

    local oldFirstIndex = self.firstIndex

    if self.itemNum <= 0 then
        self.firstIndex = 1
        self.lastIndex = 0
        self.firstPos = 0
        self.lastPos = 0
        table.remove(self.loopItems,itemIndex)
    elseif index < self.firstIndex then
        self.firstIndex = self.firstIndex - 1
        self.lastIndex = self.lastIndex - 1
        subSize = self.calSpacing + info.size
        self.firstPos = self.firstPos - subSize
        self.lastPos = self.lastPos - subSize
        itemIndex = 1
    else
        self.lastIndex = self.lastIndex - 1
        subSize = self.calSpacing + info.size
        self.lastPos = self.lastPos - subSize
        table.remove(self.loopItems,itemIndex)
    end

    local isKeep = false
    if index < oldFirstIndex then
        isKeep = true
       --Log("删除在视图上面的item")
    elseif removeItem and removeItem.pos + removeItem.size <= contentPos then
        isKeep = true
    elseif removeItem and removeItem.pos >= maxViewSize then
        isKeep = false
        --Log("删除在视图下面的item")
    elseif removeItem and removeItem.pos >= halfViewPos then
        isKeep = false
        --Log("删除在视图中间的item,并且偏下")
    elseif removeItem and removeItem.pos + removeItem.size <= halfViewPos then
        isKeep = true
        --Log("删除在视图中间的item,并且偏上")
    else
        isKeep = false
        --Log("删除在视图中间的item,并且横跨中间")
    end

    for i=itemIndex,#self.loopItems do
        local item =  self.loopItems[i]
        item.pos = item.pos - subSize
        self:SetItem(item,self.firstIndex+(i-1),i-1)
    end

    self:UpdateContentSize()
    self:UpdateReplacePos()

    if isKeep then
        local pos = contentPos
        if self.lastPos < maxViewSize then
            pos = contentPos - (maxViewSize - self.lastPos)
        else
            pos = contentPos - subSize
        end

        if pos < 0 then 
            pos = 0 
        end

        self:SetContentPos(pos)
    else
        local pos = contentPos
        if self.lastPos < maxViewSize then
            pos = contentPos - (maxViewSize - self.lastPos)
        end

        if pos < 0 then
            pos = 0
        end

        self:SetContentPos(pos)
    end

    if removeItem then
        removeItem.node:SetActive(false)
        table.insert(self.loopItemPool,removeItem)
        removeItem.node.name = "#item"
        self:CheckReplace()
    end
end

function DynamicLoopScrollView:CheckReplace()
    --if self.itemNum <= self.loopItemNum then Log("这里被返回了") return end

    if self.firstIndex == 1 and self.lastIndex == self.itemNum then
        return
    end

    local flag,dir,offsetFirst,offsetLast = self:IsReplace()

    if flag and dir == -1 then
        self:AppendFirst()
    elseif flag and dir == 1 then
        self:AppendLast()
    elseif self.firstIndex == 1 then --起始索引为1,还有存在没显示的
        self:AppendLast()
    elseif self.lastIndex == self.itemNum and self.firstIndex > 1 then --结束索引在末尾了,起始索引 > 1
        self:AppendFirst()
    elseif math.abs(offsetFirst) < math.abs(offsetLast) then
        self:AppendFirst()
    elseif math.abs(offsetLast) < math.abs(offsetFirst) then
        self:AppendLast()
    end

    self:UpdateContentSize()
end

function DynamicLoopScrollView:Jump(index)
    if self.itemNum <= 0 then
        return
    end

    if index == -1 then 
        index = self.itemNum
    end

    if index < 1 or index > self.itemNum then
        return
    end

    if self.lastIndex == self.itemNum and self.lastPos <= self.calViewSize then
        return
    end

    if self.itemNum > self.loopItemNum then
        local firstIndex = index - 1
        if firstIndex < 1 then firstIndex = 1 end

        if firstIndex + self.loopItemNum > self.itemNum then
            firstIndex = self.itemNum - self.loopItemNum + 1
        end

        self:RecycleItem()
        self:InitLoop(firstIndex)
        for i=1,self.loopItemNum - 1 do self:AppendLast() end
        self:UpdateContentSize()
    end

    local itemIndex = index - self.firstIndex + 1

    local item = self.loopItems[itemIndex]

    local pos = item.pos

    if pos + self.calViewSize > self.lastPos then
        pos = self.lastPos - self.calViewSize
    end

    if pos < 0 then
        pos = 0
    end

    self:SetContentPos(pos)
end

function DynamicLoopScrollView:InitLoop(index)
    self.firstIndex = index
    self.lastIndex = index
    local topPos,bottomPos = self:GetPos(index)

    self.firstPos = topPos
    self.firstReplacePos = bottomPos

    self.lastPos = bottomPos
    self.lastReplacePos = topPos

    --LogFormat("初始化循环[firstIndex:%s][lastIndex:%s][firstPos:%s][firstReplacePos:%s][lastPos:%s][lastReplacePos:%s]",
    --self.firstIndex,self.lastIndex,self.firstPos,self.firstReplacePos,self.lastPos,self.lastReplacePos)

    local item = self:GetItem()
    item.node:SetActive(true)

    local info = self.itemInfos[index]

    item.pos = self.firstPos
    item.size = info.size
    self:SetItem(item,index,0)

    table.insert(self.loopItems,item)

    self:UpdateReplacePos()
    self:OnReplace(self.firstIndex,item)
end

function DynamicLoopScrollView:GetItem()
    local item = self.loopItemPool[1]

    if not item.view and self.onCreate then
        item.view = self.onCreate(item.node.transform,self.cloneItem)
    end

    table.remove(self.loopItemPool,1)
    return item
end

function DynamicLoopScrollView:GetPos(index)
    if index <= 0 or index > self.itemNum then
        return nil
    end

    local pos = 0
    for i=2,index do
        pos = pos + self.itemInfos[i-1].size + self.calSpacing
    end

    return pos,pos + self.itemInfos[index].size
end

function DynamicLoopScrollView:RecycleItem()
    for i,item in ipairs(self.loopItems) do
        item.node:SetActive(false)
        item.node.name = "#item"
        table.insert(self.loopItemPool,item)
    end
    self.loopItems = {}
end

function DynamicLoopScrollView:JumpByPos()
    
end

function DynamicLoopScrollView:RemoveRangeItem(beginIndex,endIndex)

end

function DynamicLoopScrollView:IsFirst()
    if self.firstIndex ~= 1 then
        return false
    end

    if self.lastPos <= self.calViewSize then
        return true
    end

     --因为是浮点数,加个0.5的偏差
    return self:GetContentPos() <= 0.5
end

function DynamicLoopScrollView:IsLast()
    if self.lastIndex ~= self.itemNum then
        return false
    end

    if self.lastPos <= self.calViewSize then
        return true
    end

    local bottomPos = self:GetContentPos() + self.calViewSize

    --因为是浮点数,加个0.5的偏差
    return bottomPos >= self.lastPos - 0.5
end

function DynamicLoopScrollView.Test()
    local setting = {}
    setting.root = GameObject.Find("CanvasContainer/test")
    setting.startCorner = DynamicLoopScrollView.StartCorner.top
    setting.spacingX = 0
    setting.spacingY = 5
    setting.minCellSizeY = 50
    setting.content = setting.root.transform:Find("Viewport/Content")
    setting.onReplace = self:ToFunc("xxx") --index,item,info.param
    -- setting.onCreate = self:ToFunc("xxx") --item.node.transform
    -- setting.cloneItem = xxx
    --setting.onClear = self:ToFunc("xxx") --item.view


    local loopScrollView  = DynamicLoopScrollView.New(setting)
    loopScrollView:AddItem({size = 40})
    loopScrollView:AddItem({size = 30})
    loopScrollView:AddItem({size = 80})
    loopScrollView:AddItem({size = 50})
    loopScrollView:AddItem({size = 100})
    loopScrollView:AddItem({size = 60})
    loopScrollView:AddItem({size = 150})
    loopScrollView:AddItem({size = 60})
    loopScrollView:AddItem({size = 50})
    loopScrollView:AddItem({size = 150})
    loopScrollView:AddItem({size = 50})
    loopScrollView:AddItem({size = 50})
    loopScrollView:AddItem({size = 50})
    loopScrollView:AddItem({size = 250})
    loopScrollView:AddItem({size = 50})
    loopScrollView:AddItem({size = 50})

    loopScrollView:Start()

    Updater:AddUpdate(function()
        if Input.GetKeyDown(KeyCode.Space) then
            loopScrollView:RemoveItem(2)
        end

        if Input.GetKeyDown(KeyCode.Y) then
            loopScrollView:RemoveItem(21)
        end

        if Input.GetKeyDown(KeyCode.A) then
            loopScrollView:AddItem({size = math.random(50,200)})
        end

        if Input.GetKeyDown(KeyCode.D) then
            local index = math.random(1,loopScrollView.itemNum)
            Log("删除索引",index)
            loopScrollView:RemoveItem(index)
        end
    end, "DynamicLoopScrollView.Test")
end