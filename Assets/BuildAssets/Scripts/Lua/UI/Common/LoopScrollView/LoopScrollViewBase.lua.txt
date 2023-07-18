--[[
    无限滚动列表

    用法：
    1.New一个继承LoopScrollViewBase的类的实例，传入ScrollRect和Setting
    2.使用SetDatas/SetDataCount等数据接口设置数据
    3.调用Start接口启动
    4.使用Destroy接口释放
]]
--
LoopScrollViewBase = Class("LoopScrollViewBase")

function LoopScrollViewBase:OnInit(scrollRect, setting)
    self.tbItemData = {}    --List<{data:any, size:{w,h}}>  存储渲染数据
    self.tbShowingItem = {} --Dict<{data:any, size:{w,h}}, {data,index,obj,width,height}> 映射渲染数据和实体
    self.showingPool = {}   --List<{item:UIBase, holderRect:RectTransform}>  UIBase的使用池
    self.recyclePool = {}   --List<{item:UIBase, holderRect:RectTransform}>  UIBase的回收池
    self.moveTween = nil
    self.type = ELoopScrollView.Type.Unknown
    self:Init(scrollRect, setting)
end

function LoopScrollViewBase:OnDelete()
    for _, pool in pairs({ self.showingPool, self.recyclePool }) do
        for _, data in ipairs(pool) do
            if self.cbOnDeleteItem then
                self.cbOnDeleteItem(data.item)
            else
                data.item:RecycleOrDelete()
            end
            local holder = data.holderRect.gameObject
            if not UnityUtil.IsEmptyGameObject(holder) then
                UnityUtil.DestroyGameObject(holder)
            end
        end
    end
    self.tbItemData = nil
    self.tbShowingItem = nil
    self.showingPool = nil
    self.recyclePool = nil
end

local function GetSetting(setting)
    setting = setting or {}
    setting.paddingLeft = setting.paddingLeft or 0
    setting.paddingRight = setting.paddingRight or 0
    setting.paddingTop = setting.paddingTop or 0
    setting.paddingBottom = setting.paddingBottom or 0
    setting.gapX = setting.gapX or 0
    setting.gapY = setting.gapY or 0
    setting.maxRowNum = setting.maxRowNum or 0
    setting.maxColNum = setting.maxColNum or 0
    setting.itemWidth = setting.itemWidth or 0
    setting.itemHeight = setting.itemHeight or 0
    setting.alignType = setting.alignType or ELoopScrollView.AlignType.Top
    setting.overflowUp = setting.overflowUp or 0
    setting.overflowDown = setting.overflowDown or 0
    return setting
end

---组件初始化
--- # Setting
---  ## 基本参数
---     paddingLeft             左边距
---     paddingRight            右边距
---     paddingTop              上边距
---     paddingBottom           下边距
---     gapX                    水平间隔
---     gapY                    垂直间隔
---     itemWidth               Item的默认宽度
---     itemHeight              Item的默认高度
---     overflowUp              上界溢出多少(会影响视野范围内首个出现的Item的位置)
---     overflowDown            下界溢出多少(会影响视野范围内最后出现的Item的位置)
---     alignType               对齐模式(ELoopScrollView.AlignType)
---     maxColNum               最大列数(GridLoopScrollView中生效)
---     maxRowNum               最大行数(GridLoopScrollView中生效)
---     revertSibling           倒序排列在Hierarchy
---     ignoreOriginChild       是否无视在Content下原有的子物体
---  ## Item相关回调(Item继承UIBase)
---     onCreate                Item的创建回调(必要!)
---     onRender                Item的业务处理回调
---     onRecycle               Item的回收回调,默认调用Hide(显示区域外的Item会回收到池)
---     onDelete                Item的删除回调,默认调用RecycleOrDelete
---  ## 其他回调
---     onComplete              渲染完成回调(只有在第一次渲染列表完成时会调用)
---     onRenderNew             有新的Item被重新渲染时触发
---@param scrollRect ScrollRect 滚动组件
---@param setting table 配置
function LoopScrollViewBase:Init(scrollRect, setting)
    self.scrollRect = scrollRect
    self.setting = GetSetting(setting)

    self.viewport = self.scrollRect.viewport
    self.content = self.scrollRect.content

    ScrollRectExt.SetScroll(self.scrollRect,self:ToFunc("OnScroll"))

    self:AddOnItemCreateCallback(self.setting.onCreate)
    self:AddOnItemDeleteCallback(self.setting.onDelete)
    self:AddOnItemRenderCallback(self.setting.onRender)
    self:AddOnItemRecycleCallback(self.setting.onRecycle)
    self:AddOnListUpdateFinishCallback(self.setting.onComplete)
    self:AddOnNewItemRender(self.setting.onRenderNew)

    self.lastScrollVec = self.content.localPosition
    self.originChildCount = self.content.childCount
    self.enableHorizontal = self.scrollRect.horizontal
    self.enableVertical = self.scrollRect.vertical
end

---启动
function LoopScrollViewBase:Start()
    self:AdjuestContentAnchorAndPivot()
    self:OnDataChange()
end

---销毁
function LoopScrollViewBase:Destroy()
    self:Delete()
end

---创建回调
---@param callback function func(index, [data]) -- 返回一个继承自 UIBase 的对象
function LoopScrollViewBase:AddOnItemCreateCallback(callback)
    self.cbOnCreateItem = callback
end

---渲染回调
---@param callback function func(item, index, [data])
function LoopScrollViewBase:AddOnItemRenderCallback(callback)
    self.cbOnRenderItem = callback
end

---回收回调
---@param callback function func(item)
function LoopScrollViewBase:AddOnItemRecycleCallback(callback)
    self.cbOnRecycleItem = callback
end

---删除回调
---@param callback function func(item)
function LoopScrollViewBase:AddOnItemDeleteCallback(callback)
    self.cbOnDeleteItem = callback
end

---数据更新完成回调(只有在第一次渲染列表完成时会调用)
---@param callback function func()
function LoopScrollViewBase:AddOnListUpdateFinishCallback(callback)
    self.cbOnUpdateListFinish = callback
end

---有新的Item被重新渲染时触发
---@param callback function func()
function LoopScrollViewBase:AddOnNewItemRender(callback)
    self.cbOnNewItemRender = callback
end

function LoopScrollViewBase:CreateItemRoot()
    local item = UnityUtil.NewGameObject("ItemHolder")
    local rect = item:AddComponent(typeof(RectTransform))
    item.transform:SetParent(self.content)
    item.transform.localScale = Vector3.one
    UnityUtil.SetAnchorMinAndMax(item.transform, 0, 1, 0, 1)
    UnityUtil.SetPivot(item.transform, 0, 1)
    return rect
end

function LoopScrollViewBase:CreateItem(index, data)
    local item
    local holderRect
    if #self.recyclePool > 0 then
        local cache = table.remove(self.recyclePool)
        item = cache.item
        holderRect = cache.holderRect
    elseif self.cbOnCreateItem then
        holderRect = self:CreateItemRoot()
        item = self.cbOnCreateItem(index, data)
        assert(item ~= nil, "通过回调创建实例失败")
        local trans = item.gameObject and item.gameObject.transform
        assert(trans ~= nil, "实例没有Transform属性")
        local scale = trans.localScale
        trans:SetParent(holderRect)
        trans.localScale = scale
        UnityUtil.SetAnchoredPosition(trans, 0, 0)
    end
    if not item then
        PrintError("获取Item失败! Index:", index,
            "是否存在创建回调", (self.cbOnCreateItem ~= nil),
            "使用池缓存", #self.showingPool,
            "回收池缓存", #self.recyclePool)
        return
    end
    holderRect.gameObject:SetActive(true)
    table.insert(self.showingPool, { item = item, holderRect = holderRect })
    -- print("LoopScrollViewBase 创建对象",index,self,"激活池",#self.showingPool,"回收池",#self.recyclePool)
    return item, holderRect
end

function LoopScrollViewBase:OnRenderItem(item, index, data)
    if self.cbOnRenderItem then
        self.cbOnRenderItem(item, index, data)
    end
end

function LoopScrollViewBase:OnRecycleItem(item)
    if self.cbOnRecycleItem then
        self.cbOnRecycleItem(item)
    else
        item:Hide()
    end
end

function LoopScrollViewBase:OnScroll(vec)
    local cur = self.content.localPosition
    local dis = Vector3.Distance(cur, self.lastScrollVec)
    if dis > 5 then --降低灵敏度
        self.lastScrollVec = cur
        self:__UpdateList()
    end
end

function LoopScrollViewBase:OnDataChange()
    self:UpdateContentSize()
    self:__UpdateList()
end

function LoopScrollViewBase:OnUpdateListFinish()
    if self.cbOnUpdateListFinish then
        self.cbOnUpdateListFinish()
        self.cbOnUpdateListFinish = nil -- 只有在第一次渲染列表完成时会调用
    end
end

function LoopScrollViewBase:TryRenderItem(index, renderData)
    local item = {}
    local obj, holderRect = self:CreateItem(index, renderData)
    assert(obj, "创建Item失败")
    assert(holderRect, "获取挂载点Rect失败")
    item.obj = obj
    item.rectTransform = holderRect
    item.index = index
    item.data = renderData.data
    item.width = renderData.size.w
    item.height = renderData.size.h
    self.tbShowingItem[renderData] = item
    self:OnRenderItem(obj, index, renderData)
    return item
end

function LoopScrollViewBase:TryRecycleItem(insData)
    local index = insData.index
    local _item = insData.obj
    local rect = insData.rectTransform
    for _, data in ipairs(self.recyclePool or NIL_TABLE) do
        if data.item == _item then
            PrintError("对象被重复回收! Index:", index)
            return false
        end
    end
    for i = #self.showingPool, 1, -1 do
        local data = self.showingPool[i]
        if data.item == _item then
            table.remove(self.showingPool, i)
        end
    end
    rect.gameObject:SetActive(false)
    table.insert(self.recyclePool, { item = _item, holderRect = rect })
    self:OnRecycleItem(_item)
    -- print("LoopScrollViewBase 回收对象",index,self,"激活池",#self.showingPool,"回收池",#self.recyclePool)
    return true
end

function LoopScrollViewBase:ScrollToTop(cbFinish, duration, ease, jumpType)
    self:ScrollToItem(1, cbFinish, duration, ease, jumpType)
end

function LoopScrollViewBase:ScrollToBottom(cbFinish, duration, ease, jumpType)
    local index = 1
    if self.tbItemData then
        index = #self.tbItemData
    end
    self:ScrollToItem(index, cbFinish, duration, ease, jumpType)
end

function LoopScrollViewBase:MoveTo(vec3, cbFinish, duration, ease)
    self:__OnMoveComplete()
    duration = duration or 1
    self.moveTween = self.content:DOLocalMove(vec3, duration)
    if ease then self.moveTween:SetEase(ease) end
    local originInertia = self.scrollRect.inertia
    self.scrollRect.inertia = false
    self.moveTween:OnComplete(function()
        self.scrollRect.inertia = originInertia
        self:__OnMoveComplete()
        self:__UpdateList() --防止移动后没有触发OnScroll导致数据没有应用到表现层
        if cbFinish then cbFinish() end
    end)
    return self.moveTween
end

function LoopScrollViewBase:SetContentSize(w, h)
    self.content:SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, w)
    self.content:SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, h)
end

function LoopScrollViewBase:AdjuestContentAnchorAndPivot()
    local config = self:IsHorizontalDir() and ELoopScrollView.HorizontalAlignConfig or
        ELoopScrollView.VerticalAlignConfig
    local detail = config[self.setting.alignType]
    UnityUtil.SetAnchorMinAndMax(self.content,
        detail.anchors.minX, detail.anchors.minY,
        detail.anchors.maxX, detail.anchors.maxY)
    UnityUtil.SetPivot(self.content, detail.pivot.x, detail.pivot.y)
end

function LoopScrollViewBase:FixItemsStyleByShowingData(currentShowItems, nextShowItems)
    local items = {}
    local isRenderNew = false
    for renderData, data in pairs(nextShowItems) do
        local rect
        local obj
        local insData = currentShowItems[renderData]
        if insData and insData.index == data.index then
            rect = insData.rectTransform
            obj = insData.obj
        else
            local item = self:TryRenderItem(data.index, renderData)
            rect = item.rectTransform
            obj = item.obj
            isRenderNew = true
        end
        UnityUtil.SetAnchoredPosition(rect, data.pos.x, data.pos.y)
        rect:SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, renderData.size.w)
        rect:SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, renderData.size.h)
        obj.transform:SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, renderData.size.w)
        obj.transform:SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, renderData.size.h)
        table.insert(items, { rect = rect, index = data.index })
    end
    table.sort(items, function(a, b)
        if self.setting.revertSibling then
            return a.index > b.index
        end
        return a.index < b.index
    end)
    local startIndex = self.setting.ignoreOriginChild and 0 or self.originChildCount
    for i, item in ipairs(items) do
        item.rect:SetSiblingIndex(startIndex + i)
    end
    if isRenderNew then
        if self.cbOnNewItemRender then
            self.cbOnNewItemRender()
        end
    end
end

function LoopScrollViewBase:RangeRenderItem(callback, reverse)
    local list = {}
    for renderData, itemData in pairs(self.tbShowingItem or NIL_TABLE) do
        table.insert(list, itemData)
    end
    table.sort(list, function(a, b)
        if reverse then
            return a.index > b.index
        end
        return a.index < b.index
    end)
    for _, data in ipairs(list) do
        if callback(data) == true then
            break
        end
    end
end

function LoopScrollViewBase:GetRenderItemByDataIndex(index)
    for renderData, itemData in pairs(self.tbShowingItem or NIL_TABLE) do
        if itemData.index == index then
            return itemData
        end
    end
end

function LoopScrollViewBase:GetShowingItemAmount()
    return table.Count(self.tbShowingItem)
end

function LoopScrollViewBase:EnableScroll(enable)
    if enable then
        self.scrollRect.horizontal = self.enableHorizontal
        self.scrollRect.vertical = self.enableVertical
    else
        self.scrollRect.horizontal = false
        self.scrollRect.vertical = false
    end
end

--#region 数据相关

function LoopScrollViewBase:GetDefaultItemData(sc)
    sc = sc or {}
    sc.size = sc.size or { w = (self.setting.itemWidth or 0), h = (self.setting.itemHeight or 0) }
    return sc
end

---设置数据数量
---@param count integer
function LoopScrollViewBase:SetDataCount(count, notifyChange)
    count = count or 0
    local list = {}
    for i = 1, count do
        table.insert(list, {})
    end
    self:SetDatas(list, notifyChange)
end

---添加数据数量
---@param count integer
function LoopScrollViewBase:AddDataCount(count, notifyChange)
    count = count or 0
    for i = 1, count do
        local notify = notifyChange
        if i < count then
            notify = false
        end
        self:AddData(nil, notify)
    end
end

---设置一组数据
---@param list table List<{data:any, size:{w,h}}>
function LoopScrollViewBase:SetDatas(list, notifyChange)
    list = list or {}
    for i, data in ipairs(list) do
        list[i] = self:GetDefaultItemData(data)
    end
    self.tbItemData = list
    if notifyChange then
        self:OnDataChange()
    end
end

---添加数据
---@param sc table|nil {data:any, size:{w,h}}
function LoopScrollViewBase:AddData(sc, notifyChange)
    table.insert(self.tbItemData, self:GetDefaultItemData(sc))
    if notifyChange then
        self:OnDataChange()
    end
end

---移除数据
---@param index integer 下标
function LoopScrollViewBase:RemoveDataAt(index, notifyChange)
    table.remove(self.tbItemData, index)
    if notifyChange then
        self:OnDataChange()
    end
end

---移除数据
---@param func function func(data,index) 判定函数
function LoopScrollViewBase:RemoveDataByFunc(func, notifyChange)
    for i = #self.tbItemData, 1, -1 do
        local data = self.tbItemData[i]
        if func(data, i) then
            table.remove(self.tbItemData, i)
        end
    end
    if notifyChange then
        self:OnDataChange()
    end
end

---清除所有数据
function LoopScrollViewBase:ClearAllData(notifyChange)
    self.tbItemData = {}
    if notifyChange then
        self:OnDataChange()
    end
end

function LoopScrollViewBase:GetAllData()
    return self.tbItemData
end

--#endregion


--#region 虚方法

function LoopScrollViewBase:ScrollToItem(index, cbFinish, duration, ease, jumpType)
end

function LoopScrollViewBase:ScrollToPosition(pos, cbFinish, duration, ease)
end

function LoopScrollViewBase:UpdateContentSize()
end

function LoopScrollViewBase:UpdateList()
end

function LoopScrollViewBase:IsHorizontalDir() return false end

--#endregion


--#region 私有方法，不可重载

function LoopScrollViewBase:__UpdateList()
    self:UpdateList()
    self:OnUpdateListFinish()
end

function LoopScrollViewBase:__OnMoveComplete()
    if self.moveTween then
        self.moveTween:Kill()
        self.moveTween = nil
    end
end

--#endregion

return LoopScrollViewBase
