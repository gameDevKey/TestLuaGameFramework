-- À©Õ¹Unity Material class ·½·¨
local base = getmetatable(Material)
local baseMetatable = getmetatable(base)
local color = {}
setmetatable(base, nil)
local AtlasManager
function base.setUrl(self, path, name)
	if not AtlasManager then
		AtlasManager = require("manager.AtlasManager")
	end
	AtlasManager.setUrl(self, path, 0, nil, name)
end

setmetatable(base, baseMetatable)
