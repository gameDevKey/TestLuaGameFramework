Config = {}

local confs = {}

local function loadConfig(confName)
	local conf =  RequireData(confName)
	if not conf then LogErrorf(string.format("不存在的配置表[配置表:%s]",confName)) end
	confs[confName] = conf
	return conf
end

function Config.Init()

end

function Config.Get(confName,sheetName,keyIndex,key)
	local conf = confs[confName] or loadConfig(confName)
	if not conf then return end

	local confData,errCode = conf.Get(sheetName,keyIndex,key)
	
	if not errCode then return confData end

	if errCode == ConfigDefine.Error.not_sheet then 
		LogErrorf("不存在的Sheet[配置表:%s][sheet:%s]",confName,sheetName) 
	end

	if errCode == ConfigDefine.Error.not_index then 
		LogErrorf("不存在的键值索引[配置表:%s][sheet:%s][索引:(%s)][key:%s]",confName,sheetName,keyIndex,key) 
	end
end

function Config.Getf(confName,sheetName,keyIndex,...)
	local key = table.concat({...}, "_")
	return Config.Get(confName,sheetName,keyIndex,key),key
end

function Config.GetMap(levelId)
	local confName = "map_"..tostring(levelId)
	local conf = confs[confName] or loadConfig(confName)
	return conf
end

function Config.GetSkill(skillId)
	local confName = "skill_"..tostring(skillId)
	local conf = confs[confName] or loadConfig(confName)
	return conf
end

function Config.GetLua(luaType,key)
	local confName = luaType .. "_" .. tostring(key)
	return Config[confName]
end

function Config.Set(confName,sheetName,index,data)
	local conf = confs[confName] or loadConfig(confName)
	if not conf then return false end
	return conf.Set(sheetName,index,data)
end

function Config.GetNum(confName,sheetName)
	local conf = confs[confName] or loadConfig(confName)
	if not conf then return 0 end
	return conf.GetNum(sheetName)
end