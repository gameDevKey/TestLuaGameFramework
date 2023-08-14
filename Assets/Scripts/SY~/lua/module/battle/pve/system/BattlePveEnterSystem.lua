BattlePveEnterSystem = BaseClass("BattlePveEnterSystem",SECBSystem)
BattlePveEnterSystem.NAME = "BattleEnterSystem"
function BattlePveEnterSystem:__Init()
    -- self.assetLoaders = {}

    -- self.mapObject = nil
    -- self.skyBoxObject = nil

    --Common1 = 1 << 21, --通用Key
    --self.keyDownEvent | key
    --local a = 
end

function BattlePveEnterSystem:__Delete()
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

function BattlePveEnterSystem:EnterPK(data)
    --Log("进入Pk")

    self.world.BattleStateSystem:SetBattleState(BattleDefine.BattleState.enter)
    self.world.BattleDataSystem:InitData(data)

    -- self:CreateHome()

    if self.world.opts:IsClient() then
        ViewManager.Instance:OpenWindow(BattleLoadWindow)
        BattleDefine.openSelectTips = true
        AudioManager.Instance:PlayBgm("fight")
    else
        self:CreateHome()
        self.world:SetWorldState(BattleDefine.WorldState.running)
        self.world.BattleStateSystem:SetBattleState(BattleDefine.BattleState.battle)
    end

    --collectgarbage("stop")
end

function BattlePveEnterSystem:BeginBattle()
    Log("进入战斗")
    self:CreateRoleEntitys()
    self.world.BattlePlaceSystem:CleanPlaceInfos()
end

--进入完成
function BattlePveEnterSystem:EnterComplete()
    if not BattleDefine.mainPanel then
        BattleDefine.mainPanel = PveMainPanel.New()
        BattleDefine.mainPanel:SetParent(UIDefine.canvasRoot)
        local object = self.world.BattlePreLoadSystem.mainPanelObject
        BattleDefine.mainPanel:SetObject(object)
    end

    BattleDefine.mainPanel:Show()
    mod.BattleFacade:SendEvent(BattleFacade.Event.ActiveMainPanel,false)

    self:CreateHome()

    ViewManager.Instance:SetCheckMainui(false)
    mod.MainuiFacade:SendEvent(MainuiPanel.Event.ActiveMainui,false)
    mod.MainuiFacade:SendEvent(MainuiPanel.Event.ActiveTopInfo,false)
    mod.MainuiFacade:SendEvent(MainuiPanel.Event.ActiveBottomTab,false)
    ViewManager.Instance:CloseAllWindow()

    BattleDefine.rootNode:SetActive(true)

    mod.BattleFacade:SendEvent(BattleFacade.Event.PlayEnterPerform)

    self:InitSceneNodePos()
end

function BattlePveEnterSystem:InitSceneNodePos()
end

function BattlePveEnterSystem:InitRefresh()
    for iter in self.world.EntitySystem.entityList:Items() do
        local uid = iter.value
        local entity = self.world.EntitySystem:GetEntity(uid)
        if entity and entity.clientEntity.UIComponent and entity.clientEntity.UIComponent.entityTop then
            entity.clientEntity.UIComponent.entityTop:RefreshPos()
        end
    end
end


function BattlePveEnterSystem:CreateHome()
    local roleUid = self.world.BattleDataSystem.roleUid
    local homeInfo = self.world.BattleDataSystem:GetFakeHomeInfo()
    local commanderInfo = self.world.BattleDataSystem:GetCommanderInfo()

    local homeEntity = self.world.BattleEntityCreateSystem:CreateFakeHomeEntity(roleUid,homeInfo,commanderInfo,BattleDefine.Camp.defence)
    local commanderEntity = self.world.BattleEntityCreateSystem:CreateCommander(roleUid,commanderInfo,BattleDefine.Camp.defence)
    commanderEntity.CollistionComponent:SetRadius(homeEntity.CollistionComponent:GetRadius())
    commanderEntity.AIComponent:AddAI(1001)
    if commanderEntity.clientEntity and commanderEntity.clientEntity.ClientTransformComponent then
        commanderEntity.clientEntity.ClientTransformComponent.gameObject:SetActive(false)
    end
end