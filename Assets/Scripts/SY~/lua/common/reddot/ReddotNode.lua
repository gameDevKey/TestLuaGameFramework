--[[
    当前节点的状态，会影响父节点的状态
    Interface:
        1.SetParent
        2.SetState
        3.AddOnStateChangeListener
]]--
ReddotNode = BaseClass("ReddotNode")

local autoKeyFunc = function ()
    local key = 0
    return function ()
        key = key + 1
        return key
    end
end

function ReddotNode:__Init(nodeId)
    self.parent = nil
    self.tbChildren = {}
    self.id = nodeId or ("DEFAULT_"..autoKeyFunc())
    self.state = ReddotDefine.RedPointState.Inactive
    self.callback = nil
end

function ReddotNode:__Delete()
    self:SetParent(nil)
    if self.tbChildren then
        for nodeId, node in pairs(self.tbChildren or {}) do
            node:Delete()
        end
        self.tbChildren = nil
    end
end

function ReddotNode:GetId()
    return self.id or "[?]"
end

---添加状态变化回调
---@param func function 状态变化回调 function(ReddotDefine.RedPointState)
function ReddotNode:AddOnStateChangeListener(func)
    self.callback = func
end

---设置父节点,需要清空父节点时传入nil
---@param node ReddotNode|nil 父节点
function ReddotNode:SetParent(node)
    if node ~= nil then
        node:AddChild(self)
    else
        if self.parent then
            self.parent:RemoveChild(self:GetId())
        end
    end
    self.parent = node
end

---设置状态, 激活时会自动往上递归激活
---@param state ReddotDefine.RedPointState|integer 状态
function ReddotNode:SetState(state)
    local lastState = self.state
    self.state = state
    if lastState ~= self.state then
        self:OnStateChange()
    end
end

---添加子节点
---@param node ReddotNode 子节点
function ReddotNode:AddChild(node)
    if not node then
        return
    end
    if self.tbChildren[node:GetId()] then
        LogError("节点[",self:GetId(),"]已经包含ID为[",node:GetId(),"]的子节点")
        return
    end
    self.tbChildren[node:GetId()] = node
end

---移除子节点
---@param childId ReddotNode 子节点
---@return boolean removeSuccess 是否移除成功
function ReddotNode:RemoveChild(childId)
    if childId and self.tbChildren[childId] then
        self.tbChildren[childId] = nil
        return true
    end
    return false
end

---状态变化，往上通知
function ReddotNode:OnStateChange()
    if self.callback then
        self.callback(self:GetId(),self.state)
    end
    if self.parent then
        self.parent:CheckChildrenState()
    end
end

---当一个以上的子节点状态为Active时，自身也是Active
function ReddotNode:CheckChildrenState()
    if self.tbChildren then
        local hasActive = false
        for id, node in pairs(self.tbChildren) do
            if node.state == ReddotDefine.RedPointState.Active then
                hasActive = true
                break
            end
        end
        self:SetState(hasActive and ReddotDefine.RedPointState.Active or ReddotDefine.RedPointState.Inactive)
    end
end

return ReddotNode