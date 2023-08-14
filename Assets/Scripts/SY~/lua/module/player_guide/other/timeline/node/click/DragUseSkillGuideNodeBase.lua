DragUseSkillGuideNodeBase = BaseClass("DragUseSkillGuideNodeBase",ClickObjGuideNodeBase)

function DragUseSkillGuideNodeBase:__Init()
    self.targetRange = nil
    self.targetScreenPos = nil
    self.eventUid = nil

    self.moveEffect = nil
    self.moveEffectAnim = nil

    self.listenUid = nil

    self.guideEvent = nil
end

function DragUseSkillGuideNodeBase:OnInit()
end

function DragUseSkillGuideNodeBase:SetEvent(event)
    self.guideEvent = event
end

function DragUseSkillGuideNodeBase:OnStart()
    self.listenUid = mod.PlayerGuideCtrl:ListenPointer(self:ToFunc("PointerDown"),nil,nil)

    mod.BattleFacade:SendEvent(BattleDragRelSkillView.Event.LimitRelRange,{posX = self.actionParam.posX,posZ = self.actionParam.posZ,range = self.actionParam.range})

    local eventParam = {}
    self.eventUid = mod.PlayerGuideEventCtrl:AddListener(self.guideEvent,self:ToFunc("OnEvent"),eventParam)

    local worldPos = Vector3(self.actionParam.posX * FPFloat.PrecisionFactor,0.05,self.actionParam.posZ * FPFloat.PrecisionFactor)
    self.targetScreenPos = BaseUtils.WorldToUIPoint(BattleDefine.nodeObjs["main_camera"],worldPos)

    self:CreateRange()

    self:CreateMoveEffect()
    local moveAnim = MoveLocalAnim.New(self.moveEffect.transform,self.targetScreenPos,self.actionParam.moveTime)

    local delayAnim = DelayAnim.New(1)

    self.moveEffectAnim = SequenceAnim.New({moveAnim,delayAnim})
    self.moveEffectAnim:SetComplete(self:ToFunc("MoveEffectAnimFinish"))
    self.moveEffectAnim:Play()
end

function DragUseSkillGuideNodeBase:MoveEffectAnimFinish()
    local x,y = self:GetTargetPos()
    self.moveEffect:SetPos(x,y)
    self.moveEffectAnim:Play()
end

function DragUseSkillGuideNodeBase:CreateRange()
    if self.actionParam.range.type == 0 then
        return
    end

    self.targetRange = RangeBase.Create(self.actionParam.range.type)
    self.targetRange:SetParent(BattleDefine.nodeObjs["mixed"])
    self.targetRange:SetRange(self.actionParam.range)
    self.targetRange:SetOffsetY(0.05)
    self.targetRange:CreateRange()

    self.targetRange:SetTransform(Vector3(self.actionParam.posX * FPFloat.PrecisionFactor,0,self.actionParam.posZ * FPFloat.PrecisionFactor),nil)
end

function DragUseSkillGuideNodeBase:CreateMoveEffect()
    local x,y = self:GetTargetPos()

    local setting = {}
    setting.confId = self.actionParam.moveEffectId
    setting.parent = PlayerGuideDefine.contentTrans
    setting.order = ViewDefine.Layer["PlayerGuideView_Effect"]

	self.moveEffect = UIEffect.New()
    self.moveEffect:Init(setting)
    self.moveEffect:SetPos(x,y)
    self.moveEffect:Play()
end

function DragUseSkillGuideNodeBase:RemoveTargetRange()
    if self.targetRange then
        self.targetRange:Delete()
        self.targetRange = nil
    end
end

function DragUseSkillGuideNodeBase:PointerDown(pointerData,args)
    local clickObj = self:GetClickObj(pointerData)
    if clickObj then
        CustomUnityUtils.PointerDownHandler(clickObj,pointerData)
    end 
end

function DragUseSkillGuideNodeBase:OnEvent(param)
	self:RemoveEvent()
	self.timeline:SetForceFinish(true)
end

function DragUseSkillGuideNodeBase:RemoveEvent()
	if self.eventUid then
		mod.PlayerGuideEventCtrl:RemoveListener(self.eventUid)
		self.eventUid = nil
	end
end

function DragUseSkillGuideNodeBase:OnDestroy()
    if self.listenUid then
        mod.PlayerGuideCtrl:CancelListenPointer(self.listenUid)
        self.listenUid = nil
    end

    mod.BattleFacade:SendEvent(BattleSelectHeroView.Event.EnableTips,true)

    mod.BattleFacade:SendEvent(BattleDragRelSkillView.Event.LimitRelRange,nil)

    self:RemoveTargetRange()

    self:RemoveEvent()

    if self.moveEffectAnim then
        self.moveEffectAnim:Destroy()
        self.moveEffectAnim = nil
    end

    if self.moveEffect then
        self.moveEffect:Delete()
        self.moveEffect = nil
    end
end