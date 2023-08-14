BattleMixedView = BaseClass("BattleMixedView",ExtendView)

BattleMixedView.Event = EventEnum.New(
    "SetCommanderColliderClick"
)

function BattleMixedView:__Init()
    self.OnCommanderPlaceSlotDown = self:ToFunc("CommanderPlaceSlotDown")
    self.battleCommanderDetailsPanel = nil
end

function BattleMixedView:__Delete()
    if self.battleCommanderDetailsPanel then
        self.battleCommanderDetailsPanel:Destroy()
    end
end

function BattleMixedView:__CacheObject()

end

function BattleMixedView:__BindEvent()
    self:BindEvent(BattleMixedView.Event.SetCommanderColliderClick)
end

function BattleMixedView:__Hide()

end

function BattleMixedView:SetCommanderColliderClick()
    local enemyRoleData = RunWorld.BattleDataSystem:GetEnemyRoleData()
    self:CreateCommanderPlaceSlot(1,RunWorld.BattleDataSystem.roleUid)
    self:CreateCommanderPlaceSlot(-1,enemyRoleData.role_base.role_uid)
end

function BattleMixedView:CreateCommanderPlaceSlot(index,roleUid)
    local colliderNode = BattleDefine.nodeObjs["mixed/commander_collider"]:Find(tostring(index))
    local pointerHandler = colliderNode.gameObject:GetComponent(PointerHandler) or colliderNode.gameObject:AddComponent(PointerHandler)
    pointerHandler:SetOwner(self,"OnCommanderPlaceSlotDown","","")
    pointerHandler.isPointerDown = true
    pointerHandler.args = {roleUid = roleUid}
end

function BattleMixedView:CommanderPlaceSlotDown(pointerData,args)
    self:ShowCommanderDetails(args.roleUid)
end

function BattleMixedView:ShowCommanderDetails(roleUid)
    if self.battleCommanderDetailsPanel == nil then
        self.battleCommanderDetailsPanel = BattleHeroDetailsPanel.New()
        self.battleCommanderDetailsPanel:SetParent(UIDefine.canvasRoot)
    end
    local confData = RunWorld.BattleDataSystem:GetCampCommanderInfo(roleUid)
    local battleData = RunWorld.BattleCommanderSystem:GetCommanderInfo(roleUid)
    self.battleCommanderDetailsPanel:SetData(confData, battleData)
    self.battleCommanderDetailsPanel:Show()
end