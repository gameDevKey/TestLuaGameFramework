--代理基类，会在游戏启动前自动加载
--处理协议或者业务数据，数据更新后通过Facade或者全局事件向外通知
--禁止直接访问视图层
--最好结合DataWater类监听数据变化
--函数InitComplete()会在Facade安装完成后自顶向下被调用
ProxyBase = Class("ProxyBase",ModuleBase)

function ProxyBase:OnInit()
    self.protoCallbacks = {}
    self.dataCallbacks = {}
    self.rootDataWatcher = TableDataWatcher.New()
    self.rootDataWatcher:SetChangeFunc(self:ToFunc("HandleProtoDataChange"))
    self.rootDataWatcher:SetCompareFunc(self:ToFunc("HandleProtoDataCompare"))
end

function ProxyBase:OnDelete()
    for proto, callObject in pairs(self.protoCallbacks) do
        callObject:Delete()
    end
    for proto, callObject in pairs(self.dataCallbacks) do
        callObject:Delete()
    end
    self.rootDataWatcher:Delete()
end

function ProxyBase:OnInitComplete()
    self:AddGolbalListenerWithSelfFunc(EGlobalEvent.Proto,"HandleProto", false)
end

function ProxyBase:ListenProto(proto, selfFuncName)
    self.protoCallbacks[proto] = CallObject.New(self:ToFunc(selfFuncName))
end

function ProxyBase:ListenData(protoPattern, selfFuncName)
    self.dataCallbacks[protoPattern] = CallObject.New(self:ToFunc(selfFuncName))
end

function ProxyBase:HandleProto(proto,args)
    --先处理数据
    self.rootDataWatcher:SetVal(proto,args)
    --后触发回调
    local handler = self.protoCallbacks[proto]
    if handler then
        handler:Invoke(args)
    end
end

--TODO 需要优化，性能受限于 协议结构体深度 和 数据更新频率
local function DataCompare(new,old,prefix,key,output)
    local curPrefix = prefix or ""
    if string.valid(key) then
        curPrefix = prefix .. "." .. key
    end
    if type(new) ~= type(old) then
        output[curPrefix] = {new=new,old=old}
        return false
    end
    if not IsTable(new) and not IsTable(old) then
        local same = new == old
        if not same then
            output[curPrefix] = {new=new,old=old}
        end
        return same
    end
    local same = true
    for k, v in pairs(old or NIL_TABLE) do
        if not DataCompare(new[k],v,curPrefix,k,output) then
            --删除
            same = false
        end
    end
    for k, v in pairs(new or NIL_TABLE) do
        if not DataCompare(v,old[k],curPrefix,k,output) then
            --新增或者变化
            same = false
        end
    end
    if not same then
        output[curPrefix] = {new=new,old=old}
    end
    return same
end

--虚函数
function ProxyBase:HandleProtoDataChange(proto,new,old)
    --获取变化字段的全路径，意在通知具体的处理函数
    local paths = {}
    DataCompare(new,old,ProtoDefine[proto],"",paths)
    for path, data in pairs(paths) do
        local fn = self.dataCallbacks[path]
        if fn then
            fn:Invoke(data.new,data.old)
        end
    end
end

--虚函数
function ProxyBase:HandleProtoDataCompare(proto,new,old)
    return false --默认协议数据都是变化之后才会回传，否则请重载此函数
end

return ProxyBase