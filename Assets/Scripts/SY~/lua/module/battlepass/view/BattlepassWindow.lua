BattlepassWindow = BaseClass("BattlepassWindow",BaseWindow)
BattlepassWindow.ItemHeight = 191

BattlepassWindow.Event = EventEnum.New(
    "RefreshProgress",
    "RefreshAwardState",
    "RefreshVipState",
    "GetGuideBattlepassRewardPos"
)

function BattlepassWindow:__Init()
    self:SetAsset("ui/prefab/battlepass/battlepass_window.prefab",AssetType.Prefab)
    self.currentIndex = 0
end

function BattlepassWindow:__CacheObject()
    self.canvasTop = self:Find("canvas_top",Canvas)
    self.txtTitle = self:Find("canvas_top/txt_title",Text)
    self.txtCountDown = self:Find("canvas_top/img_time/txt_countdown",Text)
    self.imgPgrFill = self:Find("canvas_top/img_total_pgr/image_40/image_41",Image)
    self.txtPgrFill = self:Find("canvas_top/img_total_pgr/image_40/image_41/text_42",Text)
    self.txtPgrLevel = self:Find("canvas_top/img_total_pgr/image_46/txt_level",Text)
    self.txtDailyMaxExp = self:Find("canvas_top/img_total_pgr/Image/txt_daily_score",Text)
    self.btnInfo = self:Find("canvas_top/btn_info",Button)

    self.scrollview = self:Find("scroll_view",ScrollRect)

    self.canvasBottom = self:Find("canvas_bottom",Canvas)
    self.btnBuy = self:Find("canvas_bottom/bottom/image_52",Button)
    self.txtBuy = self:Find("canvas_bottom/bottom/image_52/text_53",Text)
    self.btnConfirm = self:Find("canvas_bottom/bottom/image_49",Button)
    self.txtConfirm = self:Find("canvas_bottom/bottom/image_49/text_50",Text)

    self.txtVip = self:Find("scroll_view/Viewport/Content/img_vip/txt_vip_name",Text)
    self.txtNormal = self:Find("scroll_view/Viewport/Content/img_normal/txt_normal_name",Text)

    self.template = self:Find("scroll_view/Viewport/Content/battlepass_item").gameObject
    self.template:SetActive(false)
end

function BattlepassWindow:__Create()
    self.txtVip.text = TI18N("凤凰令牌")
    self.txtNormal.text = TI18N("免费!")
end

function BattlepassWindow:__BindListener()
    self.btnBuy:SetClick(self:ToFunc("OnBuyButtonClick"))
    self.btnConfirm:SetClick(self:ToFunc("OnConfirmButtonClick"))
    self.btnInfo:SetClick(self:ToFunc("OnInfoButtonClick"))
end

function BattlepassWindow:__BindEvent()
    self:BindEvent(BattlepassWindow.Event.RefreshProgress)
    self:BindEvent(BattlepassWindow.Event.RefreshAwardState)
    self:BindEvent(BattlepassWindow.Event.RefreshVipState)
    self:BindEvent(BattlepassWindow.Event.GetGuideBattlepassRewardPos)
end

function BattlepassWindow:__Show()
    self.currentIndex = 0
    self.canvasTop.sortingOrder = self.rootCanvas.sortingOrder + 2
    self.canvasBottom.sortingOrder = self.rootCanvas.sortingOrder + 2
    self:InitLoopScrollView()
    self:RefreshAllStytle()
end

function BattlepassWindow:InitLoopScrollView()
    self:RemoveLoopScrollView()
    self.loopScrollView = self:GetLoopScrollView()
    self:SetDataToLoopScrollView()
    self.loopScrollView:Start()
end

function BattlepassWindow:RefreshAllStytle()
    self:RefreshProgressStyle()
    self:RefreshAwardListStyle()
    self:RefreshSeasonStyle()
    self.btnBuy.gameObject:SetActive(not mod.BattlepassProxy:IsVip())
end

function BattlepassWindow:RefreshProgressStyle(kvs)
    local data = mod.BattlepassProxy:GetAllData()
    local lv = data.level
    local exp = data.exp
    local seasonId = data.season_id
    local dailyGet = data.day_exp
    local nextExp = mod.BattlepassProxy:GetInfoConfig(seasonId,lv).need_exp
    self.txtPgrLevel.text = lv + 1
    self.txtPgrFill.text = string.format("%d/%d",exp,nextExp)
    self.imgPgrFill.fillAmount = exp / nextExp
    local dailyMax = Config.BattlePassData.data_battlepass_const[5]
    self.txtDailyMaxExp.text = string.format("%s:%d/%d",TI18N("今日获取积分"),dailyGet,dailyMax)
end

function BattlepassWindow:RefreshAwardListStyle(sc)
    if sc then
        local update = {}
        for i, info in pairs(sc.list) do
            if not update[info.level] then
                update[info.level] = {}
            end
            if info.is_pay == 1 then
                update[info.level].UpdateVip = true
            else
                update[info.level].UpdateFree = true
            end
        end
        -- LogYqh("RefreshAwardListStyle",update)
        self.loopScrollView:RangeRenderItem(function (itemData)
            local item = itemData.obj
            local data = update[item.data.level]
            if data then
                if data.UpdateFree then
                    item:RefreshFreeAward()
                end
                if data.UpdateVip then
                    item:RefreshVipAward()
                end
            end
        end)
    end
end

function BattlepassWindow:RefreshSeasonStyle()
    --TODO 更新赛季名、倒计时
end

function BattlepassWindow:__Hide()
    self:RemoveLoopScrollView()
end

function BattlepassWindow:SetDataToLoopScrollView()
    local seasonId = mod.BattlepassProxy:GetSeasonId()
    self.loopScrollView:ClearAllData()
    local seasonData = Config.BattlePassData.data_battlepass_season[seasonId]
    for _, season in ipairs(seasonData or {}) do
        local data = mod.BattlepassProxy:GetInfoConfig(seasonId,season.level)
        self.loopScrollView:AddData({
            data = data
        })
    end
end

function BattlepassWindow:GetLoopScrollView()
    local helper = VerticalLoopScrollView.New(self.scrollview, {
        paddingTop = 165,
        paddingBottom = 0,
        overflowUp = BattlepassWindow.ItemHeight,
        overflowDown = BattlepassWindow.ItemHeight * 2,
        -- gapY = 0,
        alignType = LoopScrollViewDefine.AlignType.Top,
        onCreate = self:ToFunc("OnItemCreate"),
        onRender = self:ToFunc("OnItemRender"),
        onRecycle = self:ToFunc("OnItemRecycle"),
        onComplete = self:ToFunc("OnLoopScrollViewFillComplete"),
        revertSibling = false,
        itemWidth = 720,
        itemHeight = BattlepassWindow.ItemHeight,
    })
    return helper
end

function BattlepassWindow:RemoveLoopScrollView()
    if self.loopScrollView then
        self.loopScrollView:Delete()
        self.loopScrollView = nil
    end
end

function BattlepassWindow:OnItemCreate(index, data)
    return BattlepassItem.Create(self.template)
end

function BattlepassWindow:OnItemRender(item, index, data)
    item:SetData(data.data, index, self)
end

function BattlepassWindow:OnItemRecycle(item)
    item:OnRecycle()
end

function BattlepassWindow:OnLoopScrollViewFillComplete()
    self:ScrollToTargetPos(0.01)
end

function BattlepassWindow:OnBuyButtonClick()
    SystemMessage.Show(TI18N("敬请期待"))
end

function BattlepassWindow:OnConfirmButtonClick()
    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_close, "battlepass")
    ViewManager.Instance:CloseWindow(BattlepassWindow)
end

function BattlepassWindow:OnInfoButtonClick()
    local info = Config.BattlePassData.data_battlepass_content[1]
    mod.TipsCtrl:OpenTipsWindow(info.title,info.content,self.btnInfo.transform)
end

--srv call
function BattlepassWindow:RefreshProgress(kvs)
    self:RefreshProgressStyle(kvs)
end

--srv call
function BattlepassWindow:RefreshAwardState(kvs)
    self:RefreshAwardListStyle(kvs)
end

--srv call
function BattlepassWindow:RefreshVipState(kvs)
    self.loopScrollView:RangeRenderItem(function (itemData)
        local item = itemData.obj
        item:RefreshAllStyle()
    end)
    self.btnBuy.gameObject:SetActive(not mod.BattlepassProxy:IsVip())
end

function BattlepassWindow:GetGuideBattlepassRewardPos(id, callback)
    if self.currentIndex <= 0 then
        return
    end
    local arr = StringUtils.Split(id, '_') --如 "vip_1" "free_2"
    local targetTpe = "free"
    local targetLv = 1
    if arr then
        targetTpe = arr[1]
        targetLv = tonumber(arr[2]) or 1
    end
    local renderItem = self.loopScrollView:GetRenderItemByDataIndex(targetLv)
    if renderItem then
        local item = renderItem.obj
        local rect
        if targetTpe == "vip" then
            rect = item.btnVip.gameObject:GetComponent(RectTransform)
        else
            rect = item.btnNormal.gameObject:GetComponent(RectTransform)
        end
        callback(rect, rect)
    end
end

function BattlepassWindow:ScrollToTargetPos(moveSpeed)
    --TODO 瞬间跳转到可领或者最高积分位置
    local rewardIndex,isVip = mod.BattlepassProxy:GetUnclaimedAwardLevel()
    local args = {}
    if rewardIndex > 0 then
        args.currentIndex = rewardIndex
    else
        local data = mod.BattlepassProxy:GetAllData()
        args.currentIndex = data.level
    end
    self.loopScrollView:ScrollToItem(args.currentIndex, function ()
        self:PlayEnterAnim(args)
    end,moveSpeed,nil,LoopScrollViewDefine.JumpType.Center)
end

function BattlepassWindow:PlayEnterAnim(args)
    --TODO 缓慢从某个地方滚动到目标位置
    self:OnEnterAnimFinish(args)
end

function BattlepassWindow:OnEnterAnimFinish(args)
    if args then
        self.currentIndex = args.currentIndex or 1
    end
    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_open, "battlepass")
end