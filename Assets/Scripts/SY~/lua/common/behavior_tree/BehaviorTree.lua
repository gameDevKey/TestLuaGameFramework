BehaviorTree = BaseClass("BehaviorTree")

function BehaviorTree:__Init()
    self.id = 0
    self.nodes = {}
    self.nodeList = {}
    self.rootNode = nil
    self.sharedData = nil

    self.enable = false
    self.paused = false
    
    self.cacheData = {}
    self.args = nil
    --self.inputData = nil
    self.callBack = nil
    self.gameObject = nil
end

function BehaviorTree:__Delete()
    for _,nodeId in ipairs(self.nodeList) do
        self.nodes[nodeId]:Delete()
	end
end

function BehaviorTree:Init(id,nodeList,...)
    self.id = id
    self.nodeList = nodeList
    self:OnInit(...)
end

function BehaviorTree:SetCacheData(key,data)
	self.cacheData[key] = data
end

function BehaviorTree:GetCacheData(key)
	return self.cacheData[key]
end

function BehaviorTree:SetGameObject(gameObject)
    self.gameObject = gameObject
end

function BehaviorTree:IsEnable()
    return self.isEnable
end

function BehaviorTree:Start(args)
    if self.enable then
        return
    end

    self.enable = true
    self.args = args
    --self.inputData  = data.inputData
    --self.cbInfo = data.cbInfo
end

function BehaviorTree:Pause(paused)
    self.paused = paused
    for _,nodeId in ipairs(self.nodeList) do
        self.nodes[nodeId]:Pause()
	end
end

function BehaviorTree:Restart()
    for _,nodeId in ipairs(self.nodeList) do
        self.nodes[nodeId]:Restart()
	end
end

function BehaviorTree:Abort()

end

function BehaviorTree:Update(deltaTime)
    if not self.enable or self.paused then
        return
    end

	local status = self.rootNode:Update(deltaTime)
	if status ~= BTTaskStatus.Success and status ~= BTTaskStatus.Failure then 
        return 
    end

    for _,nodeId in ipairs(self.nodeList) do
        self.nodes[nodeId]:Complete()
	end

    self.enable = false

    if self.cbInfo then
        self.cbInfo.callBack(self.cbInfo.args)
    end
end

function BehaviorTree:Stop()
    self.enable = false
    self.paused = false
    for _,nodeId in ipairs(self.nodeList) do
        self.nodes[nodeId]:Stop()
	end
end

function BehaviorTree:Create()
    for _,nodeId in ipairs(self.nodeList) do
        self.nodes[nodeId]:Create()
	end
    self:OnCreate()
end


--创建行为树完成
function BehaviorTree:OnInit(...)
end

function BehaviorTree:OnCreate()
end