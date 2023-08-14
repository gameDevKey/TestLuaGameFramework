local setmetatable = setmetatable

List = {}
List.__index = List

function List.New()
	local t = {}
	t.length = 0
	t.first = nil
	t.last = nil
	t.indexIters = {}
	return setmetatable(t, List)
end

function List:Clear()
	self.length = 0
    self.first = nil
	self.last = nil
	self.indexIters = {}
end

function List:SetIndex(index,iter)
	if iter and self.indexIters[index] then
		LogError("SECBList禁止重复设置索引节点")
	else
		self.indexIters[index] = iter
	end
end

function List:ExistIndex(index)
	return self.indexIters[index] ~= nil
end

function List:GetIterByIndex(index)
	return self.indexIters[index]
end

function List:RemoveByIndex(index)
	local iter = self:GetIterByIndex(index)
	if iter then
		self:Remove(iter)
	end
end

function List:RemoveIndex(index)
	self.indexIters[index] = nil
end

function List:Push(value,index,param)
	if not value then return end
	local node = {value = value,index = index,param = param}

	if self.last then
		self.last._next = node
		node._prev = self.last
	else
		self.first = node
	end

	self.last = node
	self.length = self.length + 1

	if index then
		self:SetIndex(index,node)
	end

	return node
end

function List:PushHead(value,index,param)
	if not value then return end
	local node = {value = value,index = index,param = param}

	if self.first then
        self.first._prev = node
        node._next = self.first
    else
        self.last = node
    end

    self.first = node
    self.length = self.length + 1

	if index then
		self:SetIndex(index,node)
	end

    return node
end

function List:Pop()
	if not self.last then return end
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

	if node.index then
		self:RemoveIndex(node.index)
	end
	
    return node.value,node.param
end

function List:PopHead()
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

	if node.index then
		self:RemoveIndex(node.index)
	end
	
    return node.value,node.param
end

function List:Remove(iter)
	if not iter then return end

	if iter._next == nil and iter._prev == nil then --链表里只有一个的情况
		if self.first ~= iter or self.last ~= iter then return nil end --异常
		self.first = nil
        self.last = nil
    elseif self.first == iter then
    	iter._next._prev = nil
        self.first = iter._next
    elseif self.last == iter then
    	iter._prev._next = nil
        self.last = iter._prev
    elseif iter._next ~= nil and iter._prev ~= nil then
    	if iter._next._prev ~= iter or iter._prev._next ~= iter then return nil end --异常
    	iter._next._prev = iter._prev
		iter._prev._next = iter._next
	end

	self.length = self.length - 1

	if iter.index then
		self:RemoveIndex(iter.index)
	end

	return iter
end

function List:RemoveByValue(value)
	local iter = self:Find(value)
	if iter then self:Remove(iter) end
end

function List:MoveFirst(iter)
    if not iter then return end

    if self.first == iter then return self.first end --本身就是第一个

    if self.last == iter then
		iter._prev._next = nil
    	self.last = iter._prev
    elseif iter._prev ~= nil and iter._next ~= nil then
    	iter._prev._next = iter._next
    	iter._next._prev = iter._prev
    end

    iter._next = self.first
    iter._prev = nil
    self.first._prev = iter
    self.first = iter
end

function List:MoveLast(iter)
    if not iter then return end

    if self.last == iter then return self.last end --本身就是最后一个

    if self.first == iter then
    	iter._next._prev = nil
    	self.first = iter._next
    elseif iter._prev ~= nil and iter._next ~= nil then
    	iter._prev._next = iter._next
    	iter._next._prev = iter._prev
    end

    iter._next = nil
    iter._prev = self.last
    self.last._next = iter
    self.last = iter
end

function List:Find(v, iter)
	iter = iter or self.first
	while iter do
        if v == iter.value then return iter end
        iter = iter._next
    end
	return nil
end

function List:FindLast(v, iter)
	iter = iter or self.last
	while iter do
        if v == iter.value then return iter end
        iter = iter._prev
    end
    return nil
end

function List:Next(iter)
	if iter and iter._next == nil then return nil end

	if iter and iter._next ~= nil then 
		return iter._next, iter._next.value 
	end

	if self.first then
		return self.first, self.first.value
	end

    return nil
end

function List:Prev(iter)
	if iter and iter._prev ~= nil then
		return iter._prev, iter._prev.value
	end

	if self.last then
		return self.last, self.last.value
	end

	return nil
end

function List:Insert(iter,value,index,param)
	if not value then return end
	if not iter then return self:Push(value) end
	local node = {value = value,index = index,param = param}

	if iter._next then
        iter._next._prev = node
        node._next = iter._next
    else
        self.last = node
    end

    node._prev = iter
    iter._next = node
    self.length = self.length + 1

	if index then
		self:SetIndex(index,iter)
	end

	return node
end

function List:Head()
	if self.first == nil then return nil end
	return self.first.value
end

function List:Tail()
	if self.last == nil then return nil end
	return self.last.value
end

function List:Clone()
	local t = List:New()
	for item in self:Items() do t:Push(item.value) end
	return t
end

function List:Items()
    return self.Next,self
end

function List:ReverseItems()
    return self.Prev,self
end

function List:Count()
	return self.length
end

function List:Length()
	return self.length
end