--四叉树
QuadTreeNode = Class("QuadTreeNode")

function QuadTreeNode:OnInit(data)
    self.maxDepth = data.maxDepth
    self.capcity = data.capcity

    self.childNodes = {}
    self.objects = {}
    self.depth = data.depth
    self.rect = data.rect
end

function QuadTreeNode:OnDelete()
    for _, node in ipairs(self.childNodes) do
        node:Delete()
    end
    self.childNodes = nil
    self.objects = nil
end

--插入
function QuadTreeNode:Insert(rect)
    if not QuadTreeUtil.IsIntersect(self.rect, rect) then
        return false
    end
    local childAmount = #self.childNodes
    if childAmount > 0 then
        local side = self:SideOf(rect)
        if side ~= EQuadTree.Side.Unknown then
            return self.childNodes[side]:Insert(rect)
        end
    end
    table.insert(self.objects, rect)
    if childAmount == 0 and
        (self.maxDepth <= 0 or self.depth <= self.maxDepth) and
        (#self.objects > self.capcity) then
        self:Split()
    end
    return true
end

--分裂
function QuadTreeNode:Split()
    local halfWidth = self.rect.width / 2
    local halfHeight = self.rect.height / 2
    local midX = self.rect.x + halfWidth
    local midY = self.rect.y + halfHeight

    self.childNodes[EQuadTree.Side.LeftTop] = QuadTreeNode.New({
        maxDepth = self.maxDepth,
        capcity = self.capcity,
        depth = self.depth + 1,
        rect = QuadTreeUtil.CreateRect(self.rect.x, self.rect.y, halfWidth, halfHeight),
    })
    self.childNodes[EQuadTree.Side.LeftBottom] = QuadTreeNode.New({
        maxDepth = self.maxDepth,
        capcity = self.capcity,
        depth = self.depth + 1,
        rect = QuadTreeUtil.CreateRect(self.rect.x, midY, halfWidth, halfHeight),
    })
    self.childNodes[EQuadTree.Side.RightTop] = QuadTreeNode.New({
        maxDepth = self.maxDepth,
        capcity = self.capcity,
        depth = self.depth + 1,
        rect = QuadTreeUtil.CreateRect(midX, self.rect.y, halfWidth, halfHeight),
    })
    self.childNodes[EQuadTree.Side.RightBottom] = QuadTreeNode.New({
        maxDepth = self.maxDepth,
        capcity = self.capcity,
        depth = self.depth + 1,
        rect = QuadTreeUtil.CreateRect(midX, midY, halfWidth, halfHeight),
    })

    local tempObjects = self.objects
    self.objects = {}
    for _, object in ipairs(tempObjects) do
        self:Insert(object)
    end
end

function QuadTreeNode:_find(rect, result)
    if not QuadTreeUtil.IsIntersect(self.rect, rect) then
        return
    end
    for _, object in ipairs(self.objects) do
        if QuadTreeUtil.IsIntersect(rect, object) then
            table.insert(result, object)
        end
    end
    for _, child in ipairs(self.childNodes) do
        child:_find(rect, result)
    end

    -- if #self.childNodes > 0 then
    --     local side = self:SideOf(rect)
    --     if side == EQuadTree.Side.Unknown then
    --         --处于交界处，可能横跨多个象限
    --         PrintLog("处于交界处，可能横跨多个象限",rect)
    --         for i, child in ipairs(self.childNodes) do
    --             local inRect = QuadTreeUtil.GetIntersect(child.rect,rect)
    --             if inRect then
    --                 PrintLog(i,"象限裁剪",inRect)
    --                 child:_find(inRect, result)
    --             end
    --         end
    --     else
    --         --处于某个象限内，由象限所属节点递归去找
    --         PrintLog("处于某个象限内，由象限所属节点递归去找",side,rect)
    --         self.childNodes[side]:_find(rect, result)
    --     end
    -- else
    --     --叶子节点直接获取所有数据
    --     PrintLog("叶子节点直接获取所有数据",rect)
    --     for _, object in ipairs(self.objects) do
    --         table.insert(result, object)
    --     end
    -- end
end

--寻找rect覆盖的object
function QuadTreeNode:Find(rect)
    local result = {}
    self:_find(rect, result)
    return result
end

--判断目标矩形处于哪个象限，处于交界处不算
function QuadTreeNode:SideOf(rect)
    local midX = self.rect.x + self.rect.width / 2
    local midY = self.rect.y + self.rect.height / 2
    if rect.x + rect.width < midX and rect.y + rect.height < midY then
        return EQuadTree.Side.LeftTop
    end
    if rect.x + rect.width < midX and rect.y > midY then
        return EQuadTree.Side.LeftBottom
    end
    if rect.x > midX and rect.y + rect.height < midY then
        return EQuadTree.Side.RightTop
    end
    if rect.x > midX and rect.y > midY then
        return EQuadTree.Side.RightBottom
    end
    return EQuadTree.Side.Unknown
end

function QuadTreeNode:ToString()
    local datas = {}
    for _, object in ipairs(self.objects) do
        table.insert(datas, object.data or table.ToString(object))
    end
    return string.format("当前层级:%d 范围:[x=%s,y=%s,w=%s,h=%s] 数据:[%s]",
        self.depth, self.rect.x, self.rect.y, self.rect.width, self.rect.height, table.concat(datas, '\n'))
end

function QuadTreeNode:_log(result)
    table.insert(result, tostring(self))
    for _, child in ipairs(self.childNodes) do
        child:_log(result)
    end
end

function QuadTreeNode:Log()
    local msg = {}
    self:_log(msg)
    PrintLog(table.concat(msg, "\n"))
end

return QuadTreeNode
