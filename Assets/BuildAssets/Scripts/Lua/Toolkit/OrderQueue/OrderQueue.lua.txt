OrderQueue = Class("OrderQueue")

function OrderQueue:OnInit()
    self.queue = {}
end

local function TryExeOrder(callback, callbackNext, isAsync)
    if callback then
        if isAsync then
            callback(function()
                if callbackNext then
                    callbackNext()
                end
            end)
        else
            callback()
            if callbackNext then
                callbackNext()
            end
        end
    end
end

function OrderQueue:AddOrder(callback, exeNextWhenFinish, posType, isAsync)
    if not callback then
        return
    end
    local pos = posType == EOrderQueue.Type.First and 1 or (#self.queue + 1)
    local cbNext
    if exeNextWhenFinish then
        cbNext = function()
            self:ExecuteNext()
        end
    end
    table.insert(self.queue, pos, function()
        TryExeOrder(callback, cbNext, isAsync)
    end)
end

function OrderQueue:AddSyncOrder(callback, exeNextWhenFinish, posType)
    self:AddOrder(callback, exeNextWhenFinish, posType, false)
end

function OrderQueue:AddAysncOrder(callback, exeNextWhenFinish, posType)
    self:AddOrder(callback, exeNextWhenFinish, posType, true)
end

function OrderQueue:ExecuteNext()
    if #self.queue == 0 then
        return
    end
    local cb = table.remove(self.queue, 1)
    cb()
end

return OrderQueue
