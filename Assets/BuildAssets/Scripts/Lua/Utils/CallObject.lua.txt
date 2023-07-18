CallObject = Class("CallObject")

function CallObject:OnInit(func,caller,args)
    self.func = func
    self.caller = caller
    self.args = args
end

--触发回调，注意args拼接在回调的首位，后面才是传入的参数
function CallObject:Invoke(...)
    if not self._alive then
        PrintError(self,"已被删除，但仍被调用")
        return
    end
    if self.func ~= nil then
        if self.caller ~= nil then
            if self.args ~= nil then
                return self.func(self.caller,self.args,...)
            end
            return self.func(self.caller,...)
        end
        if self.args ~= nil then
            return self.func(self.args,...)
        end
        return self.func(...)
    end
end

function CallObject:GetFunc()
    return self.func,self.caller,self.args
end

return CallObject