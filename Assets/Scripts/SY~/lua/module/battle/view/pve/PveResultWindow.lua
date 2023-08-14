PveResultWindow = BaseClass("PveResultWindow", BaseWindow)

function PveResultWindow:__Init()
    self:SetAsset("ui/prefab/battle_result/pve_result_window.prefab",AssetType.Prefab)
    self.statisticsPanel = nil
    self.tbItem = {}
    self.awardObjs = {}
end

function PveResultWindow:__CacheObject()
    self.objWinBg = self:Find("img_win_bg").gameObject
    self.objLoseBg = self:Find("img_lose_bg").gameObject
    self.btnClose = self:Find("btn_bg_close",Button)
    self.objWinTitle = self:Find("main/img_win").gameObject
    self.objLoseTitle = self:Find("main/img_lose").gameObject
    self.txtLevelName = self:Find("main/image_5/txt_lv_name",Text)
    self.imgPlayerIcon = self:Find("main/image_55/img_player_icon",Image)
    self.txtPlayerName = self:Find("main/image_55/txt_player_name",Text)
    self.txtTime = self:Find("main/image_55/txt_time",Text)
    self.imgCmdIcon = self:Find("main/image_9/img_cmd_icon",Image)
    self.transContent = self:Find("main/image_9/result_content")
    self.txtCloseTips = self:Find("main/txt_click_tips",Text)
    self.btnStatistics = self:Find("main/btn_data",Button)
    self.txtAwardTitle = self:Find("main/image_45/txt_award_title",Text)
    self.txtTotalTime = self:Find("main/image_55/txt_time",Text)
    self.template = self:Find("main/image_9/result_content/pve_result_item").gameObject
    self.template:SetActive(false)
    self.awardTemplate = self:Find("main/image_45/award_content/award_item").gameObject
    self.awardTemplate:SetActive(false)
    self.awardContent = self:Find("main/image_45/award_content")
end

function PveResultWindow:__Create()
    self.txtCloseTips.text = TI18N("点击空白处关闭")
    self.txtAwardTitle.text = TI18N("奖励")
    self.btnClose:SetClick(self:ToFunc("OnCloseButtonClick"))
    -- self.btnStatistics:SetClick(self:ToFunc("OnStatistButtonClick"))
    self.btnStatistics.gameObject:SetActive(false) --TODO 暂时屏蔽
end


function PveResultWindow:RecycleAllItem()
    for _, item in ipairs(self.tbItem or {}) do
        item:OnRecycle()
        item:Destroy()
    end
    self.tbItem = {}
    for _, obj in ipairs(self.awardObjs) do
        GameObject.Destroy(obj)
    end
    self.awardObjs = {}
end

function PveResultWindow:OnCloseButtonClick()
    self:RecycleAllItem()
    ViewManager.Instance:CloseWindow(PveResultWindow)
    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_close, "pve_result")
    if RunWorld then
        mod.BattleCtrl:ExitPve(RunWorld)
    end
end

function PveResultWindow:OnStatistButtonClick()
    if not self.statisticsPanel then
        self.statisticsPanel = BattleStatisticsPanel.New()
        self.statisticsPanel:SetParent(self.transform)
    end
    self.statisticsPanel:Show()
end

function PveResultWindow:__BindEvent()
end

function PveResultWindow:__Show()
    local is_win = self.args.isWin
    local item_list = self.args.itemList
    local totalSec = self.args.totalSec
    local skill_list = self.args.skillList
    local name = self.args.name
    self:RefreshStyle(is_win,item_list,skill_list,totalSec,name)
    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_open, "pve_result")
end

function PveResultWindow:RefreshStyle(is_win,item_list,skill_list,totalSec,name)
    self:RecycleAllItem()
    self.objWinBg:SetActive(is_win)
    self.objWinTitle:SetActive(is_win)
    self.objLoseBg:SetActive(not is_win)
    self.objLoseTitle:SetActive(not is_win)
    --技能
    for i = 1, 4 do
        local item = PveResultItem.Create(self.template)
        item.transform:SetParent(self.transContent)
        item.transform.localScale = Vector3.one
        local data = skill_list[i] or { isEmpty = true }
        item:SetData(data, i)
        table.insert(self.tbItem, item)
    end
    --奖励
    for _, item in ipairs(item_list) do
        local awardItem = GameObject.Instantiate(self.awardTemplate)
        local img = awardItem.transform:Find("img_icon"):GetComponent(Image)
        local txt = awardItem.transform:Find("txt_num"):GetComponent(Text)
        awardItem:SetActive(true)
        awardItem.transform:SetParent(self.awardContent)
        awardItem.transform:Reset()
        local conf = Config.ItemData.data_item_info[item.item_id]
        self:SetSprite(img, AssetPath.GetItemIcon(conf.icon),true)
        txt.text = item.count
        table.insert(self.awardObjs,awardItem)
    end
    --时间
    self.txtTotalTime.text = TimeUtils.GetMinSecTimeByChinese(totalSec)
    --基本信息
    self.txtLevelName.text = name
    self.txtPlayerName.text = mod.RoleProxy.roleData.name
    self:SetSprite(self.imgCmdIcon, AssetPath.GetCommanderVerticalHeadIcon(2002))
end

function PveResultWindow:__Hide()
    if self.statisticsPanel then
        self.statisticsPanel:Destroy()
        self.statisticsPanel = nil
    end
end