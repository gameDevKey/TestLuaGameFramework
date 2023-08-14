BaseModule = BaseClass("BaseModule")

function BaseModule:__Init()
    local className = ClassToModule[self.__className]
    --local classType = GetClass(className)
    --assert(classType ~= nil,string.format("模块不存在[模块:%s]",1))
    self.module = Facade.GetFacade(className)
end

function BaseModule:__Delete()
end

function BaseModule:SendEvent(eventName,...)
    self.module:SendEvent(eventName,...)
end

function BaseModule:SendMsg(msgId,...)
    self.module:SendMsg(msgId,...)
end
