BTUtils = StaticClass("BTUtils")

function BTUtils.Create(btType,config,...)
    local bt = btType.New()
    bt:Init(config.id,config.nodeList,...)
	
	for i,nodeId in ipairs(bt.nodeList) do
        local nodeInfo = config.nodes[nodeId]
        if not nodeInfo then
            assert(false, string.format("行为树创建异常,节点不存在[行为树Id:%s][节点Id:%s]",bt.id,nodeId))
        end

		local nodeClass = _G[nodeInfo.class]
        if not nodeClass then
            assert(false, string.format("行为树创建异常,节点类型不存在[行为树Id:%s][节点id:%s][class:%s]",bt.id,nodeId,nodeInfo.class))
        end

		local runNode= nodeClass.New()
		runNode.id = nodeId
		runNode.owner = bt
        runNode:SetParams(nodeInfo.params)

        if runNode:CanHasChild() then
            assert(nodeInfo.childs, string.format("行为树创建异常,节点不应该存在子节点属性[行为树Id:%s][节点Id:%s]",bt.id,nodeId))
        end

		runNode:OnAwake()

		bt.nodes[runNode.id] = runNode
	end

	bt.rootNode = bt.nodes[config.rootId]
    if not bt.rootNode then
        assert(false, string.format("行为树创建异常,根节点不存在[行为树Id:%s][根节点Id:%s]",bt.id,tostring(config.rootId)))
    end

    for i,nodeId in ipairs(bt.nodeList) do
        local nodeInfo = config.nodes[nodeId]
        local runNode = bt.nodes[nodeId]
        if runNode:CanHasChild() then
            for _,childNodeId in ipairs(nodeInfo.childs) do
                local childNode = bt.nodes[childNodeId]
                if childNode then
                    runNode:AddChild(childNode)
                else
                    assert(false,string.format("行为树创建异常,子节点不存在[行为树Id:%s][节点Id:%s][子节点Id:%s]",bt.id,runNode.id,childNodeId))
                end
            end
        end
    end

    bt.sharedData = config.sharedData

    bt:Create()

	return bt
end
