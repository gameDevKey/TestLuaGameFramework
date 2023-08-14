-- ----------------------------------------------------

-- 既像List，又像Map

-- 特点1：完全具有数组的特点，元素是按顺序插入的

-- 特点2：可以通过索引或key两种方式获取元素

--

-- 强制要求：元素必须有id或key这两个属性中的一个，用来作为字典的key。

-- 其实完全有其它方法不强制要求存在id或key这两个属性，但为了避免频繁gc，这里作了取舍

--

-- 可以按需要继续扩充排序等方法

-- author:lizc

-- ----------------------------------------------------

--==============================================================================================================================

--@file ListMap

--@brief 数组+map存储结构

--@date 2021/06/28

--==============================================================================================================================

ListMap = BaseClass("ListMap")

function ListMap:__Init()
    --数组
    self.aryElement = {}

    --key:道具唯一id（服务端id）,value:道具
    self.dictElement = {}

    --key:道具唯一id（服务端id），value:数组索引
    self.dicKeyIndex = {}

    --key:baseId，value:数组，
    self.dicBaseIdKey = {}

    self.debug = false
end

function ListMap:__Delete()
    --数组
    self.aryElement = {}

    --key:道具唯一id（服务端id）,value:道具
    self.dictElement = {}

    --key:道具唯一id（服务端id），value:数组索引
    self.dicKeyIndex = {}

    --key:baseId，value:数组，
    self.dicBaseIdKey = {}
end

function ListMap:Clean()
    self.aryElement = {}
    self.dictElement = {}
    self.dicKeyIndex = {}
    self.dicBaseIdKey = {}
end

--插入一个道具,若道具已存在，则只更新数据，不修改索引
--@param item 构造好的道具
--@param index 非必填参数，要插入到索引位置
function ListMap:Push(item, index)
    local key = item.id

    if self.dictElement[key] == nil then
    --如果元素不存在，插入
        if index then
            table.insert(self.aryElement, index, item)
            self.dicKeyIndex[key] = index

            --得更新索引，这里会有一定的开销
            for i = index, #self.aryElement do
                local each = self.aryElement[i]
                local eachKey = each.id or each.key
                self.dicKeyIndex[eachKey] = i
            end
        else
            table.insert(self.aryElement, item)
            local length = #self.aryElement
            self.dicKeyIndex[key] = length
            if self.debug then
                Logf("插入的id[%s],索引[%s]", key, length)
            end
        end
    end

    self.dictElement[key] = item
end

--通过索引获取

function ListMap:GetByIndex(index)
    return self.aryElement[index]
end

--通过道具唯一id(服务端id)获取
function ListMap:GetById(id)
    return self.dictElement[id]
end

--是否包含此id(唯一id)的道具
--@return 有则true，否则false
function ListMap:ContainId(id)
    return self.dictElement[id] ~= nil
end

--通过id移除元素

function ListMap:RemoveById(id)
    local value = self.dictElement[id]
    if value then
        --通过key找到此元素的索引
        local index = self.dicKeyIndex[id]

        if self.debug then
            Logf("移除前：要移除的id[%s]，所在的索引[%s]，数组总数量[%s]",id,index,#self.aryElement)
        end

        --移除数组里的元素
        table.remove(self.aryElement, index)

        if self.debug then
            Logf("移除后：数组总数量[%s]", #self.aryElement)
        end

        --移除字典里的元素
        self.dictElement[id] = nil
        self.dicKeyIndex[id] = nil

        --得更新索引，这里会有一定的开销
        for i = index, #self.aryElement do
            local each = self.aryElement[i]
            local eachKey = each.id or each.key
            self.dicKeyIndex[eachKey] = i
        end
    end

    return value
end

--通过index移除元素

function ListMap:RemoveByIndex(index)
    local element = self.aryElement[index]
    if element then
        table.remove(self.aryElement, index)
        self.dictElement[element.id] = nil
        self.dicKeyIndex[element.id] = nil
    else
        LogErrorf("无法通过索引[%s]找到元素", index)
    end
    return element
end

--通过key获取元素所在的index
--@params  key，如果是英雄或者道具，那么key等于id
function ListMap:GetIndex(key)
    return self.dicKeyIndex[key]
end

--获取map
function ListMap:Map()
    return self.dictElement
end

--获取list
function ListMap:List()
    return self.aryElement
end

function ListMap:Size()
    return #self.aryElement
end

function ListMap:Count()
    return #self.aryElement
end

--重新创建key<->index的配对
function ListMap:ResetKeyIndex()
    self.dicKeyIndex = {}
    for i, each in ipairs(self.aryElement) do
        self.dicKeyIndex[each.id] = i
    end
end