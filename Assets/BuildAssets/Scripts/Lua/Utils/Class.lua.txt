local function InjectInterfaces(obj,interfaces)
    for _, interface in ipairs(interfaces or NIL_TABLE) do
        if interface._isInterface then
            for fieldName, field in pairs(interface) do
                if IsFunction(field) then
                    obj[fieldName] = field
                end
            end
        end
    end
end

---递归调用函数
---@param fnName string 函数名
---@param topDir boolean 调用方向, true表示从上往下调用, 反之从下往上调用
local function CallFuncDeeply(cls, caller, fnName, depth, maxDepth, topDir, ...)
    if not cls or maxDepth and depth >= maxDepth then return end
    local fn = rawget(cls, fnName)
    if topDir then
        CallFuncDeeply(cls._super, caller, fnName, depth+1, maxDepth, topDir, ...)
        if caller then local _ = fn and fn(caller,...)
        else local _ = fn and fn(...) end
    else
        if caller then local _ = fn and fn(caller,...)
        else local _ = fn and fn(...) end
        CallFuncDeeply(cls._super, caller, fnName, depth+1, maxDepth, topDir, ...)
    end
end

local function AssertClass(cls, super)
    if not IsClass(cls) then
        PrintError("当前类类型异常!",cls)
        return false
    end
    if super and not IsClass(super) then
        PrintError("父类类型异常!",super)
        return false
    end
    if super and cls._className == super._className then
        PrintError("不可以自己继承自己!")
        return false
    end
    return true
end

if MEM_CHECK then
    ALL_CLASS = {}
    setmetatable(ALL_CLASS,{__mode = "kv"})
end

---创建接口，只能包含函数
---配合Class()使用时，会把该表的所有函数注册到类中
---虚函数: ToString
---@param interfaceName string 接口名
---@param interfaces List<Interface>|table|nil 接口类列表，只能包含函数
---@return Interface interface 接口
function Interface(interfaceName,interfaces)
    local interface = {}
    interface._isInterface = true
    interface._interfaceName = interfaceName
    interface._interfaces = interfaces or NIL_TABLE
    local nameStr = string.format("接口[%s-%s]", interfaceName, tostring(interface))
    setmetatable(interface, {
        __tostring = function()
            local fn = rawget(interface, "ToString")
            return fn and fn(interface) or nameStr
        end,
     })
    InjectInterfaces(interface,interface._interfaces)
    return interface
end

---调用当前类的父类的方法, 注意不能直接通过 self._super:Func() 去调用, 因为self可能不是当前类,
---比如 function A:Func() self._super:Func() end 中, B继承A, 此时 B:Func() 调用后, self指向B, 就引起了死循环
---@param cls Class 类
---@param caller Class 类的实例, 注意这个实例不一定是cls实例化出来的
---@param fnName string 函数名
---@param force boolean 当前类的父类没有该函数时，是否一直往上找直至调用成功
function CallMySuperFunc(cls, caller, fnName, force, ...)
    if cls._isInstance then
        PrintError("禁止通过实例调用父类函数",cls,fnName)
        return
    end
    local super = cls._super
    if not super then
        return
    end
    local fn = rawget(super, fnName)
    if not fn then
        if not force then
            return
        end
        return CallMySuperFunc(super, caller, fnName, force)
    end
    return fn(caller,...)
end

---创建类: 子类支持重载ToString()，暂不支持多重继承，支持实现多个接口类
---包含字段: _className:string 类名 | _class:Class 所属类 | _super:Class 父类 | _objectId:integer 实例ID
---包含方法: New 静态实例化函数 | Delete 析构函数 | ToFunc 返回某个函数 | CallFuncDeeply 调用父类函数
---虚函数: OnInit(自顶向下调用) | OnDelete(自底向上调用) | ToString
---@param className string 类名
---@param superClass Class|nil Class 父类
---@param interfaces List<Interface>|table|nil 接口类列表，只能包含函数
---@return Class cls 类
function Class(className, superClass, interfaces)
    local clazz = {}
    clazz._isClass = true
    clazz._className = className
    clazz._interfaces = interfaces or NIL_TABLE
    clazz._location = tostring(clazz)

    local nameStr = string.format("类[%s-%s]", className, clazz._location)
    setmetatable(clazz, {
        __index = superClass,
        __tostring = function()
            local fn = rawget(clazz, "ToString")
            return fn and fn(clazz) or nameStr
        end,
     })
    clazz._super = superClass

    InjectInterfaces(clazz,clazz._interfaces)

    function clazz.New(...)
        local instance = {}
        instance._isInstance = true
        instance._class = clazz
        instance._objectId = tostring(instance)
        instance._alive = false
        instance._funcs = {}
        local defaultStr = string.format("%s实例[%s]", clazz._className, instance._objectId)
        if MEM_CHECK then
            ALL_CLASS[instance] = debug.traceback()
        end
        setmetatable(instance,
        {
            __index = clazz,
            __tostring = function()
                local fn = rawget(clazz, "ToString")
                return fn and fn(instance) or defaultStr
            end,
        })

        function instance:Ctor(...)
            if not self._alive then
                self._alive = true
                self:CallFuncDeeply("OnInit", true, ...)
            end
        end

        function instance:Delete(...)
            if self._alive then
                self._alive = false
                if MEM_CHECK then
                    ALL_CLASS[instance] = nil
                end
                self:CallFuncDeeply("OnDelete", false, ...)
            end
        end

        function instance:ToFunc(name)
            if not self._alive then
                PrintError(self, "已被删除，无法获取函数", name)
                return nil
            end
            if not self._funcs[name] then
                local func = self[name]
                if IsFunction(func) then
                    self._funcs[name] = function (...)
                        if instance._alive then
                            return func(instance,...)
                        end
                        PrintError(self,'已被删除，但仍被调用函数',name)
                    end
                else
                    PrintError(self, "未定义函数", name)
                end
            end
            return self._funcs[name]
        end

        function instance:CallFuncDeeply(fnName, topDir, ...)
            CallFuncDeeply(clazz, instance, fnName, 0, nil, topDir, ...)
        end

        function instance:CallSuperFuncDeeply(fnName, topDir, ...)
            CallFuncDeeply(clazz._super, instance, fnName, 0, nil, topDir, ...)
        end

        instance:Ctor(...)
        return instance
    end

    if TEST_ENV then
        AssertClass(clazz, superClass)
    end
    return clazz
end

local singletonClasses = {}

---创建单例类: 每个单例类的实例全局唯一, 子类支持重载ToString()，暂不支持多重继承，支持实现多个接口类
---包含字段: Instance 单例Getter | _className:string 类名 | _class:Class 所属类 | _super:Class 父类 | _objectId:integer 实例ID
---包含方法: Instance 单例获取函数 | Delete 析构函数 | ToFunc 返回某个函数 | CallFuncDeeply 调用父类函数
---虚函数: OnInit(自顶向下调用) | OnDelete(自底向上调用) | ToString
---@param className string 类名
---@param superClass Class|nil Class 父类
---@param interfaces List<Interface>|table|nil 接口类列表，只能包含函数
---@return Class cls 单例类
function SingletonClass(className, superClass, interfaces)
    if singletonClasses[className] then
        return singletonClasses[className]._class
    end

    local clazz = {}
    clazz._isClass = true
    clazz._className = className
    clazz._interfaces = interfaces or NIL_TABLE
    clazz._location = tostring(clazz)

    local nameStr = string.format("单例类[%s-%s]", className, clazz._location)
    setmetatable(clazz, {
        __index = function (tb,key)
            if key == "Instance" then --访问时动态注入字段
                rawset(tb, key, clazz.New())
                return rawget(tb, key)
            end
            return superClass and superClass[key]
        end,
        __tostring = function()
            local fn = rawget(clazz, "ToString")
            return fn and fn(clazz) or nameStr
        end,
    })
    clazz._super = superClass

    InjectInterfaces(clazz,clazz._interfaces)

    function clazz.New(...)
        if singletonClasses[clazz._className] then
            PrintError(clazz,"不可重复实例化, 访问请用Instance字段")
            return singletonClasses[clazz._className]
        end
        local instance = {}
        instance._isInstance = true
        instance._class = clazz
        instance._objectId = tostring(instance)
        instance._alive = false
        instance._funcs = {}
        if MEM_CHECK then
            ALL_CLASS[instance] = debug.traceback()
        end
        local defaultStr = string.format("%s实例[%s]", clazz._className, instance._objectId)
        setmetatable(instance,
            {
                __index = clazz,
                __tostring = function()
                    local fn = rawget(clazz, "ToString")
                    return fn and fn(instance) or defaultStr
                end,
            })

        function instance:Ctor(...)
            if not self._alive then
                self._alive = true
                singletonClasses[clazz._className] = self
                self:CallFuncDeeply("OnInit", true, ...)
            end
        end

        function instance:Delete(...)
            if self._alive then
                self._alive = false
                singletonClasses[clazz._className] = nil
                if MEM_CHECK then
                    ALL_CLASS[instance] = nil
                end
                self:CallFuncDeeply("OnDelete", false, ...)
            end
        end

        function instance:ToFunc(name)
            if not self._alive then
                PrintError(self, "已被删除，无法获取函数", name)
                return nil
            end
            if not self._funcs[name] then
                local func = self[name]
                if IsFunction(func) then
                    self._funcs[name] = function (...)
                        if instance._alive then
                            return func(instance,...)
                        end
                        PrintError(self,'已被删除，但仍被调用函数',name)
                    end
                else
                    PrintError(self, "未定义函数", name)
                end
            end
            return self._funcs[name]
        end

        function instance:CallFuncDeeply(fnName, topDir, ...)
            CallFuncDeeply(clazz, instance, fnName, 0, nil, topDir, ...)
        end

        function instance:CallSuperFuncDeeply(fnName, topDir, ...)
            CallFuncDeeply(clazz._super, instance, fnName, 0, nil, topDir, ...)
        end

        instance:Ctor(...)
        return instance
    end

    if TEST_ENV then
        AssertClass(clazz, superClass)
    end
    return clazz
end

local staticClasses = {}

---创建静态类: 不允许创建实例，全局唯一，不可删除
---包含字段: _className:string 类名
---虚函数: ToString
---@param className string 类名
---@return Class|nil cls 静态类
function StaticClass(className)
    if staticClasses[className] then
        PrintError("静态类",className,"无法重复创建")
        return nil
    end

    local clazz = {}
    clazz._isClass = true
    clazz._className = className
    local defaultStr = string.format("静态类[%s-%s]", className, tostring(clazz))
    staticClasses[clazz._className] = clazz

    setmetatable(clazz, {
        __tostring = function()
            local fn = rawget(clazz, "ToString")
            return fn and fn(clazz) or defaultStr
        end,
    })

    if TEST_ENV then
        AssertClass(clazz)
    end
    return clazz
end

local globalInstances = {}

---获取实例，这个实例全局唯一，某些非单例类需要创建一个全局实例，比如事件系统
---@param cls Class 类
---@return table instance 类实例
function GetGlobalInstance(cls)
    if not globalInstances[cls._className] then
        globalInstances[cls._className] = cls.New()
    end
    return globalInstances[cls._className]
end

---扩展类
---@param cls Class 类
function ExtendClass(cls)
    return cls
end

--卸载所有类实例(慎用!)
function ClearAllClass()
    for name, ins in pairs(singletonClasses) do
        ins:Delete()
    end
    singletonClasses = {}
    for name, ins in pairs(globalInstances) do
        ins:Delete()
    end
    globalInstances = {}
end

if MEM_CHECK then
    function CheckClsInstanceInMemery(showTraceback)
        collectgarbage("collect")
        print("当前内存",collectgarbage("count"))
        for instance, traceback in pairs(ALL_CLASS) do
            if showTraceback then
                PrintLog("内存中存在",instance,'\n',traceback)
            else
                PrintLog("内存中存在",instance)
            end
        end
    end
end