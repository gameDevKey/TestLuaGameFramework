QuadTree = Class("QuadTree")

---初始化
---@param data table {maxDepth,capcity,depth,rect}
function QuadTree:OnInit(data)
    self.data = data
    self.tree = QuadTreeNode.New(data)
end

function QuadTree:OnDelete()
    self.data = nil
    self.tree:Delete()
end

---插入
---@param rect table {width,height,x,y,data}
function QuadTree:Insert(rect)
    self.tree:Insert(rect)
end

--查找范围内物体
---@param rect table {width,height,x,y}
---@return List<rect> result
function QuadTree:Find(rect)
    return self.tree:Find(rect)
end

function QuadTree:Log()
    return self.tree:Log()
end

return QuadTree
