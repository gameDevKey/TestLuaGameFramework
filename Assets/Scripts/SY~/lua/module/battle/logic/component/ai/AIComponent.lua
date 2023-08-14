AIComponent = BaseClass("AIComponent",SECBComponent)

function AIComponent:__Init()
    self.behaviorTrees = SECBList.New()
end

function AIComponent:__Delete()
    for iter in self.behaviorTrees:Items() do
        iter.value:Delete()
    end
    self.behaviorTrees:Delete()
end

function AIComponent:OnInit()
    
end

function AIComponent:OnUpdate()
    if not self.world.BattleStateSystem:IsBattleResult(BattleDefine.BattleResult.none) then
        return
    end

    if self.entity.isUidSingle ~= self.world.isSingleFrame then
        return
    end

    for iter in self.behaviorTrees:Items() do
        iter.value:Update(self.world.opts.frameDeltaTime)
    end
end

function AIComponent:AddAI(id,args)
    local aiConf = self.world.BattleConfSystem:AIBehaviorTree(id)
    if not aiConf then
        assert(false,string.format("AI配置不存在[AI:%s]",id))
    end

    local behaviorTree = BTUtils.Create(AIBehaviorTree,aiConf,self.world,self.entity)
    behaviorTree:Start(args)
    self.behaviorTrees:Push(behaviorTree)
end