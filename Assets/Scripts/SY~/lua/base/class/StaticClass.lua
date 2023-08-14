-- 保存类类型的虚表
local classTypes = {}

function StaticClass(className)
	if GDefine.luaDebug then
		local checkName = FileToClass[debug.getinfo(2,"S").short_src]
		assert(className == checkName,string.format("StaticClass传入错误类名[%s](%s)",tostring(className),checkName))
	else
		--assert(className and type(className) == "string" and className ~= "" ,string.format("StaticClass传入错误类名[%s]",tostring(className)))
	end

	-- 生成一个类类型
	local class = {}

	local vtbl = {}
	
    vtbl.ClassName = function() return className end
    
	classTypes[class] = vtbl

    setmetatable(class, {__newindex = function(t,k,v) vtbl[k] = v end,__index = vtbl})
    
	return class
end