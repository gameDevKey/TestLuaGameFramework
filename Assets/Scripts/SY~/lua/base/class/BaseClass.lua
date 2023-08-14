-- 保存类类型的虚表
local classTypes = {}

if IS_EDITOR then
	DebugFightClassClear = {}
	DebugFightClassCreate = {}
end

function BaseClass(className,super,indexCallback)
	if GDefine.luaDebug then
		--local track = debug.getinfo(2,"Sln")
		--if track then classFile = track.short_src end
		--local checkName = FileToClass[debug.getinfo(2,"S").short_src]
		--assert(className == checkName,string.format("BaseClass传入错误类名[%s](%s)",tostring(className),checkName))a


	else
		--assert(className and type(className) == "string" and className ~= "" ,string.format("BaseClass传入错误类名[%s]",tostring(className)))
	end
	
	-- 生成一个类类型
	local class = {}

	class.__Init = false
	class.__Delete = false

	class.super = super

	class.New = function(...)
		-- 生成一个类对象

		local obj = {}
		obj._create = true
		obj._class = true
		obj._type = class

		if IS_EDITOR then
			obj.traceInfo = debug.traceback()
			if not class.NOT_CLEAR and string.find(obj.traceInfo,"module/battle/logic/") ~= nil and string.find(obj.traceInfo,"module/battle/view") == nil then
				DebugFightClassClear[obj] = obj.traceInfo

				if not DebugFightClassCreate[className] then
					DebugFightClassCreate[className] = {num = 0}
				end
				DebugFightClassCreate[className].num = DebugFightClassCreate[className].num + 1
			end
		end

		
		-- 在初始化之前注册基类方法
		setmetatable(obj, { __index = classTypes[class] })

		-- 注册一个delete方法
		obj.Delete = function(self)
			self._create = nil

			if IS_EDITOR then
				if DebugFightClassClear[self] then
					DebugFightClassClear[self] = nil
				end
			end

			local nowSuper = self._type
			while nowSuper ~= nil do
				local super = nowSuper.super
				if nowSuper.__Delete then  nowSuper.__Delete(self) end
				nowSuper = super
			end
		end

		obj.funcs = nil
		obj.ToFunc = function(self,fn)
			if not self.funcs then self.funcs = {} end
			local func = self.funcs[fn]
			if not func then
				func = function(...) 
					if self._create and self[fn] then
						return self[fn](self,...) 
					end
				end
				self.funcs[fn]=func
			end
			return func
		end

		obj.GetFunc = function(self,fn)
			if not self.funcs then return nil end
			return self.funcs[fn]
		end

		local _superFunc
		_superFunc = function(c,fn,flag,...)
			if flag then
				if c.super then _superFunc(c.super,fn,flag,...) end
				if c[fn] then c[fn](obj, ...) end
			else
				if c[fn] then c[fn](obj, ...) end
				if c.super then _superFunc(c.super,fn,flag,...) end
			end
		end

		--flag为true,则从父到子顺序调用
		--flag为false,则从子到父顺序调用
		obj.SuperFunc = function(self,fn,flag,...)
			_superFunc(class,fn,flag, ...)
		end

		-- 调用初始化方法
		do
			local create
			create = function(c, ...)
				if c.super then create(c.super, ...) end
				if c.__Init then c.__Init(obj, ...) end
			end

			create(class, ...)
		end

		return obj
	end

	local vtbl = {}

	vtbl.__className = className
	vtbl.__type = class

	classTypes[class] = vtbl

	setmetatable(class, {__newindex = function(t,k,v) vtbl[k] = v end,__index = vtbl})
	if super then
		setmetatable(vtbl, {__index = function(t,k) return classTypes[super][k] end })
	elseif indexCallback ~= nil then
		setmetatable(vtbl, {__index = indexCallback })
	end
	return class
end