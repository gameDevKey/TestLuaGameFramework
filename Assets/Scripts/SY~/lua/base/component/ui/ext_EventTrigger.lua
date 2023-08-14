local base = xlua.getmetatable(EventTrigger)
local __baseindex = base.__index
local __extends = {}

--扩展
function __extends.SetEvent(self,eventType,cb,arg1,arg2,arg3)
	self.triggers:Clear()
	local entry = EventTrigger.Entry()
	entry.eventID = eventType
	entry.callback:AddListener(function(pointerData) cb(pointerData,arg1,arg2,arg3) end)
	self.triggers:Add(entry)
	return entry
end

function __extends.AddEvent(self,eventType,cb,arg1,arg2,arg3)
	local entry = EventTrigger.Entry()
	entry.eventID = eventType
	entry.callback:AddListener(function(pointerData) cb(pointerData,arg1,arg2,arg3) end)
	self.triggers:Add(entry)
	return entry
end

function __extends.ClearEvent(self)
	self.triggers:Clear()
end

--
base.__index = function(t,k)
	if __extends[k] then
		return __extends[k]
	else
		return __baseindex(t,k)
	end
end
xlua.setmetatable(EventTrigger, base)