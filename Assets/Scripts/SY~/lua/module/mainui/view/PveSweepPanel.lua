PveSweepPanel = BaseClass("PveSweepPanel",ExtendView)

PveSweepPanel.Event = EventEnum.New(
    "RefreshSweepCount"
)

function PveSweepPanel:__Init()
    self.propItems = {}
end

function PveSweepPanel:__Delete()
    for i, v in ipairs(self.propItems) do
        v:Destroy()
    end
end

function PveSweepPanel:__CacheObject()
    self.trans = self:Find("sweep_panel")

    self.rewardTemplete = self:Find("templete/reward_info_item").gameObject
    self.propItemTemp = self:Find("templete/prop_item").gameObject
    self.propItemCon = self:Find("main/sweep_reward/con",nil,self.trans)

    self.sweepBtn = self:Find("main/sweep_btn",Button,self.trans)
    self.freeTips = self:Find("main/sweep_btn/free",nil,self.trans).gameObject
    self.consumeTips = self:Find("main/sweep_btn/consume",nil,self.trans).gameObject
    self.maxCountTips = self:Find("main/sweep_btn/max_count",nil,self.trans).gameObject

    self.consumeNum = self:Find("main/sweep_btn/consume/num",Text,self.trans)
    self.consumeCount = self:Find("main/sweep_btn/consume/count",Text,self.trans)

    self.previewTitle = self:Find("main/preview_reward/title",Text,self.trans)
end

function PveSweepPanel:__Create()
    self:CloneRewardItems()

    self.freeTips.transform:Find("text").gameObject:GetComponent(Text).text = TI18N("免费扫荡")
    self.freeTips.transform:Find("free_tips").gameObject:GetComponent(Text).text = TI18N("每日首次扫荡免费")
    self.consumeTips.transform:Find("text").gameObject:GetComponent(Text).text = TI18N("扫荡")
    self.maxCountTips.transform:Find("text").gameObject:GetComponent(Text).text = TI18N("今日扫荡完成")
end

function PveSweepPanel:CloneRewardItems()
    for i = 1, 4 do
        local propItem = PropItem.Create(self.propItemTemp)
        propItem:SetParent(self.propItemCon,0,0)
        propItem.transform:Reset()
        propItem:Show()
        table.insert(self.propItems,propItem)
    end
end

function PveSweepPanel:__BindEvent()
    self:BindEvent(PveSweepPanel.Event.RefreshSweepCount)
end

function PveSweepPanel:__BindListener()
    self:Find("panel_bg",Button,self.trans):SetClick( self:ToFunc("OnInactive") )
    self:Find("main/close_btn",Button,self.trans):SetClick( self:ToFunc("OnInactive") )

    self.sweepBtn:SetClick( self:ToFunc("OnSweepBtnClick") )
end

function PveSweepPanel:OnActive()
    self.trans.gameObject:SetActive(true)
end

function PveSweepPanel:OnInactive()
    self.trans.gameObject:SetActive(false)
end

function PveSweepPanel:SetData()
    self.pveProgress = mod.BattlePveProxy.pveProgress
    self.pveId = self.pveProgress.pve_id
    self.conf = self.pveId == 0 and Config.PveData.data_pve[1] or Config.PveData.data_pve[self.pveId]
    local consumeGroup = self.conf.sweep_consume_group
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

function PveSweepPanel:SetSweepReward()
    local k = 1
    for i, v in ipairs(self.sweepReward) do
        local rewardData = {}
        rewardData.item_id = v[1]
        rewardData.count = v[2]
        self.propItems[i]:SetData(rewardData)
        k = i
    end
    for i = k+1, 4 do
        self.propItems[i]:Hide()
    end
end

function PveSweepPanel:SetConsume()
    local sweepCount = self.maxCount - self.pveProgress.sweep_count

    if sweepCount == 0 then
        self.freeTips:SetActive(false)
        self.consumeTips:SetActive(false)
        self.maxCountTips:SetActive(true)
        return
    end

    self.maxCountTips:SetActive(false)

    local consume = self.consumeConf.consume
    if TableUtils.IsEmpty(consume) then
        self.freeTips:SetActive(true)
        self.consumeTips:SetActive(false)
        return
    end

    local consumeNum = consume[1][2]
    local roleAdvTicket = mod.RoleItemProxy:GetItemNum(GDefine.ItemId.AdvTicket)
    local color = "#ffffff"
    if roleAdvTicket < consumeNum then
        color = "#ff8080"
    end
    self.consumeNum.text = string.format("(%s/%s)",UIUtils.GetColorText(roleAdvTicket,color),consumeNum)
    self.consumeTips:SetActive(true)

    self.consumeCount.text = TI18N(string.format("剩余次数(%s/%s)",sweepCount,self.maxCount))
end

function PveSweepPanel:RefreshSweepCount()
    self:SetData()
end

function PveSweepPanel:OnSweepBtnClick()
    local sweepCount = self.maxCount - self.pveProgress.sweep_count
    if sweepCount <= 0 then
        SystemMessage.Show(TI18N("今日扫荡已达次数上限"))
        return
    end

    local consumeGroup = self.conf.sweep_consume_group
    local consumeKey = consumeGroup.."_"..tostring(self.pveProgress.sweep_count)

    if sweepCount ~= 0 then
        if self.consumeConf then
            local costItemId = GDefine.ItemId.AdvTicket
            local costItemNum = self.consumeConf.consume[1][2]
            local flag = mod.JumpCtrl:CheckItemNumJumpWay(costItemId,costItemNum)
            if flag then
                return
            else
                mod.BattleFacade:SendMsg(10902)
            end
        end
    end
end