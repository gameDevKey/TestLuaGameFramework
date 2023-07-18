RedPointManager = SingletonClass("RedPointManager")

function RedPointManager:OnInit()
    self.tbAllRedPoint = {}
    setmetatable(self.tbAllRedPoint, { __mode = "kv" }) --弱引用表，collectgarbage()之后会自动清除无效引用
end

function RedPointManager:OnDelete()
    for nodeId, node in pairs(self.tbAllRedPoint) do
        node:Delete()
    end
end

---创建节点
---@param nodeId string 节点唯一ID，不能重名
---@param parentNode RedPointNode 父节点
---@param callback function 回调
function RedPointManager:CreateNode(nodeId, parentNode, callback)
    local node = self.tbAllRedPoint[nodeId] or RedPointNode.New(nodeId)
    node:SetParent(parentNode)
    node:AddOnStateChangeListener(callback)
    self.tbAllRedPoint[nodeId] = node
    return node
end

function RedPointManager:CreateSubTree(treeData, parentNode)
    local node = self:CreateNode(treeData.Id, parentNode, treeData.Callback)
    for _, childData in pairs(treeData.Children or NIL_TABLE) do
        self:CreateSubTree(childData, node)
    end
    return node
end

---根据红点树数据构建红点数
---@param data RedPointTreeData 红点树数据 Id/Callback/Children
-- RedPointTreeData = {
--     Id = string,
--     Callback = function,
--     Children = {
--         {Id = string, Callback = function, Children = {}},
--         {Id = string, Callback = function, Children = {}},
--     }
-- }
function RedPointManager:CreateTree(data)
    return self:CreateSubTree(data)
end

---获取某个节点
---@param nodeId string 节点ID
---@return RedPointNode
function RedPointManager:GetNode(nodeId)
    return self.tbAllRedPoint[nodeId]
end

return RedPointManager
