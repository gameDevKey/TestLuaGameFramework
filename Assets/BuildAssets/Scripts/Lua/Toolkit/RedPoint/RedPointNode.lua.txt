--[[
    当前节点的状态，会影响父节点的状态
    Interface:
        1.SetParent
        2.SetState
        3.AddOnStateChangeListener
]]
--
RedPointNode = Class("RedPointNode")

local autoKeyFunc = GetAutoIncreaseFunc()

function RedPointNode:OnInit(nodeId)
    self.parent = nil
    self.tbChildren = {}
    self.id = nodeId or ("DEFAULT_" .. autoKeyFunc())
    self.state = ERedPoint.State.Inactive
    self.callback = nil
end

function RedPointNode:GetId()
    return self.id
end

---添加状态变化回调
---@param func function 状态变化回调 function(ERedPointState)
function RedPointNode:AddOnStateChangeListener(func)
    self.callback = func
end

---设置父节点，需要清空父节点时传入nil
---@param node RedPointNode|nil 父节点
function RedPointNode:SetParent(node)
    if node ~= nil then
        node:AddChild(self)
    else
        if self.parent then
            self.parent:RemoveChild(self:GetId())
        end
    end
    self.parent = node
end

---设置状态
---@param state ERedPoint.State 状态
function RedPointNode:SetState(state)
    local lastState = self.state
    self.state = state
    if lastState ~= self.state then
        self:OnStateChange()
    end
end

---添加子节点
---@param node RedPointNode 子节点
function RedPointNode:AddChild(node)
    if not node then
        return
    end
    if self.tbChildren[node:GetId()] then
        PrintWarning("节点[", self:GetId(), "]已经包含ID为[", node:GetId(), "]的子节点")
        return
    end
    self.tbChildren[node:GetId()] = node
end

---移除子节点
---@param childId RedPointNode 子节点
---@return boolean removeSuccess 是否移除成功
function RedPointNode:RemoveChild(childId)
    if childId and self.tbChildren[childId] then
        self.tbChildren[childId] = nil
        return true
    end
    return false
end

---状态变化，往上通知
function RedPointNode:OnStateChange()
    if self.callback then
        self.callback(self:GetId(), self.state)
    end
    if self.parent then
        self.parent:CheckChildrenState()
    end
end

---当一个以上的子节点状态为Active时，自身也是Active
function RedPointNode:CheckChildrenState()
    if self.tbChildren then
        local hasActive = false
        for id, node in pairs(self.tbChildren) do
            if node.state == ERedPoint.State.Active then
                hasActive = true
                break
            end
        end
        self:SetState(hasActive and ERedPoint.State.Active or ERedPoint.State.Inactive)
    end
end

return RedPointNode
