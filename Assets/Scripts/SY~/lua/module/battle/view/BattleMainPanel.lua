BattleMainPanel = BaseClass("BattleMainPanel",BasePanel)

BattleMainPanel.Event = EventEnum.New()

BattleMainPanel.SortingOrder = {}

function BattleMainPanel:__Init()
	--self:SetAsset("ui/prefab/battle/battle_main_panel.prefab")

	self.childViews = {}

	self.OnRandomHeroClick = self:ToFunc("RandomHeroClick")
end

function BattleMainPanel:__ExtendView()
	self.flyingTextView = self:ExtendView(FlyingTextView)

	self:ExtendView(BattleMixedView)
	self:ExtendView(BattleMixedEffectView)
	self.battleInfoView = self:ExtendView(BattleInfoView)  --TODO  场景化战斗信息修改为2dUI
	self:ExtendView(BattleHeroGridView)  --TODO  场景化战斗信息修改为2dUI
	self:ExtendView(BattleSelectHeroView)
	-- self:ExtendView(BattleHeroOutputView)
	self:ExtendView(BattleHeroStatisticsView)
	self:ExtendView(BattleDialogPanel)

	self:ExtendView(BattleEnemyGridView)
	self:ExtendView(BattleHaloTipsView)
	self:ExtendView(BattleDragRelSkillView)
	self:ExtendView(BattleBridgeView)
	self:ExtendView(BattleCommanderDragSkillView)
	self:ExtendView(BattleSituationView)
	self:ExtendView(BattleStarUpView)

	self:ExtendView(BattleEnterPerformView)
	self:ExtendView(BattleResultPerformView)

	-- self:ExtendView(BattleSkillBannerView)
end

function BattleMainPanel:__Create()
	self.lockScreenNode:GetComponent(Canvas).sortingOrder = ViewDefine.Layer["BattleMainPanel_Lock"]
	ViewManager.Instance:Adaptive(self:Find("main/top_node",RectTransform),true,false)
end

function BattleMainPanel:__CacheObject()
	--头顶UI
	BattleDefine.uiObjs["template/entity_top/hero"] = self:Find("template/entity_top/hero").gameObject
	BattleDefine.uiObjs["template/entity_top/home"] = self:Find("template/entity_top/home").gameObject
	--BattleDefine.uiObjs["template/entity_top/guard_item"] = self:Find("template/entity_top/guard_item").gameObject

	BattleDefine.uiObjs["entity_top"] = self:Find("main/entity_top")
	BattleDefine.uiObjs["fly_text"] = self:Find("main/fly_text")

	BattleDefine.uiObjs["place_slot_ui"] = self:Find("main/place_slot_ui")
	BattleDefine.uiObjs["mixed_effect"]  =self:Find("main/mixed_effect")
	--飘字
	-- BattleDefine.uiObjs["template/fly_text/phy_dmg"] = self:Find("template/fly_text/phy_dmg").gameObject
	-- BattleDefine.uiObjs["template/fly_text/magic_dmg"] = self:Find("template/fly_text/magic_dmg").gameObject
	-- BattleDefine.uiObjs["template/fly_text/heal"] = self:Find("template/fly_text/heal").gameObject
	-- BattleDefine.uiObjs["template/fly_text/skill_name"] = self:Find("template/fly_text/skill_name").gameObject
	-- BattleDefine.uiObjs["template/fly_text/cont_kill"] = self:Find("template/fly_text/cont_kill").gameObject


	self.lockScreenNode = self:Find("lock_screen").gameObject


	self.angleSlider =  self:Find("angle_debug",Slider)
    self.angleText =  self:Find("angle_debug/Text",Text)
	self.angleText.text = 0
end

function BattleMainPanel:__BindListener()
	self:Find("main/operate/random_buy_btn",Button):SetClick( self:ToFunc("RandomHeroClick") )
	self.angleSlider:SetClick(self:ToFunc("AngleChange"))
end

function BattleMainPanel:__BindEvent()
	self:BindEvent(BattleFacade.Event.ActiveLockScreen)
	self:BindEvent(BattleFacade.Event.ActiveMainPanel)
end

function BattleMainPanel:__Show()
	self:ActiveLockScreen(true)
end

function BattleMainPanel:__Hide()
	for k,v in ipairs(self.childViews) do
		v:Destroy()
	end
	self.childViews = {}

	self:ActiveLockScreen(false)
end

function BattleMainPanel:Update()
	self.flyingTextView:Update()
	self.battleInfoView:Update()
end

function BattleMainPanel:RandomHeroClick()
	local roleUid = RunWorld.BattleDataSystem.roleUid

	-- local existWaitSelectUnits = RunWorld.BattleDataSystem:ExistWaitSelectUnits(roleUid)
	-- if existWaitSelectUnits then
	-- 	SystemMessage.Show(TI18N("请选取需要的卡牌"))
	-- 	return
	-- end

	local needMoney = RunWorld.BattleDataSystem:GetRandomCostMoney(roleUid)
    local flag = RunWorld.BattleDataSystem:HasMoney(roleUid,needMoney)
	if not flag then
		SystemMessage.Show(TI18N("能量不足，请等待回合开始时补充"))
		return
	end

	RunWorld.BattleInputSystem:AddRandomUnits()

	self.battleInfoView:CheckRandomUnitTips()

	-- local flag,opIndex = RunWorld.BattleInputSystem:AddOp(BattleDefine.Operation.random_hero)
	-- if flag then
	-- 	mod.BattleFacade:SendMsg(10405,opIndex)
	-- 	local flag,opIndex = RunWorld.BattleInputSystem:AddOp(BattleDefine.Operation.random_hero)
	-- else
	-- 	SystemMessage.Show(TI18N("操作过于频繁"))
	-- end
end

function BattleMainPanel:ActiveLockScreen(flag)
	self.lockScreenNode:SetActive(flag)
	BattleDefine.nodeObjs["mixed/commander_collider"].gameObject:SetActive(not flag)
end

function BattleMainPanel:ActiveMainPanel(flag)
	self:SetActive(self.transform,flag)
end

function BattleMainPanel:AngleChange()
    local angle = tostring(self.angleSlider.value)
	self.angleText.text = string.format("%.3f",angle)
	DEBUG_TPOSE_ANGLE = angle

	for iter in RunWorld.EntitySystem.entityList:Items() do
        local uid = iter.value
        local entity = RunWorld.EntitySystem:GetEntity(uid)

        if entity and RunWorld.EntitySystem:HasEntity(uid) and entity.TagComponent.mainTag == BattleDefine.EntityTag.hero  then
			entity.clientEntity.ClientTransformComponent:SetRightAxis(DEBUG_TPOSE_ANGLE)
			entity.clientEntity.ClientTransformComponent:SyncPos()
        end
    end
end