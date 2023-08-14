require "base/csharp_types"

local editor = false
if CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.WindowsEditor 
	or CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.OSXEditor then
	editor = CS.BaseSetting.debug
end

require "utils/log"

if not editor then
	require "mapping"
else
	ClassToFile = {}
	FileToClass = {}
	DataToFile = {}
	ModuleMapping = {}
	ClassToModule = {}

	local fileNames = {}

	local luaPath = CS.IOUtils.GetAbsPath(CS.UnityEngine.Application.dataPath .. "/../../lua/")
	local dataPath = CS.IOUtils.GetAbsPath(CS.UnityEngine.Application.dataPath .. "/../../data/")

	local nameRx = "^[a-zA-Z][a-zA-Z_0-9]*$"
	local folderRx = "^[a-z][a-z0-9_]*$"
	local numRx = "^[0-9]*$"

	Log("lua路径:"..luaPath)
	Log("data路径:"..dataPath)

	local function ParseLuaFile(file)
		local filePath = CS.IOUtils.SubPath(file,luaPath)
		if string.find(filePath,"tolua") == 1 then 
			return
		end
	
		local fileName = CS.IOUtils.GetFileName(file)
	
		if not string.match(fileName,nameRx)
			or string.sub(fileName, -1) == "_" 
			or string.find(fileName, "__") then
			LogErrorf("lua文件命名异常[%s]（只能出现字母、数字、下划线，首尾不能为下划线，不能出现连续2个下划线 ）",filePath)
			return
		end
	
		local directory = CS.IOUtils.GetPathDirectory(filePath,false);
		for folder in (directory.."/"):gmatch("(.-)/") do
			if folder ~= "" and not string.match(folder,numRx) 
				and (not string.match(folder,folderRx) or string.sub(folder, -1) == "_" or string.find(folder,"__")) then
				LogErrorf("Lua文件夹路径命名异常[%s][%s]（只能出现字母、数字、下划线，首尾不能为下划线，不能出现连续2个下划线 ）",filePath,folder)
				return
			end
		end
	
		assert(not fileNames[fileName],string.format("lua文件存在相同命名[%s][%s]",fileNames[fileName],filePath))
		fileNames[fileName] = filePath
	
		--首字母非大写
		local firstChar = string.byte(fileName,1)
		if firstChar < string.byte("A") or firstChar > string.byte("Z") then
			return
		end
	
		local className = fileName
	
		local excludeExtFilePath = CS.IOUtils.GetPathExcludeExt(filePath,false)
		ClassToFile[className] = excludeExtFilePath
	
		local moduleLocalPath = CS.IOUtils.SubPath(filePath,"module/")
		if filePath == moduleLocalPath then return end
	
		local index =  string.find(moduleLocalPath,"/")
		if index == nil then return end
	
		local moduleFacadeName = ""
		local moduleName = string.sub(moduleLocalPath, 1, index-1)
		for str in string.gmatch(moduleName,"%a+") do
			local cell = string.sub(string.upper(str),1,1) ..string.sub(str,2)
			moduleFacadeName = moduleFacadeName ..cell
		end
		moduleFacadeName = moduleFacadeName.."Facade"
	
		local num = ModuleMapping[moduleFacadeName] or 0
		ModuleMapping[moduleFacadeName] = num + 1
		ClassToModule[className] = moduleFacadeName
	end
	
	local function ParseDataFile(file)
		local fileName = CS.IOUtils.GetFileName(file)
		local configName = ""
		for str in string.gmatch(fileName,"([^_]+)") do
			local cell = string.sub(string.upper(str),1,1) ..string.sub(str,2)
			configName = configName ..cell
		end
	
		local filePath = CS.IOUtils.SubPath(file,dataPath)
		local excludeExtFilePath = CS.IOUtils.GetPathExcludeExt(filePath,false)
		DataToFile[configName] = "data/"..excludeExtFilePath
	end


	local files = CS.IOUtils.GetFiles(luaPath,"lua")
	for i=0,files.Length-1 do ParseLuaFile(files[i]) end
	
	local files = CS.IOUtils.GetFiles(dataPath,"lua")
	for i=0,files.Length-1 do ParseDataFile(files[i]) end

	for k,v in pairs(ClassToFile) do
		FileToClass[v] = k
	end
end


-----------------------------------------------------------------------------
local parentG = {}
local __ClassLoaded = {}
local __CSTypes = {}
local __activeCS = true 
setmetatable(_G, parentG)
parentG.__index = function(t, k)
    local requireName = ClassToFile[k]
    if requireName and not __ClassLoaded[requireName] then
        __ClassLoaded[requireName] = true
        if require (ClassToFile[k]) then
            return _G[k]
        else
            return false
        end
	else
		local csType = GetCSharp(k)
        if csType and __activeCS then
            _G[k] = csType
			__CSTypes[k] = csType
            return csType
        end
    end
end

Config = Config or {}
local dataG = {}
local __Dataoaded = {}
setmetatable(Config, dataG)
dataG.__index = function(t, k)
    local requireName = DataToFile[k]
    if requireName and not __Dataoaded[requireName] then
        __Dataoaded[requireName] = true
        if require (DataToFile[k]) then
			Config[k] = _G[k]
			return Config[k]
        else
            return false
        end
    end
end

function ActiveCSType(flag)
	__activeCS = flag
	for k,v in pairs(__CSTypes) do
		if flag then
			_G[k] = v
		else
			_G[k] = nil
			package.loaded[k] = nil
		end
	end
end

function GetClass(className)
	return _G[className]
end
-----------------------------------------------------------------------------


function TI18N(data)
	return data
end

--require "base/component/ext_Component"
require "base/component/base/ext_Transform"
require "base/component/base/ext_GameObject"

require "base/component/ui/ext_Button"
require "base/component/ui/ext_Dropdown"
require "base/component/ui/ext_EventTrigger"
require "base/component/ui/ext_Image"
require "base/component/ui/ext_InputField"
require "base/component/ui/ext_RectTransform"
require "base/component/ui/ext_ScrollRect"
require "base/component/ui/ext_Slider"
require "base/component/ui/ext_Text"
require "base/component/ui/ext_Toggle"

if CS.UnityEngine.Application.platform ~= CS.UnityEngine.RuntimePlatform.WebGLPlayer then
	require "base/component/math/ext_Mathf"
	require "base/component/math/ext_Vector2"
	require "base/component/math/ext_Vector3"
	require "base/component/math/ext_Vector4"
	require "base/component/math/ext_Quaternion"
	require "base/component/math/ext_Color"
	require "base/component/math/ext_Ray"
	require "base/component/math/ext_Bounds"
end


require "common/fixpoint/InitFixPoint"

--Socket = require "tolua/socket”
--CJson = require "cjson"
---------------------------------------------------------------------------------------


-- if CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.WebGLPlayer then
-- 	local _ = _G["AssetPath"]
-- 	for k,v in pairs(ClassToFile) do
-- 		local _ = _G[k]
-- 	end

-- 	for k,v in pairs(DataToFile) do
-- 		local _ = Config[k]
-- 	end
-- end