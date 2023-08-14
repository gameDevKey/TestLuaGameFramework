BattleResultWindow = BaseClass("BattleResultWindow",BaseWindow)

BattleResultWindow.Event = EventEnum.New(
    "BattleStatisticsPanelActive"
)

function BattleResultWindow:__Init()
	self:SetAsset("ui/prefab/battle_result/battle_result_window.prefab")

    self.heros = {}
    self.selfItems = {}

    self.statisticsPanel = nil
end

function BattleResultWindow:__Delete()
end

function BattleResultWindow:__ExtendView()
    self.winPanel = self:ExtendView(WinExtraRewardPanel)
    self.losePanel = self:ExtendView(LoseExemptPunPanel)
end

function BattleResultWindow:__CacheObject()
    self.bgBtn = self:Find("bg",Button)
    self.closeTips = self:Find("main/close_tips",Text)

    self:CachePlayerMsg()

    self.winTitle = self:Find("bg/win_title").gameObject
    self.loseTitle = self:Find("bg/lose_title").gameObject

    -- self.enemyCardGroup = self:Find("main/player_msg_1/card_group/heros")
    -- self.selfCardGroup = self:Find("main/player_msg_2/card_group/heros")

    self.emptyItem = self:Find("main/template/empty_item").gameObject

    self.mainCanvas = self:Find("main",Canvas)
end

function BattleResultWindow:CachePlayerMsg()
    self.enemyPlayerMsg = self:GetPlayerMsgObject(1)
    self.selfPlayerMsg = self:GetPlayerMsgObject(2)
end

function BattleResultWindow:GetPlayerMsgObject(index)
    local info = {}
    info.transform = self:Find("main/player_msg_"..index)
    info.gameObject = info.transform.gameObject

    info.headIcon = info.transform:Find("head").gameObject:GetComponent(Image)
    info.straightWinsNode = info.transform:Find("head/straight_wins").gameObject
    info.straightWinsText = info.transform:Find("head/straight_wins/text").gameObject:GetComponent(Text)
    info.playerName = info.transform:Find("player_name").gameObject:GetComponent(Text)
    info.trophyNum = info.transform:Find("trophy_num").gameObject:GetComponent(Text)
    info.divisionIcon = info.transform:Find("division_icon").gameObject:GetComponent(Image)

    return info
end

function BattleResultWindow:__Create()
    self.closeTips.text = TI18N("点击空白处关闭")
end

function BattleResultWindow:__BindListener()
    self.bgBtn:SetClick(self:ToFunc("CloseClick"))
    self:Find("main/statistics_info_btn",Button):SetClick(self:ToFunc("OpenStatisticsInfo"))

    
    self:AddAnimEffectListener("battle_result_window_win_extra",self:ToFunc("OnAnimEffectPlay"))
    self:AddAnimEffectListener("battle_result_window_win_base",self:ToFunc("OnAnimEffectPlay"))
end

function BattleResultWindow:__BindEvent()
    self:BindEvent(BattleResultWindow.Event.BattleStatisticsPanelActive)
end

function BattleResultWindow:__Hide()
    if self.statisticsPanel then
        self.statisticsPanel:Destroy()
        self.statisticsPanel = nil
    end
    self.winPanel:OnInactive()
    self.losePanel:OnInactive()
end

function BattleResultWindow:__Show()
    local resultData = RunWorld.BattleResultSystem.resultData
    local roleData = RunWorld.BattleDataSystem:GetRoleData(RunWorld.BattleDataSystem.roleUid)
    local isWin = resultData.win_camp == roleData.camp

    if isWin then
        self.winTitle:SetActive(true)
        self.loseTitle:SetActive(false)
    else
        self.winTitle:SetActive(false)
        self.loseTitle:SetActive(true)
    end
    -- self:SetCardGroup()
    self:SetPlayerInfo(isWin)

    -- if next(mod.BackpackProxy.newUnlockUnits)~=nil then
    --     ViewManager.Instance:OpenWindow(ObtainedNewUnitWindow,{newUnlockUnits = mod.BackpackProxy.newUnlockUnits})
    -- end

    self.mainCanvas.sortingOrder = self:GetOrder() + GDefine.EffectOrderAdd + 3
end

function BattleResultWindow:ClearHeroItems()
    self:TablePushPool("heros")
end

--[[
function BattleResultWindow:SetCardGroup()
    local roleList = mod.BattleProxy.readyEnterData.role_list
    local groups = {}
    groups[BattleDefine.Camp.attack] = nil
    groups[BattleDefine.Camp.defence] = nil
    for i, v in ipairs(roleList) do
        groups[v.camp] = v.unit_list
    end

    local maxItemNum = Config.ConstData.data_const_info["card_group_unit_count"].val

    local selfCamp = BattleDefine.Camp.attack
    local enemyCamp = BattleDefine.Camp.defence
    if not RunWorld.BattleMixedSystem:IsSelfCamp(selfCamp) then
        selfCamp = BattleDefine.Camp.defence
        enemyCamp = BattleDefine.Camp.attack
    end

    for i, v in ipairs(groups[selfCamp]) do
        local unitConf = Config.UnitData.data_unit_info[v.unit_id]
        local hero = HeroItem.Create()
        hero:SetData(v)
        hero:SetSize(65,65)
        hero:ActiveStar(false)
        hero:SetParent(self.selfCardGroup)
        table.insert(self.heros, hero)
    end

    for i=#groups[selfCamp] + 1,maxItemNum do 
        local emptyItem = GameObject.Instantiate(self.emptyItem)
        emptyItem.transform:SetParent(self.selfCardGroup)
        emptyItem.transform:Reset()
    end

    for i, v in ipairs(groups[enemyCamp]) do
        local unitConf = Config.UnitData.data_unit_info[v.unit_id]
        local hero = HeroItem.Create()
        hero:SetData(v)
        hero:SetSize(65,65)
        hero:ActiveStar(false)
        hero:SetParent(self.enemyCardGroup)
        table.insert(self.heros, hero)
    end
    for i=#groups[enemyCamp] + 1,maxItemNum do 
        local emptyItem = GameObject.Instantiate(self.emptyItem)
        emptyItem.transform:SetParent(self.enemyCardGroup)
        emptyItem.transform:Reset()
    end
end
--]]

function BattleResultWindow:SetPlayerInfo(isWin)
    local resultData = RunWorld.BattleResultSystem.resultData
    local roleUid = RunWorld.BattleDataSystem.roleUid

    local selfRoleData = nil
    local enemyRoleData = nil
    for k, v in pairs(resultData.end_roles) do
        if roleUid == v.role_base.role_uid then
            selfRoleData = v
        else
            enemyRoleData = v
        end
    end

    self:SetPlayerMsg(self.selfPlayerMsg,selfRoleData)
    self:SetPlayerMsg(self.enemyPlayerMsg,enemyRoleData)

    local trophyNum = selfRoleData.after_trophy - selfRoleData.before_trophy
    local itemList = {}
    table.insert(itemList,{item_id = GDefine.ItemId.Trophy, count = trophyNum})
    for i, v in ipairs(resultData.item_list) do
        table.insert(itemList,{item_id = v.item_id, count = v.count})
    end

    table.sort(itemList, function (a,b)
        return a.item_id > b.item_id
    end)
    ---

    local pvpId = RunWorld.BattleDataSystem.pvpConf.id
    if isWin then
        local division = selfRoleData.after_division
        self.winPanel:SetData(itemList,pvpId,division,trophyNum)
        self.winPanel:OnActive()
    else
        self.losePanel:SetData(trophyNum,pvpId)
        self.losePanel:OnActive()
    end
end

function BattleResultWindow:SetPlayerMsg(playerMsg,data)
    -- self:SetSprite(playerMsg.playerName,"")  --设置头像
    --TODO 设置连胜节点
    playerMsg.straightWinsNode:SetActive(false)
    -- playerMsg.straightWinsText.text = TI18N(string.format("%s连胜",data.xxx))
    playerMsg.playerName.text = data.role_base.name
    playerMsg.trophyNum.text = data.role_base.trophy
    local divisionConf = Config.DivisionData.data_division_info[data.after_division]
    self:SetSprite(playerMsg.divisionIcon,AssetPath.GetDivisionIconPath(divisionConf.icon),true) --设置段位图标
end

function BattleResultWindow:CloseClick()
    if RunWorld then
        mod.BattleCtrl:ExitBattle(RunWorld)
    end
    self:ClearHeroItems()
    self.heros = {}
end

function BattleResultWindow:OpenStatisticsInfo()
    if not self.statisticsPanel then
        self.statisticsPanel = BattleStatisticsPanel.New()
        self.statisticsPanel:SetParent(self.transform)
    end
    self.statisticsPanel:Show()
end

function BattleResultWindow:OnAnimEffectPlay(animName,data)
    self:LoadUIEffectByAnimData(data,true)
end

function BattleResultWindow:OpenLeader(_,flag)
    local roleUid = nil
    if self.battleCommanderDetailsPanel == nil then
        self.battleCommanderDetailsPanel = BattleCommanderDetailsPanel.New()
        self.battleCommanderDetailsPanel:SetParent(UIDefine.canvasRoot)
    end
    local resultData = RunWorld.BattleResultSystem.resultData
    for k, v in pairs(resultData.end_roles) do
        if self.roleData.role_base.name == v.role_base.name then
            self.SelfUnid = v.role_base.role_uid
        else
            self.enemyUnid = v.role_base.role_uid
        end
    end
    if flag then
        roleUid = self.SelfUnid
    else
        roleUid = self.enemyUnid
    end
    local confData = RunWorld.BattleDataSystem:GetCampCommanderInfo(roleUid)
    local battleData = RunWorld.BattleCommanderSystem:GetCommanderInfo(roleUid)
    self.battleCommanderDetailsPanel:SetData(confData, battleData)
    self.battleCommanderDetailsPanel:Show()
end  

function BattleResultWindow:OpenRole(_,dataItem)
    local resultData = RunWorld.BattleResultSystem.resultData
    for k, v in pairs(resultData.end_roles) do
        if self.enemyRoleData.role_base.name == v.role_base.name then
            self.enemyRoleUid = v.role_base.role_uid
        end
    end
    self.battleUnitDetailsPanel = BattleUnitDetailsPanel.New()
    self.battleUnitDetailsPanel:SetParent(UIDefine.canvasRoot)
    local data = RunWorld.BattleDataSystem:GetBaseUnitData(self.enemyRoleUid,dataItem.heroId)
    data.star = RunWorld.BattleDataSystem:GetHeroStarByUnitId(self.enemyRoleUid,dataItem.heroId)
    self.battleUnitDetailsPanel:SetData(data)
    self.battleUnitDetailsPanel:Show()
end 

function BattleResultWindow:BattleStatisticsPanelActive(flag)
    self:ActiveSelf(flag)
end

function BattleResultWindow:ActiveSelf(flag)
    self.bgBtn.gameObject:SetActive(flag)
    self.mainCanvas.gameObject:SetActive(flag)
end

function BattleResultWindow:ActivePanelBgBtn(flag)
    self.bgBtn.interactable = flag
    self.closeTips.gameObject:SetActive(flag)
end