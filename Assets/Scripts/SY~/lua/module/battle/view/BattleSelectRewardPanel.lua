BattleSelectRewardPanel = BaseClass("BattleSelectRewardPanel",BaseView)

BattleSelectRewardPanel.Event = EventEnum.New(
)

local qualityTextColor =
{
    [BattleDefine.RewardQuality.blue] = "6fbcf2",
    [BattleDefine.RewardQuality.purple] = "aa6ff2",
    [BattleDefine.RewardQuality.orange] = "ff9b1e",
}

local qualityIndex1 =
{
    [BattleDefine.RewardQuality.blue] = UITex("battle_result/battle_result_16"),
    [BattleDefine.RewardQuality.purple] = UITex("battle_result/battle_result_17"),
    [BattleDefine.RewardQuality.orange] = UITex("battle_result/battle_result_18"),
}

local qualityIndex2 =
{
    [BattleDefine.RewardQuality.blue] = UITex("battle_result/battle_result_14"),
    [BattleDefine.RewardQuality.purple] = UITex("battle_result/battle_result_15"),
    [BattleDefine.RewardQuality.orange] = UITex("battle_result/battle_result_13"),
}

function BattleSelectRewardPanel:__Init()
	self:SetAsset("ui/prefab/battle/battle_select_reward_panel.prefab")
    self.selectIndex = 0
    self.selectTime = 0
    self.selectTimer = nil
end

function BattleSelectRewardPanel:__Delete()
    self:RemoveSelectTimer()
end

function BattleSelectRewardPanel:__ExtendView()

end

function BattleSelectRewardPanel:__CacheObject()
    self.rewardObjects = {}
    for i=1,3 do self:GetRewardObjects(i) end

    self.countdownText = self:Find("main/countdown",Text)
end

function BattleSelectRewardPanel:GetRewardObjects(index)
    local root = self:Find("main/reward_"..tostring(index))

    local objects = {}
    objects.btn = root.gameObject:GetComponent(Button)
    objects.selectNode = root:Find("select").gameObject
    objects.nameText = root:Find("name").gameObject:GetComponent(Text)
    objects.qualityIcon1 = root:Find("quality_1").gameObject:GetComponent(Image)
    objects.icon = root:Find("icon").gameObject:GetComponent(Image)
    objects.qualityIcon2 = root:Find("quality_2").gameObject:GetComponent(Image)
    objects.descText = root:Find("desc").gameObject:GetComponent(Text)
    objects.natureIcon = root:Find("nature_icon").gameObject:GetComponent(CircleImage)

    table.insert(self.rewardObjects,objects)
end

function BattleSelectRewardPanel:__BindListener()
    self:Find("main/confirm_btn",Button):SetClick( self:ToFunc("ConfirmClick") )

    for i,v in ipairs(self.rewardObjects) do
        v.btn:SetClick(self:ToFunc("RewardClick"),i)
    end
end

function BattleSelectRewardPanel:__Show()
    self:SetSelectReward(0)

    local roundResultData = RunWorld.BattleDataSystem.roundResultData
    for i,v in ipairs(roundResultData.choose_reward_list) do
        self:RefreshReward(i,v.reward_id)
    end

    local roundResultData = RunWorld.BattleDataSystem.roundResultData
    local remainTime = Network.Instance:GetRemoteRemainTime(roundResultData.show_end_time)

    self.selectTime = remainTime --remainTime > 10 and 10 or remainTime
    self.countdownText.text = remainTime.."s"
    self.selectTimer = TimerManager.Instance:AddTimer(self.selectTime,1,self:ToFunc("CallSelectTimer"))
end

function BattleSelectRewardPanel:__Hide()
    self.selectIndex = 0
    self:RemoveSelectTimer()
end


function BattleSelectRewardPanel:CallSelectTimer()
    self.selectTime = self.selectTime -1

    if self.selectTime <= 0 then
        self:RemoveSelectTimer()
        self:Hide()
    else
        self.countdownText.text = self.selectTime.."s"
    end
end

function BattleSelectRewardPanel:RemoveSelectTimer()
    if self.selectTimer then
        TimerManager.Instance:RemoveTimer(self.selectTimer)
        self.selectTimer = nil
    end
end

function BattleSelectRewardPanel:RefreshReward(index,rewardId)
    local conf = Config.QualifyingRewardData.data_reward_data[rewardId]
    local objects = self.rewardObjects[index]

    local color = qualityTextColor[conf.quality_type]
    objects.nameText.text =  string.format("<color='#%s'>%s</color>",color,conf.name)

    self:SetSprite(objects.qualityIcon1,qualityIndex1[conf.quality_type],true)

    local iconFile = AssetPath.GetBattleSelectRewardIcon(conf.reward_icon)
    self:SetSprite(objects.icon,iconFile,true)

    self:SetSprite(objects.qualityIcon2,qualityIndex2[conf.quality_type],true)

    objects.descText.text = conf.desc

    local iconFile = AssetPath.GetNatureIcon(conf.nature)
    self:SetSprite(objects.natureIcon,iconFile,true)
end

function BattleSelectRewardPanel:RewardClick(index)
    if self.selectIndex == index then
        return
    end

    self.selectIndex = index
    self:SetSelectReward(self.selectIndex)
end

function BattleSelectRewardPanel:SetSelectReward(index)
    for i,v in ipairs(self.rewardObjects) do
        v.selectNode:SetActive(index == i)
    end
end

function BattleSelectRewardPanel:ConfirmClick()
    if self.selectIndex == 0 then
        return
    end

    mod.BattleFacade:SendMsg(10312,self.selectIndex)
    self:Hide()
end