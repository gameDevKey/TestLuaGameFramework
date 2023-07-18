-- local inA = Interface("InterfaceA")
-- function inA:InterfaceFuncA()
--     print("Call InterfaceFuncA")
-- end

-- local inB = Interface("InterfaceB")
-- function inB:InterfaceFuncB()
--     print("Call InterfaceFuncB")
-- end

-- local clsA = Class("ClassA",nil,{inA,inB})
-- function clsA:FuncA()
--     print("Call FuncA")
-- end

-- local clsB = Class("ClassB", clsA)
-- function clsB:FuncB()
--     print("Call FuncB")
-- end

-- local clsC = Class("ClassC",clsB)
-- function clsC:FuncC()
--     print("Call FuncC")
-- end

-- local objC = clsC.New()
-- objC:FuncA()
-- objC:InterfaceFuncA()
-- objC:InterfaceFuncB()

-- objC:Delete()

-- local func = objC:ToFunc("FuncC")
-- func()




-- local cls = Class("Class")
-- function cls:ToString()
--     return "重载ClassToString"
-- end
-- print("创建类",cls)

-- local scls = SingletonClass("SingletonClass")
-- print("创建单例类",scls)
-- local insA = scls.New()
-- print("创建单例类实例A",insA)
-- local insB = scls.New()
-- print("创建单例类实例B",insB)

-- local staticCls = StaticClass("StaticClass")
-- print("创建静态类",staticCls)
-- staticCls:Delete()



-- local clsA = Class("A")
-- function clsA:OnInit(...)
--     print("构造A",...)
-- end
-- function clsA:OnDelete(...)
--     print("删除A",...)
-- end

-- local clsB = Class("B",clsA)
-- function clsB:OnInit(...)
--     print("构造B",...)
-- end
-- function clsB:OnDelete(...)
--     print("删除B",...)
-- end

-- local clsC = Class("C",clsB)
-- function clsC:OnInit(...)
--     print("构造C",...)
-- end
-- function clsC:OnDelete(...)
--     print("删除C",...)
-- end

-- local ins = clsC.New("参数12")

-- print("-------------------创建C")
-- CheckClsInstanceInMemery()

-- ins:Delete()

-- print("------------------删除C")
-- CheckClsInstanceInMemery()

-- ClearAllClass()

-- print("------------------全部清除")
-- CheckClsInstanceInMemery(true)

-- for key, value in pairs(_G) do
--     if IsClass(value) then
--         print("_G:",key,value)
--     end
-- end

local cls = Class("A")
function cls:Func()
    PrintLog(self,"调用函数Func")
end
local ins = cls.New()
local fn = ins:ToFunc("Func")
fn()
ins:Delete()
fn()