BattleStatisticsPanel = BaseClass("BattleStatisticsPanel",BaseView)

BattleStatisticsPanel.Event = EventEnum.New(
)

function BattleStatisticsPanel:__Init()
    self:SetAsset("ui/prefab/battle_result/battle_statistics_panel.prefab")
    self.heroOutputItems = {}
end

function BattleStatisticsPanel:__Delete()
    for i,v in ipairs(self.heroOutputItems) do
        v.heroItem:Destroy()
    end
end

function BattleStatisticsPanel:__ExtendView()

end

function BattleStatisticsPanel:__CacheObject()
    self.selfHeroItem = self:Find("main/content_node/self/unit_list/Viewport/Content/item")
    self.selfHeroParent = self:Find("main/content_node/self/unit_list/Viewport/Content")

    self.enemyHeroItem = self:Find("main/content_node/enemy/unit_list/Viewport/Content/item")
    self.enemyHeroParent = self:Find("main/content_node/enemy/unit_list/Viewport/Content")

    self.groupNum = self:Find("main/content_node/group_num",Text)

    self.selfRoleHead = self:Find("main/content_node/self/head",Image)
    self.selfName = self:Find("main/content_node/self/name",Text)
    self.selfOutputTotal = self:Find("main/content_node/self/output_total_num",Text)
    self.selfCommanderHead = self:Find("main/content_node/self_commander_head",Image)
    self.selfCommanderLev = self:Find("main/content_node/self/lev",Text)

    self.enemyRoleHead = self:Find("main/content_node/enemy/head",Image)
    self.enemyName = self:Find("main/content_node/enemy/name",Text)
    self.enemyOutputTotal = self:Find("main/content_node/enemy/output_total_num",Text)
    self.enemyCommanderHead = self:Find("main/content_node/enemy_commander_head",Image)
    self.enemyCommanderLev = self:Find("main/content_node/enemy/lev",Text)

    self.selfWinImg = self:Find("main/content_node/self/result_win").gameObject
    self.selfLoseImg = self:Find("main/content_node/self/result_lose").gameObject
    self.enemyWinImg = self:Find("main/content_node/enemy/result_win").gameObject
    self.enemyLoseImg = self:Find("main/content_node/enemy/result_lose").gameObject
end

function BattleStatisticsPanel:__BindListener()
    -- self:Find("bg",Button):SetClick(self:ToFunc("CloseClick"))
    -- self:Find("main/battle_info",Button):SetClick(self:ToFunc("BattleInfo"))
    -- self:Find("battleresultinfo/main/enter_btn",Button):SetClick(self:ToFunc("CloseInfo"))
    self:Find("main/close_btn",Button):SetClick(self:ToFunc("CloseStatisticsPanel"),self,true)
    --self:Find("battleresultinfo/main/enemy_head",Button):SetClick(self:ToFunc("OpenLeader"),self,false)
end

function BattleStatisticsPanel:__Create()
    self:SetBaseInfo()
    self:SetHeroInfo()
end

function BattleStatisticsPanel:__Hide()
    
end

function BattleStatisticsPanel:__Show()
    mod.BattleFacade:SendEvent(BattleResultWindow.Event.BattleStatisticsPanelActive,false)
end

function BattleStatisticsPanel:SetBaseInfo()
    local selfRoleData = RunWorld.BattleDataSystem:GetRoleData(RunWorld.BattleDataSystem.roleUid)
    local selfStatisticsInfo = RunWorld.BattleStatisticsSystem:GetInfo(selfRoleData.role_base.role_uid)
    local selfCommanderBaseInfo = RunWorld.BattleDataSystem:GetCampCommanderInfo(selfRoleData.role_base.role_uid)
    local selfCommanderInfo = RunWorld.BattleCommanderSystem:GetCommanderInfo(selfRoleData.role_base.role_uid)
    local selfCommanderUnitConf = Config.UnitData.data_unit_info[selfCommanderBaseInfo.unit_id]

    local enemyRoleData = RunWorld.BattleDataSystem:GetEnemyRoleData()
    local enemyStatisticsInfo = RunWorld.BattleStatisticsSystem:GetInfo(enemyRoleData.role_base.role_uid)
    local enemyCommanderBaseInfo = RunWorld.BattleDataSystem:GetCampCommanderInfo(enemyRoleData.role_base.role_uid)
    local enemyCommanderInfo = RunWorld.BattleCommanderSystem:GetCommanderInfo(enemyRoleData.role_base.role_uid)
    local enemyCommanderUnitConf = Config.UnitData.data_unit_info[enemyCommanderBaseInfo.unit_id]


    self.groupNum.text = "回合数: "..RunWorld.BattleGroupSystem.group.."轮"

    
    self:SetSprite(self.selfRoleHead,AssetPath.GetRoleHeadIcon(1,1), false)
    self.selfName.text = selfRoleData.role_base.name
    self.selfCommanderLev.text = "Lv."..selfCommanderBaseInfo.level
    self:SetSprite(self.selfCommanderHead,AssetPath.GetCommanderHoriRectIcon(selfCommanderUnitConf.head), true)

    local selfoutputMaxVal = selfStatisticsInfo.outputMaxVals[BattleDefine.OutputType.atk] or 0
    if selfoutputMaxVal == 0 then
        self.selfOutputTotal.text = "0"
    else
        self.selfOutputTotal.text = string.format("%.2fk",selfoutputMaxVal / 1000)
    end


    --
    self:SetSprite(self.enemyRoleHead,AssetPath.GetRoleHeadIcon(1,1), false)
    self.enemyName.text = enemyRoleData.role_base.name
    self.enemyOutputTotal.text = enemyStatisticsInfo.outputMaxVals[BattleDefine.OutputType.atk]
    self.enemyCommanderLev.text = "Lv."..enemyCommanderBaseInfo.level
    self:SetSprite(self.enemyCommanderHead,AssetPath.GetCommanderHoriRectIcon(enemyCommanderUnitConf.head), true)

    local enemyoutputMaxVal = enemyStatisticsInfo.outputMaxVals[BattleDefine.OutputType.atk] or 0
    if enemyoutputMaxVal == 0 then
        self.enemyOutputTotal.text = "0"
    else
        self.enemyOutputTotal.text = string.format("%.2fk",enemyoutputMaxVal / 1000)
    end

    local resultData = RunWorld.BattleResultSystem.resultData
    local roleData = RunWorld.BattleDataSystem:GetRoleData(RunWorld.BattleDataSystem.roleUid)
    local isWin = resultData.win_camp == roleData.camp

    self.selfWinImg:SetActive(isWin)
    self.selfLoseImg:SetActive(not isWin)
    self.enemyWinImg:SetActive(not isWin)
    self.enemyLoseImg:SetActive(isWin)
end

function BattleStatisticsPanel:SetHeroInfo()
    local selfRoleData = RunWorld.BattleDataSystem:GetRoleData(RunWorld.BattleDataSystem.roleUid)
    local selfStatisticsInfo = RunWorld.BattleStatisticsSystem:GetInfo(selfRoleData.role_base.role_uid)

    local enemyRoleData = RunWorld.BattleDataSystem:GetEnemyRoleData()
    local enemyStatisticsInfo = RunWorld.BattleStatisticsSystem:GetInfo(enemyRoleData.role_base.role_uid)

    RunWorld.BattleStatisticsSystem:SortOutputByTotal()

    local maxValues = {}
    maxValues[BattleDefine.OutputType.atk] = 0
    maxValues[BattleDefine.OutputType.heal] = 0
    maxValues[BattleDefine.OutputType.def] = 0
    for _,v in pairs(RunWorld.BattleStatisticsSystem.roleInfos) do
        for _,info in ipairs(v.outputInfoList) do
            if info.valueList[BattleDefine.OutputType.atk] 
                and info.valueList[BattleDefine.OutputType.atk].value > maxValues[BattleDefine.OutputType.atk] then
                maxValues[BattleDefine.OutputType.atk] = info.valueList[BattleDefine.OutputType.atk].value
            end

            if info.valueList[BattleDefine.OutputType.heal] 
                and info.valueList[BattleDefine.OutputType.heal].value > maxValues[BattleDefine.OutputType.heal] then
                maxValues[BattleDefine.OutputType.heal] = info.valueList[BattleDefine.OutputType.heal].value
            end

            if info.valueList[BattleDefine.OutputType.def] 
                and info.valueList[BattleDefine.OutputType.def].value > maxValues[BattleDefine.OutputType.def] then
                maxValues[BattleDefine.OutputType.def] = info.valueList[BattleDefine.OutputType.def].value
            end
        end
    end

    if selfStatisticsInfo then
        for i,v in ipairs(selfStatisticsInfo.outputInfoList) do
            self:CreateHeroItem(selfRoleData.role_base.role_uid,self.selfHeroItem,self.selfHeroParent,selfStatisticsInfo,v.unitId,maxValues)
        end
    end
    
    if enemyStatisticsInfo then
        for i,v in ipairs(enemyStatisticsInfo.outputInfoList) do
            self:CreateHeroItem(enemyRoleData.role_base.role_uid,self.enemyHeroItem,self.enemyHeroParent,enemyStatisticsInfo,v.unitId,maxValues)
        end
    end
end


function BattleStatisticsPanel:CreateHeroItem(roleUid,item,parent,statisticsInfo,unitId,maxValues)
    local unitBaseData = RunWorld.BattleDataSystem:GetBaseUnitData(roleUid,unitId)
    local star = RunWorld.BattleDataSystem:GetUnitStar(roleUid,unitId)

    local conf = Config.UnitData.data_unit_info[unitId]

    local unitOutputInfo = statisticsInfo.outputInfos[unitId]

    local heroOutputItem = GameObject.Instantiate(item)
    heroOutputItem.gameObject:SetActive(true)
    heroOutputItem.transform:SetParent(parent)
    heroOutputItem.transform:Reset()

    local heroItem = HeroItem.Create()
    heroItem:SetData(unitBaseData)
    heroItem:SetSize(96,96)
    -- heroItem:SetStar(RunWorld.BattleDataSystem:GetUnitStar(roleUid,unitId))
    heroItem:SetParent(heroOutputItem.transform:Find("head_node"))

    --local outputVal = unitOutputInfo.valueList[BattleDefine.OutputType.atk]

    --self:SetSprite(heroOutputItem.transform:Find("job"):GetComponent(Image),AssetPath.JobToIcon[conf.job])

    --heroOutputItem.transform:Find("star"):GetComponent(Text).text = star

    --
    local curAtkValue = unitOutputInfo.valueList[BattleDefine.OutputType.atk].value
    local showAtkValue = string.format("%.2fk",curAtkValue / 1000)

    local atkMaxVal = maxValues[BattleDefine.OutputType.atk] or 0
    local atkProgress = atkMaxVal > 0 and curAtkValue / atkMaxVal or 0

    heroOutputItem.transform:Find("atk_node/progress"):GetComponent(RectTransform):SetSizeDelata(182 * atkProgress,20)
    heroOutputItem.transform:Find("atk_node/val"):GetComponent(Text).text = showAtkValue


    --
    local curHealValue = unitOutputInfo.valueList[BattleDefine.OutputType.heal].value
    local showHealValue = string.format("%.2fk",curHealValue / 1000)

    local healMaxVal = maxValues[BattleDefine.OutputType.heal] or 0
    local healProgress = healMaxVal > 0 and curHealValue / healMaxVal or 0

    heroOutputItem.transform:Find("heal_node/progress"):GetComponent(RectTransform):SetSizeDelata(182 * healProgress,20)
    heroOutputItem.transform:Find("heal_node/val"):GetComponent(Text).text = showHealValue


    --
    local curDefValue = unitOutputInfo.valueList[BattleDefine.OutputType.def].value
    local showDefValue = string.format("%.2fk",curDefValue / 1000)

    local defMaxVal = maxValues[BattleDefine.OutputType.def] or 0
    local defProgress = defMaxVal > 0 and curDefValue / defMaxVal or 0

    heroOutputItem.transform:Find("def_node/progress"):GetComponent(RectTransform):SetSizeDelata(182 * defProgress,20)
    heroOutputItem.transform:Find("def_node/val"):GetComponent(Text).text = showDefValue
    
    local heroOutputItemInfo = {}
    heroOutputItemInfo.heroItem = heroItem
    table.insert(self.heroOutputItems,heroOutputItemInfo)
end

function BattleStatisticsPanel:CloseStatisticsPanel()
    mod.BattleFacade:SendEvent(BattleResultWindow.Event.BattleStatisticsPanelActive,true)
    self:Hide()
end

