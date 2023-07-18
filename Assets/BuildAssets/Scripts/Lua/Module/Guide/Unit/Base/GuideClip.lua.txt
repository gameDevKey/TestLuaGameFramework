--新手引导片段，找到所有目标位置后才会运行Action
GuideClip = Class("GuideClip", GuideModuleBase)

function GuideClip:OnInit(timeline, data, callback)
    self.timeline = timeline
    self.data = data
    self.callback = callback
    self.finders = {}
    self.finderResults = {}
    self.finderAmount = self.data.Find and #self.data.Find or 0
    self.action = nil
    self:Start()
end

function GuideClip:OnUpdate(deltaTime)
    for _, finder in ipairs(self.finders) do
        finder:Update(deltaTime)
    end
    if self.action then
        self.action:Update(deltaTime)
    end
end

function GuideClip:OnDelete()
    for _, finder in ipairs(self.finders or NIL_TABLE) do
        finder:Delete()
    end
    self.finders = nil
    if self.action then
        self.action:Delete()
        self.action = nil
    end
end

function GuideClip:Start()
    PrintGuide("片段开始")
    for index, data in ipairs(self.data.Find or NIL_TABLE) do
        data.Args = data.Args or {}
        data.Args._FinderIndex = index
        self.finders[index] = self:CreateFinder(
            EGuideModule.FinderMap[data.Type],
            data.Args
        )
    end
    self:TryStartAction()
end

function GuideClip:CreateFinder(clsName, args)
    PrintGuide("创建查找器", clsName, args._FinderIndex)
    local finder = _G[clsName].New(self, args, self:ToFunc("FinishFinder"))
    finder:SetFacade(self.facade)
    finder:InitComplete()
    return finder
end

function GuideClip:FinishFinder(result, finder)
    local index = finder.args._FinderIndex
    PrintGuide("完成查找器", index)
    self.finderResults[index] = result or true
    self.finders[index] = nil
    finder:Delete()
    self:TryStartAction()
end

function GuideClip:TryStartAction()
    local len = #self.finderResults
    PrintGuide("已找到位置：", len, '/', self.finderAmount)
    if len == self.finderAmount then
        if self.data.Action and self.data.Action.Type then
            self.action = self:CreateAction(
                EGuideModule.ActionMap[self.data.Action.Type],
                self.data.Action.Args,
                self.finderResults
            )
        else
            self:Finish()
        end
    end
end

function GuideClip:CreateAction(clsName, args, finderResults)
    PrintGuide("创建行为", clsName)
    local action = _G[clsName].New(self, args, finderResults, self:ToFunc("Finish"))
    action:SetFacade(self.facade)
    action:InitComplete()
    return action
end

function GuideClip:Finish()
    PrintGuide("片段结束")
    if self.action then
        self.action:Delete()
        self.action = nil
    end
    _ = self.callback and self.callback()
end

return GuideClip
