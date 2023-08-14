DragUseMagicCardGuideNode = BaseClass("DragUseMagicCardGuideNode",ClickObjGuideNodeBase)

function DragUseMagicCardGuideNode:__Init()
    self.targetRange = nil
    self.targetScreenPos = nil
    self.eventUid = nil

    self.moveEffect = nil
    self.moveEffectAnim = nil

    self.listenUid = nil
end

function DragUseMagicCardGuideNode:OnInit()
end

function DragUseMagicCardGuideNode:OnStart()
    self.listenUid = mod.PlayerGuideCtrl:ListenPointer(self:ToFunc("PointerDown"),nil,nil)

    mod.BattleFacade:SendEvent(BattleSelectHeroView.Event.EnableTips,false)

    mod.BattleFacade:SendEvent(BattleDragRelSkillView.Event.LimitRelRange,{posX = self.actionParam.posX,posZ = self.actionParam.posZ,range = self.actionParam.range})

    local eventParam = {}
    self.eventUid = mod.PlayerGuideEventCtrl:AddListener(PlayerGuideDefine.Event.use_magic_card,self:ToFunc("OnEvent"),eventParam)

    self:CreateRange()

    self:CreateMoveEffect()
    local moveAnim = MoveLocalAnim.New(self.moveEffect.transform,self.targetScreenPos,self.actionParam.moveTime)
    --moveAnim:Play()

    local delayAnim = DelayAnim.New(1)

    self.moveEffectAnim = SequenceAnim.New({moveAnim,delayAnim})
    self.moveEffectAnim:SetComplete(self:ToFunc("MoveEffectAnimFinish"))
    self.moveEffectAnim:Play()
end

function DragUseMagicCardGuideNode:MoveEffectAnimFinish()
    local x,y = self:GetTargetPos()
    self.moveEffect:SetPos(x,y)
    self.moveEffectAnim:Play()
end

function DragUseMagicCardGuideNode:CreateRange()
    self.targetRange = RangeBase.Create(self.actionParam.range.type)
    self.targetRange:SetParent(BattleDefine.nodeObjs["mixed"])
    self.targetRange:SetRange(self.actionParam.range)
    self.targetRange:SetOffsetY(0.05)
    self.targetRange:CreateRange()

    self.targetRange:SetTransform(Vector3(self.actionParam.posX * FPFloat.PrecisionFactor,0,self.actionParam.posZ * FPFloat.PrecisionFactor),nil)

    local worldPos = Vector3(self.actionParam.posX * FPFloat.PrecisionFactor,0.05,self.actionParam.posZ * FPFloat.PrecisionFactor)

    self.targetScreenPos = BaseUtils.WorldToUIPoint(BattleDefine.nodeObjs["main_camera"],worldPos)
end

function DragUseMagicCardGuideNode:CreateMoveEffect()
    local x,y = self:GetTargetPos()

    local setting = {}
    setting.confId = 10007
    setting.parent = PlayerGuideDefine.contentTrans
    setting.order = ViewDefine.Layer["PlayerGuideView_Effect"]

	self.moveEffect = UIEffect.New()
    self.moveEffect:Init(setting)
    self.moveEffect:SetPos(x,y)
    self.moveEffect:Play()
end

function DragUseMagicCardGuideNode:RemoveTargetRange()
    if self.targetRange then
        self.targetRange:Delete()
        self.targetRange = nil
    end
end

function DragUseMagicCardGuideNode:PointerDown(pointerData,args)
    local clickObj = self:GetClickObj(pointerData)
    if clickObj then
        CustomUnityUtils.PointerDownHandler(clickObj,pointerData)
    end 
end

function DragUseMagicCardGuideNode:OnEvent(param)
	self:RemoveEvent()
	self.timeline:SetForceFinish(true)
end

function DragUseMagicCardGuideNode:RemoveEvent()
	if self.eventUid then
		mod.PlayerGuideEventCtrl:RemoveListener(self.eventUid)
		self.eventUid = nil
	end
end

function DragUseMagicCardGuideNode:OnDestroy()
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