Facade = BaseClass("Facade")

local facades = {}
local proxys = {}
local ctrls = {}

local gEvents = {}

function Facade:__Init(facadeType)
    facades[facadeType.__className] = self
    self.msgs = {}
    self.proxys = {}
    self.ctrls = {}
    self.events = {}
    self:__InitFacade()
    self:__InitEvent()
end

function Facade:Clean()
    for _,v in pairs(self.proxys) do v:Delete() end
    for _,v in pairs(self.ctrls) do v:Delete() end
    self:Delete()

    facades = {}
    proxys = {}
    ctrls = {}
end

function Facade:BindProxy(proxyType)
    if not proxyType then
        assert(false,string.format("Proxy组件为空[module:%s][proxy:nil]",self.__className))
    end

    if proxys[proxyType] then
        assert(false, string.format("Proxy重复注册[module:%s][proxy:%s]",self.__className,proxyType.__className))
    end

    local proxy = proxyType.New()
    proxys[proxyType] = proxy
    table.insert(self.proxys,proxy)
end

function Facade:BindCtrl(ctrlType)
    if not ctrlType then
        assert(false, string.format("Ctrl组件为空[module:%s][ctrl:nil]",self.__className))
    end
    
    if ctrls[ctrlType] then
        assert(false, string.format("Ctrl重复注册[module:%s][ctrl:%s]",self.__className,ctrlType.__className))
    end
    
    local ctrl = ctrlType.New()
    ctrls[ctrlType] = ctrl

    table.insert(self.ctrls,ctrl)
end

function Facade:BindEvent(event,cb)
    --if CommonDefine.debugEvent[eventName] then Debug.Logf("调试模块事件:绑定事件[%s]",eventName) end
    if not cb then return end
    if self.events[event]==nil then self.events[event] = {} end
    self.events[event][cb] = cb
end

function Facade:RemoveEvent(event,cb)
    --if CommonDefine.debugEvent[eventName] then Debug.Logf("调试模块事件:移除事件[%s]",eventName) end
    if not cb then return end
    if not self.events[event] then return end
    self.events[event][cb] = nil
end

function Facade:SendEvent(event,...)
    if not event then LogError("发送了空的事件") return end
    if not event._enum then LogError("发送的不是事件") return end
    local events = self.events[event]
    if not events then return end
    for k,v in pairs(events) do k(...) end
end

function Facade:SendMsg(msgId,...)
    local cb = self.msgs[msgId]
    if not cb then
        assert(false,string.format("发送未注册的网络协议[模块:%s][msdId:%s]",self.__className,tostring(msgId)))
    end
    cb(msgId,...)
end

function Facade:BindMsg(msgId,cb)
    self.msgs[msgId] = cb
end

function Facade:RemoveMsg(msgId)
    self.msgs[msgId] = nil
end

function Facade:GetProxys()
    return self.proxys
end

function Facade:GetCtrls()
    return self.ctrls
end

function Facade.InitComplete()
    local instances = {}
    for k,v in pairs(proxys) do instances[ v.__className ] = v end
    for k,v in pairs(ctrls) do instances[ v.__className ] = v end
    for k,v in pairs(facades) do instances[ v.__className ] = v end
    mod = TableUtils.ReadOnly(instances)

    for k,v in pairs(proxys) do v:__InitComplete() end
    for k,v in pairs(ctrls) do v:__InitComplete() end
    for k,v in pairs(facades) do v:__InitComplete() end
end

function Facade.CleanModules()
    for k,v in pairs(facades) do v:Clean() end
end

function Facade.GetFacade(name)
    local facade = facades[name]
    if not facade then
        assert(false, string.format("不存在Facade[%s]",name))
    end
    return facade
end
function Facade:__InitFacade() end
function Facade:__InitEvent(enum) end
function Facade:__InitComplete() end