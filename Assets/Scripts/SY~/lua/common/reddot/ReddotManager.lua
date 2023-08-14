ReddotManager = SingleClass("ReddotManager")

function ReddotManager:__Init()
    self.tbAllRedPoint = {} --map[nodeId]node
    -- setmetatable(self.tbAllRedPoint,{__mode = "v"}) --弱引用表，collectgarbage()之后会自动清除无效引用
end

function ReddotManager:__Delete()
    self.tbAllRedPoint = nil
end

---创建节点
---@param nodeId string|nil 节点唯一ID,不能重名
---@param parentNode ReddotNode 父节点
---@param callback function 回调
function ReddotManager:CreateNode(nodeId,parentNode,callback)
    local node = ReddotNode.New(nodeId)
    node:SetParent(parentNode)
    node:AddOnStateChangeListener(callback)
    self.tbAllRedPoint[node:GetId()] = node
    return node
end

function ReddotManager:CreateSubTree(treeData, parentNode)
    local node = self:CreateNode(treeData.Id, parentNode, treeData.Callback)
    for _, childData in pairs(treeData.Children or {}) do
        self:CreateSubTree(childData, node)
    end
    return node
end

---根据红点树数据构建红点数
---@param data RedPointTreeData 红点树数据
-- RedPointTreeData = {
--     Id = string,
--     Callback = function,
--     Children = {
--        {    
--             Id = string, 
--             Callback = function, 
--             Children = {
--                 {Id = string, Callback = function, Children = {}
--             },
--        }}, 
--     }
-- }
function ReddotManager:CreateTree(data)
    return self:CreateSubTree(data)
end

---获取某个节点
---@param nodeId string 节点ID
---@return ReddotNode
function ReddotManager:GetNode(nodeId)
    return self.tbAllRedPoint[nodeId]
end

---移除某个节点
---@param nodeId string 节点ID
function ReddotManager:RemoveNode(nodeId)
    local node = self.tbAllRedPoint[nodeId]
    if node then
        node:Delete()
        self.tbAllRedPoint[nodeId] = nil
    end
end

return ReddotManager