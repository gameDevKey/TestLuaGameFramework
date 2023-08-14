SwapUnitGuideNode = BaseClass("SwapUnitGuideNode",ClickObjGuideNodeBase)

function SwapUnitGuideNode:__Init()
    self.targetScreenPos = nil
    self.eventUid = nil

    self.moveEffect = nil
    self.moveEffectAnim = nil

    self.listenUid = nil
end

function SwapUnitGuideNode:OnInit()
end

function SwapUnitGuideNode:OnStart()
    self.listenUid = mod.PlayerGuideCtrl:ListenPointer(self:ToFunc("PointerDown"),nil,nil)

    mod.BattleFacade:SendEvent(BattleHeroGridView.Event.LimitSwapGird,{fromGrid = self.actionParam.fromGrid,toGrid = self.actionParam.toGrid})
    mod.BattleFacade:SendEvent(BattleHeroGridView.Event.EnableGridTips,false)
    mod.BattleFacade:SendEvent(BattleHeroGridView.Event.EnableRecycle,false)


    local eventParam = {}
    eventParam.fromGrid = self.actionParam.fromGrid
    eventParam.toGrid = self.actionParam.toGrid
    self.eventUid = mod.PlayerGuideEventCtrl:AddListener(PlayerGuideDefine.Event.swap_unit_grid,self:ToFunc("OnEvent"),eventParam)

    --
    local toGridWorldPos = RunWorld.BattleMixedSystem:GetPlaceSlotPos(self.actionParam.toGrid)  -- TODO 场景化UI修改为2dUI
    toGridWorldPos = Vector3(toGridWorldPos.x,toGridWorldPos.y,toGridWorldPos.z)


    self.targetScreenPos = BaseUtils.WorldToUIPoint(BattleDefine.nodeObjs["main_camera"],toGridWorldPos)


    self:CreateMoveEffect()

    local moveAnim = MoveLocalAnim.New(self.moveEffect.transform,self.targetScreenPos,self.actionParam.moveTime)
    local delayAnim = DelayAnim.New(1)
    self.moveEffectAnim = SequenceAnim.New({moveAnim,delayAnim})
    self.moveEffectAnim:SetComplete(self:ToFunc("MoveEffectAnimFinish"))
    self.moveEffectAnim:Play()
end

function SwapUnitGuideNode:MoveEffectAnimFinish()
    local x,y = self:GetTargetPos()
    self.moveEffect:SetPos(x,y)
    self.moveEffectAnim:Play()
end

function SwapUnitGuideNode:CreateMoveEffect()
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


function SwapUnitGuideNode:PointerDown(pointerData,args)
    local clickObj = self:GetClickObj(pointerData)
    if clickObj then
        CustomUnityUtils.PointerDownHandler(clickObj,pointerData)
    end 
end

function SwapUnitGuideNode:OnEvent(param)
	self:RemoveEvent()
	self.timeline:SetForceFinish(true)
end

function SwapUnitGuideNode:RemoveEvent()
	if self.eventUid then
		mod.PlayerGuideEventCtrl:RemoveListener(self.eventUid)
		self.eventUid = nil
	end
end

function SwapUnitGuideNode:OnDestroy()
    if self.listenUid then
        mod.PlayerGuideCtrl:CancelListenPointer(self.listenUid)
        self.listenUid = nil
    end

    mod.BattleFacade:SendEvent(BattleHeroGridView.Event.LimitSwapGird,nil)
    -- mod.BattleFacade:SendEvent(BattleHeroOperateView.Event.EnableGridTips,true)--TODO 2dUI
    -- mod.BattleFacade:SendEvent(BattleHeroOperateView.Event.EnableRecycle,true)

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

function SwapUnitGuideNode:OnAutoRun()
    -- local obj = self.timeline.targetArgs.targetObj
    -- if not obj then
    --     self:OnAutoRunFailed("未找到目标引导位置")
    --     return
    -- end
    -- local data = PointerEventData(EventSystem.current)
    -- data.pointerId = 1
    -- CustomUnityUtils.PointerDownHandler(obj, data)
    -- CustomUnityUtils.PointerUpHandler(obj, data)
    -- CustomUnityUtils.PointerClickHandler(obj, data)

    -- local pos = BaseUtils.WorldToScreenPoint(UIDefine.uiCamera,obj.transform.position)
    -- local cancelData = {}
    -- cancelData.fingerId = 1
	-- cancelData.pos = pos
	-- cancelData.beginPos = pos
	-- TouchManager.Instance:NoticeListen(TouchDefine.TouchEvent.cancel,cancelData)

    -- self:OnAutoRunSuccess(false)
end