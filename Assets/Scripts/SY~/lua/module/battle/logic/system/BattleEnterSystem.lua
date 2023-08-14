BattleEnterSystem = BaseClass("BattleEnterSystem",SECBSystem)

function BattleEnterSystem:__Init()
    -- self.assetLoaders = {}

    -- self.mapObject = nil
    -- self.skyBoxObject = nil

    --Common1 = 1 << 21, --通用Key
    --self.keyDownEvent | key
    --local a = 
end

function BattleEnterSystem:__Delete()
    -- self:RemoveLoaders()
    --SceneManagement.SceneManager.LoadScene("Jumper")

    -- if self.mapObject then
    --     GameObject.Destroy(self.mapObject)
    --     self.mapObject = nil
    -- end

    -- if self.skyBoxObject then
    --     GameObject.Destroy(self.skyBoxObject)
    --     self.skyBoxObject = nil
    -- end
end

function BattleEnterSystem:EnterPK(data)
    --Log("进入Pk")

    self.world.BattleStateSystem:SetBattleState(BattleDefine.BattleState.enter)
    self.world.BattleDataSystem:InitData(data)

    -- self:CreateHomes()

    if self.world.opts:IsClient() then
        ViewManager.Instance:OpenWindow(BattleLoadWindow)
        BattleDefine.openSelectTips = true
        AudioManager.Instance:PlayBgm("fight")
    else
        self:CreateHomes()
        self.world:SetWorldState(BattleDefine.WorldState.running)
        self.world.BattleStateSystem:SetBattleState(BattleDefine.BattleState.battle)
    end

    --collectgarbage("stop")
end

function BattleEnterSystem:BeginBattle()
    Log("进入战斗")
    self:CreateRoleEntitys()
    self.world.BattlePlaceSystem:CleanPlaceInfos()
end

--进入完成
function BattleEnterSystem:EnterComplete()
    if not BattleDefine.mainPanel then
        BattleDefine.mainPanel = BattleMainPanel.New()
        BattleDefine.mainPanel:SetParent(UIDefine.canvasRoot)
        local object = self.world.BattlePreLoadSystem.mainPanelObject
        BattleDefine.mainPanel:SetObject(object)
    end

    BattleDefine.mainPanel:Show()
    mod.BattleFacade:SendEvent(BattleFacade.Event.ActiveMainPanel,false)

    self:CreateHomes()

    ViewManager.Instance:SetCheckMainui(false)
    mod.MainuiFacade:SendEvent(MainuiPanel.Event.ActiveMainui,false)
    mod.MainuiFacade:SendEvent(MainuiPanel.Event.ActiveTopInfo,false)
    mod.MainuiFacade:SendEvent(MainuiPanel.Event.ActiveBottomTab,false)
    ViewManager.Instance:CloseAllWindow()

    BattleDefine.rootNode:SetActive(true)

    mod.BattleFacade:SendEvent(BattleFacade.Event.PlayEnterPerform)
    

    self:InitSceneNodePos()
end

function BattleEnterSystem:InitSceneNodePos()
end

function BattleEnterSystem:InitRefresh()
    for iter in self.world.EntitySystem.entityList:Items() do
        local uid = iter.value
        local entity = self.world.EntitySystem:GetEntity(uid)
        if entity and entity.clientEntity.UIComponent and entity.clientEntity.UIComponent.entityTop then
            entity.clientEntity.UIComponent.entityTop:RefreshPos()
        end
    end
end


function BattleEnterSystem:CreateHomes()
    local attackRoleUid = self.world.BattleDataSystem:GetRoleUidByIndex(BattleDefine.Camp.attack,1)
    local attackHomeInfo = self.world.BattleDataSystem:GetCampHomeInfo(attackRoleUid)
    local attackHomeEntity = self.world.BattleEntityCreateSystem:CreateHomeEntity(attackRoleUid,attackHomeInfo,BattleDefine.Camp.attack)

    local attackCommanderInfo = self.world.BattleDataSystem:GetCampCommanderInfo(attackRoleUid)
    local attackCommanderEntity = self.world.BattleEntityCreateSystem:CreateCommander(attackRoleUid,attackCommanderInfo,BattleDefine.Camp.attack)
    attackCommanderEntity.CollistionComponent:SetRadius(attackHomeEntity.CollistionComponent:GetRadius())
    attackCommanderEntity.AIComponent:AddAI(1001)
    if attackCommanderEntity.clientEntity and attackCommanderEntity.clientEntity.ClientTransformComponent then
        attackCommanderEntity.clientEntity.ClientTransformComponent.gameObject:SetActive(false)
    end

    local attackMagicCards = self.world.BattleDataSystem:GetMagicCards(attackRoleUid)
    for i,v in ipairs(attackMagicCards) do
        self.world.BattleEntityCreateSystem:CreateMagicCard(attackRoleUid,v,BattleDefine.Camp.attack)
    end

    self.world.BattleHaloSystem:InitCommanderHalo(attackRoleUid,BattleDefine.Camp.attack,attackCommanderInfo.unit_id)
    --
    local defenceRoleUid = self.world.BattleDataSystem:GetRoleUidByIndex(BattleDefine.Camp.defence,1)
    local defenceHomeInfo = self.world.BattleDataSystem:GetCampHomeInfo(defenceRoleUid)
    local defenceHomeEntity = self.world.BattleEntityCreateSystem:CreateHomeEntity(defenceRoleUid,defenceHomeInfo,BattleDefine.Camp.defence)

    local defenceCommanderInfo = self.world.BattleDataSystem:GetCampCommanderInfo(defenceRoleUid)
    local defenceCommanderEntity = self.world.BattleEntityCreateSystem:CreateCommander(defenceRoleUid,defenceCommanderInfo,BattleDefine.Camp.defence)
    defenceCommanderEntity.CollistionComponent:SetRadius(defenceHomeEntity.CollistionComponent:GetRadius())
    defenceCommanderEntity.AIComponent:AddAI(1001)
    if defenceCommanderEntity.clientEntity and defenceCommanderEntity.clientEntity.ClientTransformComponent then
        defenceCommanderEntity.clientEntity.ClientTransformComponent.gameObject:SetActive(false)
    end

    local defenceMagicCards = self.world.BattleDataSystem:GetMagicCards(defenceRoleUid)
    for i,v in ipairs(defenceMagicCards) do
        self.world.BattleEntityCreateSystem:CreateMagicCard(defenceRoleUid,v,BattleDefine.Camp.defence)
    end

    self.world.BattleHaloSystem:InitCommanderHalo(defenceRoleUid,BattleDefine.Camp.defence,defenceCommanderInfo.unit_id)
end