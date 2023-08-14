GuideAction = BaseClass("GuideAction")

function GuideAction:__Init()
    self.uid = 0
    self.guideId = 0
    self.conf = nil
    self.guideTrigger = nil
    self.targetPosFinder = nil

    self.targetPosArgs = nil
    self.triggerArgs = nil

    self.guideTimeline = nil

    self.lockScreenUid = nil
end

function GuideAction:__Delete()

end

function GuideAction:Init(guideId)
    self.guideId = guideId
    self.conf = Config.PlayerGuideData.data_guide_info[guideId]
    self:TryLockScreen(true)
    self:CreateGuideTrigger()
end

function GuideAction:Start()
end

function GuideAction:CreateTargetFinder()
    local posType = self.conf.target_pos.type

    local class  = nil
    if PlayerGuideDefine.TargetPosFinder[posType] then
        class = _G[PlayerGuideDefine.TargetPosFinder[posType]]
    end
    if not class then
        assert(false,string.format("未实现的目标位置查找器[引导Id:%s][目标位置查找器类型:%s]",self.guideId,tostring(posType)))
    end

    LogGuide("创建查找器 参数",self.conf.target_pos)

    self.targetPosFinder = class.New()
    self.targetPosFinder:Init(self)
    self:Update(0)
end

function GuideAction:Update(deltaTime)
    if self.guideTrigger then
        self.guideTrigger:Update(deltaTime)
    end

    if self.targetPosFinder then
        self.targetPosFinder:Update(deltaTime)
    end

    if self.guideTimeline then
        self.guideTimeline:Update(Time.unscaledDeltaTime)
    end
end

function GuideAction:PosFinderFinish(targetArgs)
    LogGuide("查找完成",targetArgs)
    self.targetPosArgs = targetArgs
    self.targetPosFinder:Delete()
    self.targetPosFinder = nil
    self:TryLockScreen(false)
    self:CreateGuideTimeline(targetArgs)
end

function GuideAction:CreateGuideTrigger()
    self.guideTrigger = MixLogicTrigger.New()
    self.guideTrigger:Init(self)
    self:Update(0)
end

--触发完成
function GuideAction:TriggerFinish(param)
    LogGuide("触发完成",param)
    self.triggerArgs = param

    if self.guideTrigger then
        self.guideTrigger:Delete()
        self.guideTrigger = nil
    end

    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.trigger_guide,self.guideId)

    self:CreateTargetFinder()
end


function GuideAction:CreateGuideTimeline(targetArgs)
    LogGuide("创建引导timeline",self.conf.act_id)
    local actConf = Config["PlayerGuide"..tostring(self.conf.act_id)]
    if not actConf then
        assert(false,string.format("找不到引导行为配置[引导Id:%s][行为Id:%s]",self.guideId,self.conf.act_id))
    end

    self.guideTimeline = GuideTimeline.New()
    self.guideTimeline:Init(actConf)
    self.guideTimeline:SetGuideAction(self)
    self.guideTimeline:SetTargetArgs(targetArgs)
    self.guideTimeline:SetComplete(self:ToFunc("TimelineFinish"))
    self.guideTimeline:Start()
end

function GuideAction:TimelineFinish()
    LogGuide("引导timeline完成")
    self.guideTimeline:Destroy()
    self.guideTimeline = nil

    for _, id in ipairs(self.conf.close_id) do
        local action = PlayerGuideProxy:GetGuideAction(id)
        if action then
            action:TimelineFinish()
        end
    end

    mod.PlayerGuideCtrl:NextGuide(self.guideId)
end

--进行触发引导了
function GuideAction:GuideTrigger()

end

function GuideAction:TryLockScreen(isLock)
    if self.conf.is_lock == 0 then
        return
    end
    if isLock then
        self.lockScreenUid = mod.PlayerGuideCtrl:LockScreen()
        LogGuide("锁屏 ID:",self.lockScreenUid)
    else
        if self.lockScreenUid then
            LogGuide("取消锁屏 ID:",self.lockScreenUid)
            mod.PlayerGuideCtrl:CancelLockScreen(self.lockScreenUid)
            self.lockScreenUid = nil
        end
    end
end