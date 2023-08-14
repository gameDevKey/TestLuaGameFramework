TreasureChestUpWindow = BaseClass("TreasureChestUpWindow", BaseWindow)
TreasureChestUpWindow.__topInfo = true
TreasureChestUpWindow.__bottomTab = true
TreasureChestUpWindow.__adaptive = true
TreasureChestUpWindow.notTempHide = true

TreasureChestUpWindow.Event = EventEnum.New(
    "RefreshTreasureChestInfo"
)

function TreasureChestUpWindow:__Init()
    self:SetAsset("ui/prefab/commander/treasure_chest_up_window.prefab", AssetType.Prefab)

    self.checkIntensifyRemind = nil
    self.checkUpLevRemind = nil
end

function TreasureChestUpWindow:__Delete()
    if self.checkIntensifyRemind then
        self.checkIntensifyRemind:Destroy()
        self.checkIntensifyRemind = nil
    end

    if self.checkUpLevRemind then
        self.checkUpLevRemind:Destroy()
        self.checkUpLevRemind = nil
    end
end

function TreasureChestUpWindow:__ExtendView()
end

function TreasureChestUpWindow:__CacheObject()
    self.curLev = self:Find("main/cur_lev",Text)
    self.nextLev = self:Find("main/next_lev",Text)

    self.qualityProbObjs = {}
    for k,v in pairs(GDefine.Quality) do self:GetQualityProbObj(v) end


    self.intensifyNode = self:Find("main/intensify_node").gameObject
    self.upLevNode = self:Find("main/up_lev_node").gameObject

    self.intensifyLineObjs = {}
    for i = 1, 20 do self:GetIntensifyLineObjs(i) end

    self.intensifyProgress = self:Find("main/intensify_node/progress_node/progress",Image)
    self.intensifyCost  = self:Find("main/intensify_node/intensify_btn/cost",Text)


    self.speedUpBtn = self:Find("main/up_lev_node/speed_up_btn").gameObject
    self.speedUpItemIcon = self:Find("main/up_lev_node/speed_up_btn/item_icon",Image)
    self.reduceTimeBtn = self:Find("main/up_lev_node/reduce_time_btn").gameObject
    self.upLevBtn = self:Find("main/up_lev_node/up_lev_btn").gameObject

    self.upLevTime = self:Find("main/up_lev_time",Text)

    self.expediteItemIcon = self:Find("main/expedite_item_icon",Image)
    self.expediteItemNum = self:Find("main/expedite_item_num",Text)


    self.checkIntensifyRemindParent = self:Find("main/intensify_node/intensify_btn/remind_node")
    self.checkUpLevRemindParent = self:Find("main/up_lev_node/up_lev_btn/remind_node")
end

function TreasureChestUpWindow:GetQualityProbObj(quality)
    local object = {}
    local root = self:Find(string.format("main/quality_prob_node/%s",quality)).gameObject
    object.curText = root.transform:Find("cur").gameObject:GetComponent(Text)
    object.nextText = root.transform:Find("next").gameObject:GetComponent(Text)
    self.qualityProbObjs[quality] = object
end

function TreasureChestUpWindow:GetIntensifyLineObjs(index)
    local object = {}
    local root = self:Find(string.format("main/intensify_node/progress_node/line/%s",index)).gameObject
    object.gameObject = root
    object.rectTrans = root:GetComponent(RectTransform)
    self.intensifyLineObjs[index] = object
end

function TreasureChestUpWindow:__BindListener()
    self:Find("main/close_btn",Button):SetClick(self:ToFunc("CloseClick"))
    self:Find("main/intensify_node/intensify_btn",Button):SetClick(self:ToFunc("IntensifyClick"))
    self:Find("main/up_lev_node/up_lev_btn",Button):SetClick(self:ToFunc("UpLevClick"))
    self:Find("main/up_lev_node/speed_up_btn",Button):SetClick(self:ToFunc("ExpediteClick"))
    self:Find("main/up_lev_node/reduce_time_btn",Button):SetClick(self:ToFunc("ReduceTimeClick"))
    self:Find("main/expedite_item_icon",Button):SetClick(self:ToFunc("ExpediteItemIconClick"))
end

function TreasureChestUpWindow:__BindEvent()
    self:BindEvent(TreasureChestUpWindow.Event.RefreshTreasureChestInfo)
end


function TreasureChestUpWindow:__Create()
    self.checkIntensifyRemind = MarkRemindItem.New()
    self.checkIntensifyRemind:SetParent(self.checkIntensifyRemindParent)
    self.checkIntensifyRemind:SetRemindId(RemindDefine.RemindId.commander_chest_intensify)

    self.checkUpLevRemind = MarkRemindItem.New()
    self.checkUpLevRemind:SetParent(self.checkUpLevRemindParent)
    self.checkUpLevRemind:SetRemindId(RemindDefine.RemindId.commander_chest_up_lev)
end

function TreasureChestUpWindow:__Show()
    self:RefreshTreasureChestInfo()
end

function TreasureChestUpWindow:RefreshTreasureChestInfo()
    local lev = mod.TreasureChestProxy.treasureChestInfo.level
    local conf = Config.TreasureBox.data_chest_intensify_info[lev]

    self.curLev.text = lev

    local existNext = Config.TreasureBox.data_chest_intensify_info[lev + 1] ~= nil
    self.nextLev.text = existNext and tostring(lev + 1) or "MAX"

    local qualityToProps = mod.TreasureChestProxy:GetChestLevQualityProp(lev)
    local nextQualityToProps = mod.TreasureChestProxy:GetChestLevQualityProp(lev + 1)

    for _,v in pairs(GDefine.Quality) do
        local objs = self.qualityProbObjs[v]
        local prop = qualityToProps[v] or 0

        objs.curText.text = prop > 0 and string.format("%.2f", prop * 0.0001 * 100) .. "%" or "0%"
        if existNext then
            prop = nextQualityToProps[v] or 0
            objs.nextText.text = prop > 0 and string.format("%.2f", prop * 0.0001 * 100) .. "%" or "0%"
        else
            objs.nextText.text = objs.curText.text
        end
    end

    if not existNext then
        self.intensifyNode:SetActive(false)
        self.upLevNode:SetActive(false)
    else
        if mod.TreasureChestProxy.treasureChestInfo.schedule < conf.intensify then
            self:RefreshIntensifyInfo()
        else
            self:RefreshUpLevInfo()
        end
    end


    self:RemoveTimer("up_lev_timer")
    if mod.TreasureChestProxy.treasureChestInfo.up_time > 0 then
        local remainTime = Network.Instance:GetRemoteRemainTime(mod.TreasureChestProxy.treasureChestInfo.up_time)
        self.upLevRemainTime = remainTime
        if self.upLevRemainTime > 0 then
            self:AddTimer("up_lev_timer",self.upLevRemainTime,1,self:ToFunc("UpLevTimer"))
        end
    else
        self.upLevRemainTime = 0
    end
    self:RefreshUpLevTime()



    local expediteItemId = Config.TreasureBox.data_chest_expedite_info[4].reduce_need[1][1]
    local expediteItemConf = Config.ItemData.data_item_info[expediteItemId]
    local expediteItemNum = mod.RoleItemProxy:GetItemNum(expediteItemId)
    self:SetSprite(self.expediteItemIcon, AssetPath.GetItemIcon(expediteItemConf.icon),true)
    self.expediteItemNum.text = expediteItemNum
end

function TreasureChestUpWindow:RefreshUpLevTime()
    self.upLevTime.text = TimeUtils.GetTimeFormat(self.upLevRemainTime)
end

function TreasureChestUpWindow:UpLevTimer()
    self.upLevRemainTime = self.upLevRemainTime - 1
    self:RefreshUpLevTime()
    if self.upLevRemainTime <= 0 then
        self:RemoveTimer("up_lev_timer")
    end
end

function TreasureChestUpWindow:RefreshIntensifyInfo()
    local lev = mod.TreasureChestProxy.treasureChestInfo.level
    local conf = Config.TreasureBox.data_chest_intensify_info[lev]

    self.intensifyNode:SetActive(true)
    self.upLevNode:SetActive(false)

    local intervalPosX = 506 / conf.intensify
    local showNum = conf.intensify - 1

    for i = 1, showNum do
        local objs = self.intensifyLineObjs[i]
        objs.gameObject:SetActive(true)
        objs.rectTrans:SetAnchoredPosition(intervalPosX * i,0)
    end

    for i = showNum + 1,#self.intensifyLineObjs do
        self.intensifyLineObjs[i].gameObject:SetActive(false)
    end

    self.intensifyProgress.fillAmount = mod.TreasureChestProxy.treasureChestInfo.schedule / conf.intensify

    self.intensifyCost.text = conf.reduce_need[1][2]
end

function TreasureChestUpWindow:RefreshUpLevInfo()
    self.intensifyNode:SetActive(false)
    self.upLevNode:SetActive(true)

    local upLev = mod.TreasureChestProxy.treasureChestInfo.up_time <= 0
    self.upLevBtn:SetActive(upLev)
    self.reduceTimeBtn:SetActive(not upLev)
    self.speedUpBtn:SetActive(not upLev)


    local itemId,_,_ = mod.TreasureChestProxy:GetExpeditetItemInfo()
    local conf = Config.ItemData.data_item_info[itemId]
    self:SetSprite(self.speedUpItemIcon,AssetPath.ItemIdToCurrencyIcon[itemId],true)
end

function TreasureChestUpWindow:CloseClick()
    ViewManager.Instance:CloseWindow(TreasureChestUpWindow)
end

function TreasureChestUpWindow:IntensifyClick()
    Log("发送强化")
    local lev = mod.TreasureChestProxy.treasureChestInfo.level
    local conf = Config.TreasureBox.data_chest_intensify_info[lev]
    local costItemId = conf.reduce_need[1][1]
    local costItemNum = conf.reduce_need[1][2]
    local flag = mod.JumpCtrl:CheckItemNumJumpWay(costItemId,costItemNum)
    if flag then
        self:CloseClick()
    else
        mod.CommanderFacade:SendMsg(11007)
    end
end

function TreasureChestUpWindow:UpLevClick()
    Log("发送升级")
    mod.CommanderFacade:SendMsg(11007)
end

function TreasureChestUpWindow:ExpediteClick()
    local itemId,_,_,flag = mod.TreasureChestProxy:GetExpeditetItemInfo()
    if not flag then
        mod.JumpCtrl:ItemJumpWay(itemId)
    else
        ViewManager.Instance:OpenWindow(TreasureChestExpediteWindow)
    end
end

function TreasureChestUpWindow:ReduceTimeClick()
    SystemMessage.Show("暂未开放广告功能")
end

function TreasureChestUpWindow:ExpediteItemIconClick()
    local expediteItemId = Config.TreasureBox.data_chest_expedite_info[4].reduce_need[1][1]

    local data = {}
    data.item_id = expediteItemId
    data.count = mod.RoleItemProxy:GetItemNum(expediteItemId)

    mod.TipsCtrl:OpenItemTips(data,self.expediteItemIcon.transform)
end