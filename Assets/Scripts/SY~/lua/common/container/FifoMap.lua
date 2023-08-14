-- 具有Map所有的特点：
-- 1、插入key，value
-- 2、根据key判定元素是否存在，根据key移除
-- 具有队列的特点：
-- 1、先进的元素总是先出。
-- 2、类似双向队列，可以操作头部和尾部
-- Author: lizc
-- Date: 2022-09-02 13:47:02
--
local setmetatable = setmetatable
 
local FifoMap = {}
FifoMap.__index = FifoMap
 
function FifoMap.New()
    local t = {}
    t.length = 0
    t.first = nil
    t.last = nil
    t.indexIters = {}
    return setmetatable(t, FifoMap)
end
 
function FifoMap:Clear()
    self.length = 0
    self.first = nil
    self.last = nil
    self.indexIters = {}
end
 
function FifoMap:PushBack(key, value)
    if not value then
        assert(false,"value不能为空")
    end
 
    local node = {key = key, value = value}
 
    if self.last then
        self.last._next = node
        node._prev = self.last
    else
        self.first = node
    end
 
    self.last = node
    self.length = self.length + 1
 
    self.indexIters[key] = node
end
 
function FifoMap:PushHead(key, value)
    if not value then
        assert(false,"value不能为空")
    end
 
    local node = {key = key, value = value}
 
    if self.first then
        self.first._prev = node
        node._next = self.first
    else
        self.last = node
    end
 
    self.first = node
    self.length = self.length + 1
 
    self.indexIters[key] = node
end
 
function FifoMap:PopBack()
    if not self.last then return nil end
    local node = self.last
 
    if not node._prev then
        self.first = nil
        self.last = nil
    else
        node._prev._next = nil
        self.last = node._prev
        node._prev = nil
    end
 
    self.length = self.length - 1
 
    self.indexIters[node.key] = nil
    return node.key, node.value
end
 
function FifoMap:PopHead()
    if not self.first then return end
    local node = self.first
 
    if not node._next then
        self.first = nil
        self.last = nil
    else
        node._next._prev = nil
        self.first = node._next
        node._next = nil
    end
 
    self.length = self.length - 1
 
    self.indexIters[node.key] = nil
    return node.key, node.value
end
 
function FifoMap:Head()
    if self.first == nil then return nil end
    return self.first.key, self.first.value
end
 
function FifoMap:Tail()
    if self.last == nil then return nil end
    return self.last.key, self.last.value
end
 
function FifoMap:Get(key)
    local node = self.indexIters[key]
    if node then
        return node.value
    end
 
    return nil
end
 
function FifoMap:Contains(key)
    return self.indexIters[key] ~= nil
end
 
function FifoMap:Remove(key)
    if not key then
        assert(key, "key不能为nil")
    end
    
    local node = self.indexIters[key]   
    if not node then 
        return
    end
 
    if node._next == nil and node._prev == nil then --链表里只有一个的情况
        if self.first ~= node or self.last ~= node then return nil end --异常
        self.first = nil
        self.last = nil
    elseif self.first == node then
        node._next._prev = nil
        self.first = node._next
    elseif self.last == node then
        node._prev._next = nil
        self.last = node._prev
    elseif node._next ~= nil and node._prev ~= nil then
        if node._next._prev ~= node or node._prev._next ~= node then return nil end --异常
        node._next._prev = node._prev
        node._prev._next = node._next
    end
 
    self.length = self.length - 1
    self.indexIters[key] = nil
end
 
 
function FifoMap:Next(node)
    if node and node._next == nil then return nil end
 
    if node and node._next ~= nil then
        return node._next, node._next.value
    end
 
    if self.first then
        return self.first, self.first.value
    end
 
    return nil
end
 
function FifoMap:Prev(node)
    if node and node._prev ~= nil then
        return node._prev, node._prev.value
    end
 
    if self.last then
        return self.last, self.last.value
    end
 
    return nil
end
 
function FifoMap:Items()
    return self.Next,self
end
 
function FifoMap:ReverseItems()
    return self.Prev,self
end
 
function FifoMap:Count()
    return self.length
end
 
function FifoMap:Length()
    return self.length
end
 
function FifoMap:Size()
    return self.length
end
 
return FifoMap