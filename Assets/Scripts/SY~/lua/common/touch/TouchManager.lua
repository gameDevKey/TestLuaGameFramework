TouchManager = SingleClass("TouchManager")

local Input = Input

local uniqueId = 0
local function GetUniqueId() uniqueId = uniqueId + 1 return uniqueId end

function TouchManager:__Init( )
    self.listens = {}
    self.listens[TouchDefine.TouchEvent.begin] = List.New()
    self.listens[TouchDefine.TouchEvent.move] = List.New()
    self.listens[TouchDefine.TouchEvent.moveed] = List.New()
	self.listens[TouchDefine.TouchEvent.cancel] = List.New()

	self.listenIters = {}
	
	self.touchList = {}
	for i=1,20 do table.insert( self.touchList,TouchData.New() ) end

	self.beginData = {}
	self.moveData = {}
	self.moveedData = {}
	self.cancelData = {}
end

function TouchManager:__Delete()
end

function TouchManager:Clean()
	self.listenIters = {}
end

function TouchManager:Update(delta)
	if self:IsMouse() then
		self:MouseTouch()
	else
		self:FingerTouch()
	end
end

--window触摸
function TouchManager:MouseTouch()
	local touchData = self.touchList[1]

	local mousePosition =  Vector2(Input.mousePosition.x,Input.mousePosition.y)

	if Input.GetMouseButtonDown(0) then
		touchData.isDown = true
		touchData.lastPos = Vector2(mousePosition.x,mousePosition.y)
		touchData.beginPos = Vector2(mousePosition.x,mousePosition.y)
		self.beginData.fingerId = 0
		self.beginData.pos = touchData.lastPos
		self:NoticeListen(TouchDefine.TouchEvent.begin,self.beginData)
	elseif Input.GetMouseButtonUp(0) then
		touchData.isDown = false
		self.cancelData.fingerId = 0
		self.cancelData.pos = Vector2(mousePosition.x,mousePosition.y)
		self.cancelData.beginPos = touchData.beginPos
		self:NoticeListen(TouchDefine.TouchEvent.cancel,self.cancelData)
	end

	if  touchData.isDown and touchData.lastPos ~= mousePosition then
		local deltaPos = Vector2(mousePosition.x,mousePosition.y) - touchData.lastPos
		touchData.lastPos = Vector2(mousePosition.x,mousePosition.y)
		touchData.noticeMoveed = true
		self.moveData.fingerId = 0
		self.moveData.pos = touchData.lastPos
		self.moveData.deltaPos = deltaPos
		self.moveData.beginPos = touchData.beginPos
		self:NoticeListen(TouchDefine.TouchEvent.move,self.moveData)
	elseif touchData.noticeMoveed then
		touchData.noticeMoveed = false
		self.moveedData.fingerId = 0
		self.moveedData.pos = touchData.lastPos
		self.moveedData.beginPos = touchData.beginPos
		self:NoticeListen(TouchDefine.TouchEvent.moveed,self.moveedData)
	end
end

--手指触摸
function TouchManager:FingerTouch()
	local touchCount = Input.touchCount
	if touchCount <= 0 then return end
	for i=0,touchCount-1 do self:FingerTouchIndex(i) end
end

function TouchManager:FingerTouchIndex(index)
	local touch = Input.GetTouch(index)

	local fingerId = touch.fingerId

	local touchData = self.touchList[fingerId + 1]
	if not touchData then
		return 
	end

	if touch.phase == TouchPhase.Began then
		touchData.isDown = true
		touchData.lastPos = touch.position
		self.beginData.fingerId = 0
		self.beginData.pos = touchData.lastPos
		self:NoticeListen(TouchDefine.TouchEvent.begin,self.beginData)
	elseif touch.phase == TouchPhase.Ended then
		touchData.isDown = false
		self.cancelData.fingerId = 0
		self.cancelData.pos = touch.position
		self.cancelData.beginPos = touchData.beginPos
		self:NoticeListen(TouchDefine.TouchEvent.cancel,self.cancelData)
	end

	if touchData.isDown and touchData.lastPos ~= touch.position then
		local deltaPos = touch.position - touchData.lastPos
		touchData.lastPos = touch.position
		touchData.noticeMoveed = true
		self.moveData.fingerId = 0
		self.moveData.pos = touchData.lastPos
		self.moveData.deltaPos = deltaPos
		self.moveData.beginPos = touchData.beginPos
		self:NoticeListen(TouchDefine.TouchEvent.move,self.moveData)
	elseif touchData.noticeMoveed then
		touchData.noticeMoveed = false
		self.moveedData.fingerId = 0
		self.moveedData.pos = touchData.lastPos
		self.moveedData.beginPos = touchData.beginPos
		self:NoticeListen(TouchDefine.TouchEvent.moveed,self.moveedData)
	end
end

function TouchManager:GetPos(index)
	if index == -1 then index = 0 end
	local touchData = self.touchList[index + 1]
	return touchData.lastPos
end


function TouchManager:IsMouse()
	if GDefine.platform == GDefine.PlatformType.IPhonePlayer then return false end
	if GDefine.platform == GDefine.PlatformType.Android then return false end
	return true
end

function TouchManager:NoticeListen(touchEvent,data)
	local listens = self.listens[touchEvent]
	if not listens then return end

	for listen in listens:Items() do
		if not listen.value.index or listen.value.index == data.fingerId then
			listen.value.callBack(data,listen.value.param)
		end
	end
end

function TouchManager:AddListen(touchEvent,callBack,index,param)
	if index == -1 then index = 0 end
	assert(self.listens[touchEvent] ~= nil,string.format("不存在的触摸事件[event:%s]",tostring(touchEvent)))
	local iter = self.listens[touchEvent]:Push( { callBack = callBack,index = index,param = param } )
	local id = GetUniqueId()
	self.listenIters[id] = { touchEvent = touchEvent,iter = iter }
	return id
end

function TouchManager:ChangeListenIndex(id,index)
	local listen = self.listenIters[id]
	if not listen then return end
	listen.iter.value.index = index
end

function TouchManager:RemoveListen(id)
	local listen = self.listenIters[id]
	if not listen then return end
	self.listens[listen.touchEvent]:Remove(listen.iter)
	self.listenIters[id] = nil
end