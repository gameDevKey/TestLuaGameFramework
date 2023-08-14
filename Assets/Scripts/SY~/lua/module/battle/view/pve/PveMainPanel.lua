PveMainPanel = BaseClass("PveMainPanel",BasePanel)

PveMainPanel.Event = EventEnum.New()

function PveMainPanel:__Init()
	self:SetAsset("ui/prefab/battle/pve_main_panel.prefab")
end

function PveMainPanel:__ExtendView()
	self:ExtendView(BattleMixedView)
	self:ExtendView(BattleMixedEffectView)
	self:ExtendView(BattleDialogPanel)
	self.battleInfoView = self:ExtendView(BattlePveInfoView)
	self:ExtendView(BattlePveAwardView)
	self:ExtendView(BattlePveAttrView)
	self:ExtendView(BattlePveSelectItemView)
	self:ExtendView(BattlePveItemView)
	self:ExtendView(BattleDragRelSkillView)

    self:ExtendView(PveEnterPerformView)
	self:ExtendView(PveResultPerformView)
	self:ExtendView(PveMixedEffectView)
end

function PveMainPanel:__CacheObject()
    BattleDefine.uiObjs["template/entity_top/hero"] = self:Find("template/entity_top/hero").gameObject
	BattleDefine.uiObjs["template/entity_top/home"] = self:Find("template/entity_top/home").gameObject

	BattleDefine.uiObjs["entity_top"] = self:Find("main/entity_top")
	BattleDefine.uiObjs["fly_text"] = self:Find("main/fly_text")

	BattleDefine.uiObjs["mixed_effect"]  =self:Find("main/mixed_effect")
end

function PveMainPanel:__Create()
	ViewManager.Instance:Adaptive(self:Find("main/top_node",RectTransform),true,false)
end

function PveMainPanel:__BindListener()
end

function PveMainPanel:__BindEvent()
	-- self:BindEvent(BattleFacade.Event.ActiveLockScreen)
	self:BindEvent(BattleFacade.Event.ActiveMainPanel)
end

function PveMainPanel:__Show()
    
end

function PveMainPanel:__Hide()
    
end

function PveMainPanel:Update()
    self.battleInfoView:Update()
end

-- function PveMainPanel:ActiveLockScreen(flag)
	-- self.lockScreenNode:SetActive(flag)
	-- BattleDefine.nodeObjs["mixed/commander_collider"].gameObject:SetActive(not flag)
-- end

function PveMainPanel:ActiveMainPanel(flag)
	self:SetActive(self.transform,flag)
end
