RankWindow = BaseClass("RankWindow",BaseWindow)

RankWindow.JumpType = {
    Normal = 1,
    LvUp = 2,
    Reward = 3,
}

RankWindow.Event = EventEnum.New(
    "RefreshRewardState",
    "RefreshRankStyle",
    "ActiveFocusButton",
    "GetGuideDivisionRewardPos",
    "GetGuideDivisionPos",
    "GetGuideDivisionUnlockCardPos",
    "ShowHeroDetailsPanel"
)

RankWindow.RankID = 1001

function RankWindow:__Init()
    self:SetAsset("ui/prefab/division/rank_main_window.prefab",AssetType.Prefab)
    self:AddAsset(AssetPath.rankItemAnimCtrl,AssetType.Object)
    self.currentIndex = 0
    self.targetPos = nil
    self.tbToPlayAnimItem = {}
    self.animTimer = nil
end

function RankWindow:__CacheObject()
    self.btnFocus = self:Find("btn_focus",Button)
    self.scrollview = self:Find("scroll_view", ScrollRect)
    self.tranBottom = self:Find("bottom")
    self.btnBack = self:Find("bottom/btn_back",Button)
    self.btnJumpUp = self:Find("canvas_jump_btns/btn_jump_up",Button)
    self.btnJumpDown = self:Find("canvas_jump_btns/btn_jump_down",Button)
    self.objJumpUp = self.btnJumpUp.transform.gameObject
    self.objJumpDown = self.btnJumpDown.transform.gameObject
    self.rectCursor = self:Find("scroll_view/viewport/content/cursor_pos/cursor",RectTransform)
    self.txtCursor = self:Find("scroll_view/viewport/content/cursor_pos/cursor/txt_current",Text)
    self.canvasGroupCursor = self:Find("scroll_view/viewport/content/cursor_pos/cursor",CanvasGroup)
    self.rectCursorPos = self:Find("scroll_view/viewport/content/cursor_pos",RectTransform)
    self.rectCloudPos = self:Find("bottom/cloud_effect_pos",RectTransform)
    self.canvasBottom = self:Find("bottom/bottom_canvas",Canvas)
    self.canvasGroupBottom = self:Find("bottom/bottom_canvas",CanvasGroup)
    self.canvasJumpBtn = self:Find("canvas_jump_btns",Canvas)
    self.template = self:Find("scroll_view/viewport/content/rank_item").gameObject
    self.template:SetActive(false)
end

function RankWindow:__Create()
    self.divisionCfg = Config.DivisionData.data_division_info
    self.trophyRewardCfg = Config.DivisionData.data_trophy_reward
    self.objJumpUp:SetActive(false)
    self.objJumpDown:SetActive(false)
end

function RankWindow:__BindListener()
    self.btnBack:SetClick(self:ToFunc("OnBackButtonClick"))
    self.btnJumpUp:SetClick(self:ToFunc("OnJumpButtonClick"),true)
    self.btnJumpDown:SetClick(self:ToFunc("OnJumpButtonClick"),false)
    self.btnFocus:SetClick(self:ToFunc("OnFocusButtonClick"))
end

function RankWindow:__BindEvent()
    self:BindEvent(RankWindow.Event.RefreshRewardState)
    self:BindEvent(RankWindow.Event.RefreshRankStyle)
    self:BindEvent(RankWindow.Event.GetGuideDivisionRewardPos)
    self:BindEvent(RankWindow.Event.GetGuideDivisionPos)
    self:BindEvent(RankWindow.Event.GetGuideDivisionUnlockCardPos)
    self:BindEvent(RankWindow.Event.ActiveFocusButton)
    self:BindEvent(RankWindow.Event.ShowHeroDetailsPanel)
end

function RankWindow:SetDataToLoopScrollView()
    self.loopScrollView:ClearAllData()
    local showList = mod.DivisionProxy:GetShowList()
    for _, data in ipairs(showList or {}) do
        self.loopScrollView:AddData({
            data = data,
            size = RankItem.CalcSize(data.divisionInfo, data.trophyReward),
        })
    end
end

function RankWindow:GetRankItemIndexByPlayerDivision(division,trophy)
    local showList = mod.DivisionProxy:GetShowList()
    local length = #showList
    local index = length
    for i = length, 1, -1 do --TODO 有序，改成二分查找
        local data = showList[i]
        local tro = 0
        if data.divisionInfo then
            tro = data.divisionInfo.trophy
        else
            tro = data.trophyReward.trophy
        end
        if tro > trophy then
            break
        end
        index = i
    end
    return index
end

function RankWindow:__Show()
    self.isGuideFindUnlock = false
    self.isGuideFindDivision = false
    self.canvasBottom.sortingOrder = self.rootCanvas.sortingOrder + 4
    self.canvasJumpBtn.sortingOrder = self.rootCanvas.sortingOrder + 5
    self.canvasGroupBottom.alpha = 0
    self.canvasGroupCursor.alpha = 0
    self.currentIndex = 0
    self.tbToPlayAnimItem = {}
    self.fixCursor = true
    self.bAutoScroll = true
    self.assetItemAnimCtrl = self:GetAsset(AssetPath.rankItemAnimCtrl)
    self.roleData = mod.RoleProxy:GetRoleData()
    self:RemoveLoopScrollView()
    self.loopScrollView = self:GetLoopScrollView()
    self:SetDataToLoopScrollView()
    self.loopScrollView:Start()
    self.rectCursor:SetParent(self.rectCursorPos) --游标默认挂载Pos下，加载完特效，会把游标挂载特效下，回收特效后再挂回Pos
    self.rectCursor:Reset()
    self.rectCursor.gameObject:SetActive(false)
    self.txtCursor.text = mod.DivisionProxy:GetPlayerTrophy()
    self:LoadAllEffect()
    mod.DivisionProxy:SendMsg(11300,RankWindow.RankID)
    self:ActiveFocusButton(false)
end

function RankWindow:RefreshRewardState(rewardId)
    self.loopScrollView:RangeRenderItem(function (itemData)
        local item = itemData.obj
        if not item.isDivision and item.realData.id == rewardId then
            item:SetData(item.data, item.index, self)
            return true
        end
    end)
end

function RankWindow:GetLoopScrollView()
    local helper = VerticalLoopScrollView.New(self.scrollview, {
        paddingTop = 300,
        paddingBottom = 300,
        overflowUp = 1000,
        overflowDown = 2000,
        -- gapY = 0,
        alignType = LoopScrollViewDefine.AlignType.Top,
        onCreate = self:ToFunc("OnItemCreate"),
        onRender = self:ToFunc("OnItemRender"),
        onRecycle = self:ToFunc("OnItemRecycle"),
        onComplete = self:ToFunc("OnLoopScrollViewFillComplete"),
        onRenderNew = self:ToFunc("OnLoopScrollViewRenderNew"),
        revertSibling = false,
        ignoreOriginChild = true,
    })
    return helper
end

function RankWindow:GetLoopScrollViewData()
    return self.loopScrollView:GetAllData()
end

function RankWindow:OnItemCreate(index, data)
    local item = RankItem.Create(self.template)
    item:SetAnim(AssetPath.rankItemAnimCtrl, self.assetItemAnimCtrl)
    return item
end

function RankWindow:OnItemRender(item, index, data)
    item:SetData(data.data, index, self)
end

function RankWindow:OnItemRecycle(item)
    item:OnRecycle()
end

function RankWindow:OnLoopScrollViewFillComplete()
    self:ScrollToTargetPos(false)
    self:UpdateJumpButtonStatus()
    self.rectCursorPos:SetAsLastSibling()
end

function RankWindow:ActiveFocusButton(active)
    self.btnFocus.gameObject:SetActive(active)
end

function RankWindow:OnLoopScrollViewRenderNew()
    self:FixAllItemProgressbar()
    self:UpdateJumpButtonStatus()
    self.rectCursorPos:SetAsLastSibling()
end

function RankWindow:FixAllItemProgressbar()
    --TODO 防止数据量过大，可以排序后根据进度段裁剪一部分
    local list = mod.DivisionProxy.rankList[RankWindow.RankID]
    local lastDivisionData
    self.loopScrollView:RangeRenderItem(function (itemData)
        if lastDivisionData then
            itemData.obj:FixProgressbarLengthByNextItem(itemData.rectTransform,lastDivisionData.rectTransform,lastDivisionData.obj)
        else
            itemData.obj:SetProgressbarLength(0)
        end
        if self.fixCursor then
            self.fixCursor = itemData.obj:TryShowCursorAndProgress(lastDivisionData and lastDivisionData.obj,self.rectCursorPos)
        else
            itemData.obj:TryShowCursorAndProgress(lastDivisionData and lastDivisionData.obj, nil)
        end
        if list then
            itemData.obj:TryShowRankCursor(lastDivisionData and lastDivisionData.obj, list)
        end
        lastDivisionData = itemData
    end,true)
end

--按照一定规则跳转到目标位置
--段位刚好升级>有可领的奖励>当前杯数
function RankWindow:ScrollToTargetPos(force)
    if not force and not self.bAutoScroll then
        return
    end
    self.loopScrollView:EnableScroll(false)
    self.bAutoScroll = false
    local lastDivision = mod.DivisionProxy:GetRankWinLastShowDivision()
    local lastTrophy = mod.DivisionProxy:GetRankWinLastShowTrophy()
    local division = mod.RoleProxy:GetRoleData().division
    local trophy = mod.RoleProxy:GetRoleData().trophy
    local index = self:GetRankItemIndexByPlayerDivision(division,trophy)
    LogAny("----> 跳转到目标位置 lastDivision=",lastDivision,',division=',division,
        ',index=',index,',currentIndex=',self.currentIndex)
    if lastDivision ~= division then
        LogAny("跳转到当前段位(升段!)",index)
        --跳转到当前段位
        local clickIndex = index    --滚动到段位那一行，但是点击位置是其奖励
        if mod.DivisionProxy:ContainAward(division) then
            clickIndex = clickIndex + 1
        end
        self:PlayEnterAnim({currentIndex=clickIndex,type=RankWindow.JumpType.LvUp})
    else
        local rewardIndex,rewardId = mod.DivisionProxy:GetUnclaimedRewardItemIndex()
        if rewardIndex > 0 then
            LogAny("跳转到奖励",rewardIndex)
            --跳转到可领奖励那一项
            self:PlayEnterAnim({currentIndex=rewardIndex,type=RankWindow.JumpType.Reward})
        else
            --跳转到当前杯数
            LogAny("跳转到当前杯数",index)
            self:PlayEnterAnim({currentIndex=index,type=RankWindow.JumpType.Normal})
        end
    end
    mod.DivisionProxy:OnRankWindowEnterFinish()
end

function RankWindow:RemoveLoopScrollView()
    if self.loopScrollView then
        self.loopScrollView:Delete()
        self.loopScrollView = nil
    end
end

function RankWindow:OnBackButtonClick()
    if self.battleHeroDetailsPanel then
        self.battleHeroDetailsPanel:Destroy()
        self.battleHeroDetailsPanel=nil
    end
    self:RemoveAnimTimer()
    self:RemoveLoopScrollView()
    self:RecycleAllEffect()
    self:ActiveFocusButton(false)
    ViewManager.Instance:CloseWindow(RankWindow)
    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_close, "division")
end

--段位奖励
function RankWindow:GetGuideDivisionRewardPos(args, callback)
    if self.currentIndex <= 0  then
        return
    end
    local renderItem = self.loopScrollView:GetRenderItemByDataIndex(self.currentIndex)
    if renderItem then
        local item = renderItem.obj
        local rect = item.btnReward.gameObject:GetComponent(RectTransform)
        callback(item.transform, rect)
    end
end

--段位
function RankWindow:GetGuideDivisionPos(args, callback)
    if self.isGuideFindDivision then
        return
    end
    self.isGuideFindDivision = true
    local setting = self.loopScrollView.setting
    local conf = Config.DivisionData.data_division_info[args.division]
    local trophy = conf.trophy
    local y = RankItem.CalcCursorPosY(trophy,setting.paddingTop,setting.gapY,self.loopScrollView.viewport.rect.height)
    self.loopScrollView:ScrollToPositionY(y, function ()
        self.loopScrollView:RangeRenderItem(function (itemData)
            local item = itemData.obj
            if item.isDivision and item.existUnlockList then
                if item.realData.division == args.division then
                    local rect = item.objRankInfo:GetComponent(RectTransform)
                    callback(rect, rect)
                    self.isGuideFindDivision = false
                    return true
                end
            end
        end)
    end,0.5)
end

--段位解锁卡牌
function RankWindow:GetGuideDivisionUnlockCardPos(args, callback)
    if self.isGuideFindUnlock then
        return
    end
    self.isGuideFindUnlock = true
    local setting = self.loopScrollView.setting
    local conf = Config.DivisionData.data_division_info[args.division]
    local trophy = conf.trophy
    local y = RankItem.CalcCursorPosY(trophy,setting.paddingTop,setting.gapY,self.loopScrollView.viewport.rect.height)
    self.loopScrollView:ScrollToPositionY(y, function ()
        self.loopScrollView:RangeRenderItem(function (itemData)
            local item = itemData.obj
            if item.isDivision and item.existUnlockList then
                if item.realData.division == args.division then
                    local rect = item.objUnlockInfo:GetComponent(RectTransform)
                    callback(rect, rect)
                    self.isGuideFindUnlock = false
                    return true
                end
            end
        end)
    end,0.5)
end

function RankWindow:OnJumpButtonClick(isUp)
    if not self.targetPos then return end
    local moveSpeed = 0.4
    self.loopScrollView:ScrollToPosition(self.targetPos,self:ToFunc("UpdateJumpButtonStatus"),
        moveSpeed,nil,LoopScrollViewDefine.JumpType.Center)
end

function RankWindow:OnFocusButtonClick()
    self:CloseAllRankCursorView()
    self:ActiveFocusButton(false)
end

function RankWindow:UpdateJumpButtonStatus()
    if not self.targetPos then return end

    local current = self.loopScrollView.content.localPosition
    local viewH = self.loopScrollView.viewport.rect.height
    local centerH = viewH / 2
    local offsetY = current.y - self.targetPos.y
    self.objJumpUp:SetActive(offsetY > centerH)
    self.objJumpDown:SetActive(offsetY < -centerH)
end

function RankWindow:LoadEffect(effectId,parent,pos)
    local order = self.rootCanvas.sortingOrder + 3
    self:LoadUIEffect({
        confId = effectId,
        parent = parent,
        order = order,
        onLoad = self:ToFunc("OnEffectLoad"),
        pos = pos,
    },true)
end

function RankWindow:LoadAllEffect()
    local config = {
        [AssetPath.DivisionEffectType.Cloud] =  {parent = self.rectCloudPos, pos = {x=0,y=0,z=0}},
        [AssetPath.DivisionEffectType.Cursor] = {parent = self.rectCursorPos, pos = {x=75,y=-33,z=0}},
    }
    for tpe, data in pairs(config) do
        local eid = AssetPath.DivisionEffectID[tpe]
        self:LoadEffect(eid, data.parent, data.pos)
    end
    local anims = ParallelAnim.New({
        ToAlphaAnim.New(self.canvasGroupBottom, 1, 0.4):SetDelay(1.2),
        ToAlphaAnim.New(self.canvasGroupCursor, 1, 0.4):SetDelay(1.2),
    })
    anims:Play()
end

function RankWindow:OnEffectLoad(effectId, effect)
    if effectId == AssetPath.DivisionEffectID[AssetPath.DivisionEffectType.Cursor] then
        --TODO 游标位置因为挂载点不是RectTransform导致锚点有问题，注意不能直接挂在RectTransform，否则transform会为空
        local root = effect.effect.transform:Find("Qipao")
        self.rectCursor:SetParent(root)
        self.rectCursor:Reset()
        self.rectCursor.gameObject:SetActive(true)
    end
end

function RankWindow:RecycleAllEffect()
    self.rectCursor:SetParent(self.rectCursorPos)
    self.rectCursor:Reset()
    self.rectCursor.gameObject:SetActive(false)
end

function RankWindow:PlayEnterAnim(args)
    -- LogYqh("PlayEnterAnim",args)
    local currentIndex = args and args.currentIndex or 0

    --要先跳转到正确位置
    self.loopScrollView:ScrollToItem(currentIndex+1,function ()

        --收集需要播放动效的Item
        self.tbToPlayAnimItem = {}
        self.loopScrollView:RangeRenderItem(function (itemData)
            local item = itemData.obj
            if math.abs(item.index - currentIndex) <= 2 then
                item:BeforePlayEnterAnim()
                table.insert(self.tbToPlayAnimItem,item)
            end
        end,false)

        table.sort(self.tbToPlayAnimItem,function (a,b)
            return a.index < b.index
        end)

        -- 一边滚动一边播动效
        self:TryPlayNextItemEnterAnim(args)
        local moveSpeed = 0.6
        self.loopScrollView:ScrollToItem(currentIndex,function ()
            self.targetPos = self.loopScrollView.content.localPosition
        end,moveSpeed,nil,LoopScrollViewDefine.JumpType.Center)

    end,0.02,nil,LoopScrollViewDefine.JumpType.Center)
end

function RankWindow:TryPlayNextItemEnterAnim(args)
    -- LogYqh("TryPlayNextItemEnterAnim #self.tbToPlayAnimItem=",#self.tbToPlayAnimItem,"args",args)
    self:RemoveAnimTimer()
    if #self.tbToPlayAnimItem > 0 then
        local last = table.remove(self.tbToPlayAnimItem)
        last:PlayEnterAnim(args)
        self.animTimer = TimerManager.Instance:AddTimer(1,0.25,function ()
            self:TryPlayNextItemEnterAnim(args)
        end)
    else
        self:OnPlayEnterAnimFinish(args)
    end
end

function RankWindow:OnPlayEnterAnimFinish(args)
    self.loopScrollView:EnableScroll(true)
    if args then
        self.currentIndex = args.currentIndex or 1
    end
    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_open, "division")
    mod.RemindCtrl:SetRemind(RemindDefine.RemindId.division_up,false)
end

function RankWindow:RemoveAnimTimer()
    if self.animTimer then
        TimerManager.Instance:RemoveTimer(self.animTimer)
        self.animTimer = nil
    end
end

function RankWindow:CloseAllRankCursorView()
    self.loopScrollView:RangeRenderItem(function (itemData)
        local item = itemData.obj
        item:CloseAllView()
    end,false)
end

function RankWindow:RefreshRankStyle()
    self:FixAllItemProgressbar()
end

function RankWindow:ShowHeroDetailsPanel(unitId)
    if self.battleHeroDetailsPanel == nil then
        self.battleHeroDetailsPanel = BattleHeroDetailsPanel.New()
        self.battleHeroDetailsPanel:SetParent(UIDefine.canvasRoot)
    end
    self.battleHeroDetailsPanel:SetMainData(unitId,1,1)
    self.battleHeroDetailsPanel:Show()
end