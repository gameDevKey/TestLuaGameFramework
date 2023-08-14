PveEnterPanel = BaseClass("PveEnterPanel",BasePanel)
PveEnterPanel.Event = EventEnum.New(
    "RefreshChapterReward",
    "RefreshBaseInfo",
    "RefreshSweepCount"
)

function PveEnterPanel:__Init()
    self:SetViewType(UIDefine.ViewType.panel)
    self:SetAsset("ui/prefab/mainui/pve_enter_panel.prefab",AssetType.Prefab)

    self.chapterRewardItems = {}
    self.enemyInfoItems = {}
    self.rewardItems = {}
    self.sweepRewardItems = {}

    self.monsterConfs = {}
    self.monsterUnitIds = {}

    self.toDrawChapterRewardPveId = nil

    self.isPassedTopest = false
    self.isWithoutPassed = false


    self.awardRemindItem = nil
    self.sweepRemindItem = nil

    self.awardEffects = {}
end

function PveEnterPanel:__Delete()
    for i, v in ipairs(self.chapterRewardItems) do
        GameObject.Destroy(v.gameObject)
    end

    for i, v in ipairs(self.enemyInfoItems) do
        GameObject.Destroy(v.gameObject)
    end

    for i, v in ipairs(self.rewardItems) do
        v:Destroy()
    end

    for i, v in ipairs(self.sweepRewardItems) do
        v:Destroy()
    end
    if self.awardRemindItem then
        self.awardRemindItem:Destroy()
    end

    if self.sweepRemindItem then
        self.sweepRemindItem:Destroy()
    end
end

function PveEnterPanel:__ExtendView()
end

function PveEnterPanel:__CacheObject()
    self.baseInfoBg = self:Find("main/base_info/bg")
    self.pveNum = self:Find("main/base_info/num",Text)
    self.pveName = self:Find("main/base_info/name",Text)
    self.recommendPowerBg = self:Find("main/base_info/recommend_power")
    self.recommendPower = self:Find("main/base_info/recommend_power/num",Text)

    self.chapterRewardParent = self:Find("main/chapter_reward")
    self.chapterRewardTips = self:Find("main/chapter_reward/chapter_reward_tips",Text)

    self.enemyInfoParent = self:Find("main/enemy_info/scroll_view/viewport/content")
    self.enemyTemplete = self:Find("templete/enemy_info_item").gameObject

    self.rewardInfoParent = self:Find("main/reward_info")
    self.rewardTemplete = self:Find("templete/reward_info_item").gameObject

    self.sweepRewardInfoParent = self:Find("main/sweep_reward_info")
    self.propItemTemp = self:Find("templete/prop_item").gameObject

    self.consumeTips = self:Find("main/sweep_btn/consume").gameObject
    self.sweepConsumeNum = self:Find("main/sweep_btn/consume/num",Text)
    self.sweepConsumeIcon = self:Find("main/sweep_btn/consume/num/icon",Image)
    self.sweepCount = self:Find("main/sweep_btn/consume/count",Text)

    self.freeTips = self:Find("main/sweep_btn/free").gameObject

    self.sweepBtn = self:Find("main/sweep_btn",Button)
    self.pveBtn = self:Find("main/pve_btn",Button)
end

function PveEnterPanel:__Create()
    -- self.name = self.transform.name
    -- self:SetOrder()

    self:CloneChapterRewardItems()
    self:CloneEnemyInfoItems()
    self:CloneRewardItems()
    self:CloneSweepRewardItems()

    self:Find("main/base_info/recommend_power/text",Text).text = TI18N("推荐战力")
    self:Find("main/enemy_info/title",Text).text = TI18N("敌人信息")
    self:Find("main/reward_info/title",Text).text = TI18N("挑战奖励")
    self:Find("main/sweep_reward_info/title",Text).text = TI18N("扫荡奖励")
    self:Find("main/pve_btn/text",Text).text = TI18N("挑战")
    self:Find("main/tips_bg/tips",Text).text = TI18N("点击空白处关闭")

    self.freeTips.transform:Find("text").gameObject:GetComponent(Text).text = TI18N("免费扫荡")
    self.freeTips.transform:Find("free_tips").gameObject:GetComponent(Text).text = TI18N("每日首次扫荡免费")

    self.consumeTips.transform:Find("text").gameObject:GetComponent(Text).text = TI18N("扫荡")

    self.awardRemindItem = MarkRemindItem.New()
    self.awardRemindItem:SetParent(self:Find("main/chapter_reward/remind_node"))
    self.awardRemindItem:SetRemindId(RemindDefine.RemindId.pve_award)

    self.sweepRemindItem = MarkRemindItem.New()
    self.sweepRemindItem:SetParent(self:Find("main/sweep_btn/remind_node"))
    self.sweepRemindItem:SetRemindId(RemindDefine.RemindId.pve_sweep)
end

function PveEnterPanel:RemoveAwardEffect()
    for i,v in ipairs(self.awardEffects) do
        v:Delete()
    end
    self.awardEffects = {}
end

function PveEnterPanel:CloneChapterRewardItems()
    for i = 1, 3 do
        local object = {}
        local item = GameObject.Instantiate(self.rewardTemplete)
        object.gameObject = item
        object.transform = item.transform
        object.transform:SetParent(self.chapterRewardParent)
        object.transform:Reset()
        UnityUtils.SetLocalScale(object.transform,0.51,0.51,0.51)
        UnityUtils.SetAnchoredPosition(object.transform, (i-1) * 63 + 55, -14.5)
        object.gameObject:SetActive(false)

        object.bg = object.transform:Find("reward_bg").gameObject:GetComponent(Image)
        object.icon = object.transform:Find("reward_icon").gameObject:GetComponent(Image)
        object.num = object.transform:Find("num").gameObject:GetComponent(Text)
        object.numBg = object.transform:Find("num_bg")
        object.frame = object.transform:Find("frame").gameObject
        object.gotIcon = object.transform:Find("got_icon").gameObject
        object.effectTrans = object.transform:Find("effect_node")
        table.insert(self.chapterRewardItems, object)
    end
end

function PveEnterPanel:CloneEnemyInfoItems()
    for i = 1, 10 do
        local object = {}
        local item = GameObject.Instantiate(self.enemyTemplete)
        object.gameObject = item
        object.transform = item.transform
        object.transform:SetParent(self.enemyInfoParent)
        object.transform:Reset()
        UnityUtils.SetAnchoredPosition(object.transform, (i-1) * 122, 0)
        object.gameObject:SetActive(false)

        object.bg = object.transform:Find("bg").gameObject:GetComponent(Image)
        object.icon = object.transform:Find("icon").gameObject:GetComponent(Image)

        table.insert(self.enemyInfoItems, object)
    end
    self.enemyTemplete:SetActive(false)
end

function PveEnterPanel:CloneRewardItems()
    for i = 1, 4 do
        local propItem = PropItem.Create(self.propItemTemp)
        propItem:SetParent(self.rewardInfoParent,0,0)
        propItem.transform:Reset()
        propItem:SetSize(102,91)
        UnityUtils.SetAnchorMinAndMax(propItem.transform,0,0.5,0,0.5)
        UnityUtils.SetPivot(propItem.transform,0,0.5)
        UnityUtils.SetAnchoredPosition(propItem.transform, (i-1) * 122, -28)
        propItem:Show()
        table.insert(self.rewardItems,propItem)
    end
end

function PveEnterPanel:CloneSweepRewardItems()
    for i = 1, 4 do
        local propItem = PropItem.Create(self.propItemTemp)
        propItem:SetParent(self.sweepRewardInfoParent,0,0)
        propItem.transform:Reset()
        propItem:SetSize(102,91)
        UnityUtils.SetAnchorMinAndMax(propItem.transform,0,0.5,0,0.5)
        UnityUtils.SetPivot(propItem.transform,0,0.5)
        UnityUtils.SetAnchoredPosition(propItem.transform, (i-1) * 122, -28)
        propItem:Show()
        table.insert(self.sweepRewardItems,propItem)
    end
end

function PveEnterPanel:__BindEvent()
    self:BindEvent(PveEnterPanel.Event.RefreshChapterReward)
    self:BindEvent(PveEnterPanel.Event.RefreshBaseInfo)
    self:BindEvent(PveEnterPanel.Event.RefreshSweepCount)
end

function PveEnterPanel:__BindListener()
    self:Find("panel_bg",Button):SetClick(self:ToFunc("OnCloseClick"))

    self.sweepBtn:SetClick(self:ToFunc("EnterSweep"))
    self.pveBtn:SetClick(self:ToFunc("EnterPve"))

    self:Find("main/chapter_reward",Button):SetClick(self:ToFunc("DrawChapterReward"))
end

function PveEnterPanel:__Show()
    self:RefreshBaseInfo()
end

function PveEnterPanel:__Hide()
    self.toDrawChapterRewardPveId = nil
    for i, v in ipairs(self.chapterRewardItems) do
        v.gameObject:SetActive(false)
    end

    for i, v in ipairs(self.enemyInfoItems) do
        v.gameObject:SetActive(false)
    end
end

function PveEnterPanel:SetPveBaseInfo()
    local conf = Config.PveData.data_pve[self.pveProgress.pve_id + 1]
    self.isPassedTopest = false
    if not conf then
        conf = Config.PveData.data_pve[self.pveProgress.pve_id]
        self.isPassedTopest = true
    end

    self.conf = conf
    self.curConf = self.pveProgress.pve_id == 0 and Config.PveData.data_pve[1] or Config.PveData.data_pve[self.pveProgress.pve_id]
    self.pveNum.text = conf.number
    self.pveName.text = conf.name
    self.recommendPower.text = conf.recommend_power

   --TODO 设置自适应背景宽度
    local baseInfoBgWidth = self.pveNum.preferredWidth + math.abs(self.pveNum.transform.anchoredPosition.x) + 60
    UnityUtils.SetSizeDelata(self.baseInfoBg,baseInfoBgWidth,self.baseInfoBg.rect.height)

    local powerBgWidth = self.recommendPower.preferredWidth + math.abs(self.recommendPower.transform.anchoredPosition.x) + 20
    UnityUtils.SetSizeDelata(self.recommendPowerBg,powerBgWidth,self.recommendPowerBg.rect.height)
end

function PveEnterPanel:SetEnemyPreview()
    self.monsterUnitIds = self:GetMonsterUnitIds(self.conf.id)

    local i = 1
    for k, v in pairs(self.monsterUnitIds) do
        local item = self.enemyInfoItems[i]
        local conf = Config.UnitData.data_unit_info[v.unitId]
        local path = AssetPath.GetUnitIconHeadObliqueSquare(conf.head)
        self:SetSprite(item.icon,path)
        self:SetSprite(item.bg, AssetPath.QualityToUnitDetailsIconBg[conf.quality])
        item.gameObject:SetActive(true)
        i = i + 1
    end
    local width = (i-1) * 122 -3
    local height = self.enemyInfoParent.rect.height
    self.enemyInfoParent:SetSizeDelata(width,height)
    for j = i, 5 do
        self.enemyInfoItems[j].gameObject:SetActive(false)
    end
end

function PveEnterPanel:GetMonsterUnitIds(pveId)
    local index = 1
    local key = pveId.."_"..index
    local pveGroupConf = Config.PveData.data_pve_group[key]
    local monsterGroupIds = {}
    local monsterUnitIds = {}

    while pveGroupConf do
        for i, v in ipairs(pveGroupConf.gen_rules) do
            local monsterGroupId = v[1]
            if not monsterGroupIds[monsterGroupId] then
                monsterGroupIds[monsterGroupId] = self:GetPveMonsterGroup(monsterGroupId)
            end
        end

        index = index + 1
        key = pveId.."_"..index
        pveGroupConf = Config.PveData.data_pve_group[key]
    end

    for _, monsterGroup in pairs(monsterGroupIds) do
        for unitId, unitConf in pairs(monsterGroup) do
            if not monsterUnitIds[unitId] then
                monsterUnitIds[unitId] = unitConf
            end
        end
    end

    return monsterUnitIds
end

function PveEnterPanel:GetPveMonsterGroup(monsterGroupId)
    if self.monsterConfs[monsterGroupId] then
        return self.monsterConfs[monsterGroupId]
    end
    local list = {}
    for _, conf in pairs(Config.PveData.data_pve_monster) do
        if conf.id == monsterGroupId then
            local monster = {}
            monster.unitId = conf.unit_id
            monster.attrList = conf.attr_list
            list[monster.unitId] = monster
        end
    end
    self.monsterConfs[monsterGroupId] = list

    return list
end

function PveEnterPanel:SetFirstRewardPreview()
    local k = 1
    for i, v in ipairs(self.conf.first_reward_preview) do
        local rewardData = {}
        rewardData.item_id = v[1]
        rewardData.count = v[2]
        self.rewardItems[i]:SetData(rewardData)
        self.rewardItems[i]:Show()
        k = i
    end

    for i = k+1, 4 do
        self.rewardItems[i]:Hide()
    end
end

function PveEnterPanel:SetBtnState()
    self.pveBtn.gameObject:SetActive( not self.isPassedTopest )
    self.sweepBtn.gameObject:SetActive( not self.isWithoutPassed )
    if self.isPassedTopest then
        UnityUtils.SetAnchoredPosition(self.sweepBtn.transform,0,-375.5)
    elseif self.isWithoutPassed then
        UnityUtils.SetAnchoredPosition(self.pveBtn.transform,0,-375.5)
    else
        UnityUtils.SetAnchoredPosition(self.pveBtn.transform,130,-375.5)
        UnityUtils.SetAnchoredPosition(self.sweepBtn.transform,-132,-375.5)
    end
end

function PveEnterPanel:SetChapterRewardInfo()
    self:RemoveAwardEffect()

    local nextChapterRewardPveId,nextChapterRewardPveConf = mod.BattlePveProxy:GetNextChapterRewardInfo(self.pveProgress.chapter_reward_top_pve_id)
    if not nextChapterRewardPveId or not nextChapterRewardPveConf then
        self.chapterRewardTips.text = TI18N("已领取完所有奖励")
        local chapterRewardPveConf = Config.PveData.data_pve[self.pveProgress.chapter_reward_top_pve_id].chapter_reward
        local count = 1
        for i, v in ipairs(chapterRewardPveConf) do
            local item = self.chapterRewardItems[i]
            local rewardConf = Config.ItemData.data_item_info[v[1]]
            local path = AssetPath.GetItemIcon(rewardConf.icon)
            self:SetSprite(item.icon,path,true)
            self:SetSprite(item.bg, AssetPath.QualityToUnitDetailsIconBg[rewardConf.quality])

            local numText = ""
            if v[2] ~= 0 then
                numText = "x" .. tostring(v[2])
            end
            item.num.text = numText
            item.numBg.gameObject:SetActive(v[2]~=0)
            local height = item.numBg.rect.height
            UnityUtils.SetSizeDelata(item.numBg, item.num.preferredWidth+10, height)
            item.gotIcon:SetActive(true)
            item.frame:SetActive( false )
            item.gameObject:SetActive(true)
            count = i
        end
        for i = count+1, 3 do
            self.chapterRewardItems[i].gameObject:SetActive(false)
        end
        return
    end

    local diff = nextChapterRewardPveId - self.pveProgress.pve_id
    if diff > 0 then
        self.chapterRewardTips.text = TI18N(string.format("再通过%s关可领取",UIUtils.GetColorText(diff,"#ffc984")))
    else
        self.chapterRewardTips.text = TI18N("可领取")
        self.toDrawChapterRewardPveId = nextChapterRewardPveId
    end

    local count = 1
    for i, v in ipairs(nextChapterRewardPveConf) do
        local item = self.chapterRewardItems[i]
        local rewardConf = Config.ItemData.data_item_info[v[1]]
        local path = AssetPath.GetItemIcon(rewardConf.icon)
        self:SetSprite(item.icon,path,true)
        item.num.text = "x"..v[2]
        local height = item.numBg.rect.height
        UnityUtils.SetSizeDelata(item.numBg,item.num.preferredWidth,height)
        item.gameObject:SetActive(true)
        item.frame:SetActive( diff <= 0 )
        count = i

        if diff <= 0 then
            local effectSetting = {}
            effectSetting.confId = 10024
            effectSetting.order = self:GetOrder() + 1
            effectSetting.parent = item.effectTrans

            local awardEffect = UIEffect.New()
            awardEffect:Init(effectSetting)
            awardEffect:Play()

            table.insert(self.awardEffects,awardEffect)
        end
    end

    for i = count+1, 3 do
        self.chapterRewardItems[i].gameObject:SetActive(false)
    end
end

function PveEnterPanel:EnterPve()
    mod.BattleFacade:SendMsg(10900)
end

function PveEnterPanel:EnterSweep()
    -- self.sweepPanel:OnActive()
    local sweepCount = self.maxCount - self.pveProgress.sweep_count
    if sweepCount <= 0 then
        SystemMessage.Show(TI18N("今日扫荡已达次数上限"))
        return
    end

    if sweepCount ~= 0 then
        if self.consumeConf and not TableUtils.IsEmpty(self.consumeConf.consume) then
            LogTable("self.consumeConf",self.consumeConf)
            local costItemId = self.consumeConf.consume[1][1]
            local costItemNum = self.consumeConf.consume[1][2]
            local flag = mod.JumpCtrl:CheckItemNumJumpWay(costItemId,costItemNum)
            if flag then
                return
            else
                mod.BattleFacade:SendMsg(10902)
            end
        else
            mod.BattleFacade:SendMsg(10902)
        end
    end
end

function PveEnterPanel:DrawChapterReward()
    if self.toDrawChapterRewardPveId then
        mod.BattleFacade:SendMsg(10903,self.toDrawChapterRewardPveId)
        self.toDrawChapterRewardPveId = nil
    else
        SystemMessage.Show(self.chapterRewardTips.text)
    end
end

function PveEnterPanel:RefreshChapterReward()
    self:SetChapterRewardInfo()
end

function PveEnterPanel:RefreshBaseInfo()
    self.pveProgress = mod.BattlePveProxy.pveProgress
    self.isWithoutPassed = self.pveProgress.pve_id == 0 and true or false
    self:SetPveBaseInfo()
    self:SetEnemyPreview()
    self:SetFirstRewardPreview()
    self:SetBtnState()
    self:SetChapterRewardInfo()
    self:SetSweepData()
end

function PveEnterPanel:RefreshSweepCount()
    self:SetSweepData()
end

function PveEnterPanel:SetSweepData()
    local consumeGroup = self.curConf.sweep_consume_group
    local maxCount = Config.PveData.data_pve_sweep_max_count[consumeGroup]
    local sweepCount = maxCount - self.pveProgress.sweep_count
    local color = sweepCount == 0 and "#ff8080" or "#ffffff"
    self.sweepCount.text = string.format("(%s/%s)",UIUtils.GetColorText(sweepCount,color),maxCount)

    local consumeKey = consumeGroup.."_"..tostring(self.pveProgress.sweep_count+1)
    self.consumeConf = Config.PveData.data_pve_sweep_consume[consumeKey]
    if not self.consumeConf then
        self.consumeConf = Config.PveData.data_pve_sweep_consume[consumeGroup.."_"..tostring(self.pveProgress.sweep_count)]
    end

    self.sweepReward = self.consumeConf.reward
    self.maxCount = Config.PveData.data_pve_sweep_max_count[consumeGroup]

    self:SetSweepReward()
    self:SetConsume()
end

function PveEnterPanel:SetSweepReward()
    local k = 1
    for i, v in ipairs(self.sweepReward) do
        local rewardData = {}
        rewardData.item_id = v[1]
        rewardData.count = v[2]
        self.sweepRewardItems[i]:SetData(rewardData)
        self.rewardItems[i]:Show()
        k = i
    end
    for i = k+1, 4 do
        self.sweepRewardItems[i]:Hide()
    end
end

function PveEnterPanel:SetConsume()
    self.freeTips:SetActive(false)
    self.consumeTips:SetActive(true)

    local consume = self.consumeConf.consume
    if TableUtils.IsEmpty(consume) then
        self.freeTips:SetActive(true)
        self.consumeTips:SetActive(false)
        return
    end
    
    local costItemId = consume[1][1]
    local costItemNum = consume[1][2]
    local itemNum = mod.RoleItemProxy:GetItemNum(costItemId)
    local color = "#798491"
    if itemNum < costItemNum then
        color = "#ff8080"
    end
    self:SetSprite(self.sweepConsumeIcon,AssetPath.GetCurrencyIconByItemId(costItemId))
    self.sweepConsumeNum.text = string.format("(%s/%s)",UIUtils.GetColorText(itemNum,color),costItemNum)
    UnityUtils.SetSizeDelata(self.sweepConsumeNum.transform,self.sweepConsumeNum.preferredWidth,self.sweepConsumeNum.transform.rect.height)
end

function PveEnterPanel:OnCloseClick()
    self:Hide()
end