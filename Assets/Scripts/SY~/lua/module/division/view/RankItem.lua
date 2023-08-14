RankItem = BaseClass("RankItem", BaseView)
RankItem.SINGLE_UNLOCK_CARD_SHOW = 3 --一行最多显示多少个解锁卡牌

function RankItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
    self.data = nil
    self.tbHeroModel = {}
    self.tbRankCursor = {}
    self.tbPropItem = {}
    self.enterAnimArgs = nil
end

function RankItem:__CacheObject()
    --段位
    self.objRankInfo = self:Find("rank_info").gameObject
    self.canvasGroupRank = self:Find("rank_info",CanvasGroup)
    self.txtRankTitle = self:Find("rank_info/txt_rank_title",Text)
    self.txtRank = self:Find("rank_info/image_12/txt_rank",Text)
    self.txtRankNum = self:Find("rank_info/img_rank_icon/txt_rank_num",Text)
    -- self.txtRankName = self:Find("rank_info/image_12/txt_rank_name",Text)
    self.btnRankInfo = self:Find("rank_info/image_12/btn_info",Button)
    self.imgRankIcon = self:Find("rank_info/img_rank_icon",Image)
    self.imgRankIcon1 = self:Find("rank_info/img_rank_icon_1",Image)
    self.rectRankBG = self:Find("rank_info/img_rank_bg",RectTransform)
    self.transLinePos = self:Find("rank_info/line_pos")
    self.canvasGroupTitle = self:Find("rank_info/image_12",CanvasGroup)

    --解锁
    self.objUnlockInfo = self:Find("unlock_info").gameObject
    self.canvasGroupUnlock = self:Find("unlock_info",CanvasGroup)
    self.imgUnlockSingle = self:Find("unlock_info/img_bg_single",Image)
    self.imgUnlockMulti = self:Find("unlock_info/img_bg_multi",Image)
    self.objUnlockSingle = self.imgUnlockSingle.gameObject
    self.objUnlockMulti = self.imgUnlockMulti.gameObject
    self.txtUnlockSingleTips = self:Find("unlock_info/img_bg_single/img_unlock_tips_single/txt_unlock_tips_single",Text)
    self.txtUnlockMultiTips = self:Find("unlock_info/img_bg_multi/img_unlock_tips_multi/txt_unlock_tips_multi",Text)
    self.rectSinglePivot = self:Find("unlock_info/img_bg_single/unlock_single_pivot",RectTransform)
    self.rectMultiPivot1 = self:Find("unlock_info/img_bg_multi/unlock_multi_pivot_1",RectTransform)
    self.rectMultiPivot2 = self:Find("unlock_info/img_bg_multi/unlock_multi_pivot_2",RectTransform)

    --奖励
    self.objRewardInfo = self:Find("reward_info").gameObject
    self.canvasGroupReward = self:Find("reward_info",CanvasGroup)
    self.objRecvImg = self:Find("reward_info/bg/img_recv_state").gameObject
    self.imgRewardBG = self:Find("reward_info/bg",Image)
    self.btnReward = self:Find("reward_info/bg/btn_reward",Button)
    self.rewardComps = {
        {
            rootObj = self:Find("reward_info/bg/reward_group_0").gameObject,
            imgIcon = self:Find("reward_info/bg/reward_group_0/img_currency_bg_0/img_currency_icon_0",Image),
            imgBigIcon = self:Find("reward_info/bg/reward_group_0/img_reward_icon_0",Image),
            txtNum = self:Find("reward_info/bg/reward_group_0/img_currency_bg_0/txt_currency_num_0",Text),
            btn = self:Find("reward_info/bg/reward_group_0/btn_reward_0",Button),
            rootCurrency = self:Find("reward_info/bg/reward_group_0/img_currency_bg_0").gameObject,
            canvas = self:Find("reward_info/bg/reward_group_0",Canvas)
        },
        {
            rootObj = self:Find("reward_info/bg/reward_group_1").gameObject,
            imgIcon = self:Find("reward_info/bg/reward_group_1/img_currency_bg_1/img_currency_icon_1",Image),
            imgBigIcon = self:Find("reward_info/bg/reward_group_1/img_reward_icon_1",Image),
            txtNum = self:Find("reward_info/bg/reward_group_1/img_currency_bg_1/txt_currency_num_1",Text),
            btn = self:Find("reward_info/bg/reward_group_1/btn_reward_1",Button),
            rootCurrency = self:Find("reward_info/bg/reward_group_1/img_currency_bg_1").gameObject,
            canvas = self:Find("reward_info/bg/reward_group_1",Canvas)
        }
    }

    --进度条
    self.objProgressbar = self:Find("progress_info").gameObject
    self.rectProgressbar = self:Find("progress_info",RectTransform)
    self.imgProgressFill = self:Find("progress_info/img_progress_grey/img_progress_fill",Image)
    self.imgProgressGrey = self:Find("progress_info/img_progress_grey",Image)
    self.imgDotGrey = self:Find("progress_info/img_progress_dot_grey",Image)
    self.imgDotFill = self:Find("progress_info/img_progress_dot_grey/img_progress_dot_fill",Image)
    self.objDotGrey = self.imgDotGrey.gameObject
    self.objDotFill = self.imgDotFill.gameObject
    self.objProgressTxt = self:Find("progress_info/txt_progress").gameObject
    self.txtProgress = self:Find("progress_info/txt_progress",Text)

    --游标
    self.canvasRankCursor = self:Find("progress_info/rank_cursor/canvas",Canvas)
    self.rectCursor = self:Find("progress_info/cursor",RectTransform)
    self.rectRankCursor = self:Find("progress_info/rank_cursor",RectTransform)
    self.transRankCursorParent = self.rectRankCursor.parent
    self.objRankCursor = self.rectRankCursor.gameObject
    self.objRankCursor:SetActive(false)
end

function RankItem:__Create()
    self.txtUnlockSingleTips.text = TI18N("解锁以上卡牌")
    self.txtUnlockMultiTips.text = TI18N("解锁以上卡牌")
    self.roleData = mod.RoleProxy:GetRoleData()
    self:AddAnimEffectListener("rank_info_refresh",self:ToFunc("OnAnimEffectPlay"))
end

function RankItem:__BindListener()
    self.btnRankInfo:SetClick(self:ToFunc("OnRankInfoButtonClick"))
    self.btnReward:SetClick(self:ToFunc("OnRewardButtonClick"),0)
    for i, comp in ipairs(self.rewardComps) do
        comp.btn:SetClick(self:ToFunc("OnRewardButtonClick"),i)
    end
end

--[[
    self.data = {
        divisionInfo = {
            remark,trophy,unlock_list
        }
        trophyReward = {
            id,trophy,item_list
        }
        isDivisionReward : boolean | nil
        belongDivision : interger | nil
    }
]]--
function RankItem:SetData(data, index, parentWindow)
    self.data = data
    self.index = index
    self.isDivision = not TableUtils.IsEmpty(self.data.divisionInfo)
    self.isDivisionReward = self.data.isDivisionReward
    self.existUnlockList = self.isDivision and not TableUtils.IsEmpty(self.data.divisionInfo.unlock_list)
    self.realData = self.data.divisionInfo or self.data.trophyReward
    self.rootCanvas = parentWindow.rootCanvas
    self.rootContent = parentWindow.loopScrollView.content
    self.canvasRankCursor.sortingOrder = self.rootCanvas.sortingOrder + 3
    self.fixRankCursor = true
    self:RefreshStyle()
end

function RankItem:OnReset()
    self.data = nil
end

function RankItem:SetSpriteByItemID(img, itemId, isBig, rewardState, canvas, index)
    if isBig then
        self:RecyclePropItem(index)
        if itemId == GDefine.ItemId.Diamond then --宝石
            local effId = AssetPath.DivisionEffectID[AssetPath.DivisionEffectType.Diamond]
            if rewardState == DivisionDefine.RewardStatus.Unclaimed then
                img.enabled = false
                self:LoadEffect(effId,img.transform,0,40)
            else
                img.enabled = true
                self:SetSprite(img, AssetPath.GetItemIcon(900001), true)
                -- self:RecycleEffect(effId)
            end
        elseif itemId == GDefine.ItemId.Gold then --金币
            local effId = AssetPath.DivisionEffectID[AssetPath.DivisionEffectType.Gold]
            if rewardState == DivisionDefine.RewardStatus.Unclaimed then
                img.enabled = false
                self:LoadEffect(effId,img.transform,0,40)
            else
                img.enabled = true
                self:SetSprite(img, AssetPath.GetItemIcon(900002), true)
                -- self:RecycleEffect(effId)
            end
        else
            local itemData = Config.ItemData.data_item_info[itemId]
            if itemData then
                if itemData.type == GDefine.ItemType.unitCard then
                    img.enabled = false
                    self:CreatePropItem(index,itemId,canvas.transform)
                else
                    img.enabled = true
                    self:SetSprite(img, AssetPath.GetItemIcon(itemData.icon), true)
                end
            end
            if rewardState == DivisionDefine.RewardStatus.Unclaimed then
                self:LoadEffect(AssetPath.DivisionEffectID[AssetPath.DivisionEffectType.Shine],canvas.transform,-93,120)
                self:LoadEffect(AssetPath.DivisionEffectID[AssetPath.DivisionEffectType.Arrow],canvas.transform,-80,220)
            else
                -- self:RecycleEffect(AssetPath.DivisionEffectID[AssetPath.DivisionEffectType.Shine])
                -- self:RecycleEffect(AssetPath.DivisionEffectID[AssetPath.DivisionEffectType.Arrow])
            end
        end
    else
        self:SetSprite(img,AssetPath.GetCurrencyIconByItemId(itemId))
    end
end

function RankItem:CreatePropItem(index,itemId,parent)
    self:RecyclePropItem(index)
    local itemData = {}
    itemData.item_id = itemId
    local propItem = PropItem.Create()
    propItem:SetParent(parent)
    propItem.transform:Reset()
    propItem:Show()
    propItem:SetData(itemData)
    UnityUtils.SetAnchorMinAndMax(propItem.transform,0.5,0.5,0.5,0.5)
    UnityUtils.SetPivot(propItem.transform,0.5,0.5)
    UnityUtils.SetAnchoredPosition(propItem.transform, -6, 120)
    propItem.rectTrans:SetSiblingIndex(0)
    propItem:EnableTips(false)
    self.tbPropItem[index] = propItem
    return propItem
end

function RankItem:RecyclePropItem(index)
    local item = self.tbPropItem[index]
    if item then
        item:Destroy()
        self.tbPropItem[index] = nil
    end
end

function RankItem:RecycleAllPropItem()
    for index, item in pairs(self.tbPropItem or {}) do
        item:Destroy()
    end
    self.tbPropItem = {}
end

function RankItem:CalcProgress(nextItem,trophy)
    local progress = 0
    local current = self:GetCurrentTrophy()
    local next = nextItem and nextItem:GetCurrentTrophy()
    local active = false
    if next then
        active = trophy <= current and trophy > next
        if current ~= next and trophy > next then
            progress = (trophy - next) / (current - next)
        end
    else
        active = not self.isDivisionReward and trophy == current
    end
    return progress,active
end

function RankItem:TryShowRankCursor(nextItem, rankMap)
    if not self.fixRankCursor then
        return
    end
    local index = 0
    for baseTrophy, rankInfos in pairs(rankMap or {}) do
        local progress,active = self:CalcProgress(nextItem, baseTrophy)
        if active then
            local item = RankCursorItem.Create(self.objRankCursor)
            item.transform:SetParent(self.transRankCursorParent,false)
            item.transform:Reset()
            index = index + 1
            item:SetData(rankInfos, index)
            table.insert(self.tbRankCursor,item)
            --根据比例和进度点位置计算游标位置
            local length = self.rectProgressbar.sizeDelta.y
            local realLength = length * progress
            item:SetPos(self.rectRankCursor.anchoredPosition.x, realLength)
            item.transform:SetParent(self.rootContent,true)
        end
    end
    if nextItem then
        self.fixRankCursor = false
    end
end

function RankItem:RemoveRankCursors()
    for _, item in ipairs(self.tbRankCursor) do
        item:OnRecycle()
        item:Destroy()
    end
    self.tbRankCursor = {}
    self.fixRankCursor = true
end

function RankItem:CloseAllView()
    for _, item in ipairs(self.tbRankCursor) do
        item:CloseAllView()
    end
end

function RankItem:TryShowCursorAndProgress(nextItem, cursor)
    local progress,active = self:CalcProgress(nextItem, self.roleData.trophy)
    local realLength = 0
    if active then
        --根据比例和进度点位置计算游标位置
        local length = self.rectProgressbar.sizeDelta.y
        realLength = length * progress
    end
    local origin = self.rectCursor.anchoredPosition
    UnityUtils.SetAnchoredPosition(self.rectCursor, origin.x, realLength)
    local fixCursor = true
    if active and cursor then
        local originParent = cursor.parent
        cursor:SetParent(self.rectCursor)
        cursor:Reset()
        cursor:SetParent(originParent,true)
        fixCursor = false
    end
    self.imgProgressFill.fillAmount = progress
    return fixCursor
end

function RankItem:GetCurrentTrophy()
    if self.isDivision then
        return self.realData.trophy
    end
    return self.realData.trophy
end

function RankItem:RefreshObjActive()
    local reach = self:GetCurrentTrophy() <= self.roleData.trophy
    if self.isDivision then
        self.objRankInfo:SetActive(true)
        if self.existUnlockList then
            self.objUnlockInfo:SetActive(true)
        else
            self.objUnlockInfo:SetActive(false)
        end
        self.objRewardInfo:SetActive(false)
        self.objDotGrey:SetActive(true)
        self.objDotFill:SetActive(reach)
        self.objProgressbar:SetActive(true)
        self.objProgressTxt:SetActive(true)
    else
        self.objRewardInfo:SetActive(true)
        self.objRankInfo:SetActive(false)
        self.objUnlockInfo:SetActive(false)
        if self.isDivisionReward then
            --段位奖励，隐藏进度点/进度值/进度条
            self.objDotGrey:SetActive(false)
            self.objProgressbar:SetActive(false)
            self.objProgressTxt:SetActive(false)
        else
            self.objDotGrey:SetActive(true)
            self.objDotFill:SetActive(reach)
            self.objProgressbar:SetActive(true)
            self.objProgressTxt:SetActive(true)
        end
    end
end

--宝箱不显示数量
function RankItem:TryShowCurrencyInfo(root,itemId)
    local show = true
    -- local config = Config.ItemData.data_item_info[itemId]
    -- if config and config.type == GDefine.ItemType.chest then
    --     show = false
    -- end
    root:SetActive(show)
end

function RankItem:RefreshRewardStyle()
    local rewardState = mod.DivisionProxy:GetTrophyRewardState(self.realData.id)
    for i, comp in ipairs(self.rewardComps) do
        local data = self.realData.item_list and self.realData.item_list[i]
        if data then
            comp.rootObj:SetActive(true)
            -- self:SetSpriteByItemID(comp.imgIcon, data[1], false, rewardState, comp.canvas)
            self:SetSpriteByItemID(comp.imgBigIcon, data[1], true, rewardState, comp.canvas, i)
            self:TryShowCurrencyInfo(comp.rootCurrency, data[1])
            comp.txtNum.text = data[2]
            comp.canvas.sortingOrder = self.rootCanvas.sortingOrder + 2
        else
            comp.rootObj:SetActive(false)
        end
    end
    if rewardState == DivisionDefine.RewardStatus.Unclaimed then --可领
        self.objRecvImg:SetActive(false)
        self:SetGrey(false)
        self:LoadEffect(AssetPath.DivisionEffectID[AssetPath.DivisionEffectType.Outline],self.imgRewardBG.transform)
    elseif rewardState == DivisionDefine.RewardStatus.Receive then --已领
        self.objRecvImg:SetActive(true)
        self:SetGrey(false)
        -- self:RecycleEffect(AssetPath.DivisionEffectID[AssetPath.DivisionEffectType.Outline])
        self:RemoveAllEffect()
    else -- rewardState == DivisionDefine.RewardStatus.Lock 未解锁
        self.objRecvImg:SetActive(false)
        self:SetGrey(true)
        -- self:RecycleEffect(AssetPath.DivisionEffectID[AssetPath.DivisionEffectType.Outline])
        self:RemoveAllEffect()
    end
end

function RankItem:RefreshDivisionStyle()
    local trophy = self:GetCurrentTrophy()
    self.txtRankTitle.text = self.realData.remark
    -- self.txtRankName.text = self.realData.remark
    self.txtRank.text = trophy
    local icon = AssetPath.GetDivisionIconPath(self.realData.icon)
    self:SetSprite(self.imgRankIcon1, icon, true)
    self:SetSprite(self.imgRankIcon, icon, true)
    self:ClearAllHeroModel()
    local total = #self.realData.unlock_list
    for i, heroId in pairs(self.realData.unlock_list or {}) do
        self:LoadHeroModel(heroId, i, total)
    end
    local length = #self.realData.unlock_list
    local isSingle = length <= RankItem.SINGLE_UNLOCK_CARD_SHOW
    self.objUnlockSingle:SetActive(isSingle)
    self.objUnlockMulti:SetActive(not isSingle)
    if trophy > self.roleData.trophy then --未解锁
        self:SetGrey(true)
        local size = self:GetRealSize()
        local originW = self.rectRankBG.rect.width
        UnityUtils.SetSizeDelata(self.rectRankBG, originW, size.h + 80)
    else        --已解锁
        self:SetGrey(false)
    end
    self:LoadEffect(AssetPath.DivisionEffectID[AssetPath.DivisionEffectType.Line],self.transLinePos,-45,nil,0)
end

function RankItem:RefreshStyle()
    self:RefreshObjActive()
    if self.isDivision then
        self:RefreshDivisionStyle()
    else
        self:RefreshRewardStyle()
    end
    local trophy = self:GetCurrentTrophy()
    self.txtProgress.text = trophy
    self:FixProgressbarPos()
end

function RankItem:SetCompGrey(comp,grey)
    local r,g,b,a = comp.color:Get()
    local color
    if grey then
        color = Color(0.6,0.6,0.6,a)
    else
        color = Color(1,1,1,a)
    end
    comp.color = color
end

function RankItem:SetGrey(grey)
    -- self:SetCompGrey(self.imgUnlockMulti, grey)
    -- self:SetCompGrey(self.imgUnlockSingle, grey)
    -- self:SetCompGrey(self.imgRewardBG, grey)
    -- for _, comp in ipairs(self.rewardComps) do
    --     self:SetCompGrey(comp.imgIcon, grey)
    --     self:SetCompGrey(comp.imgBigIcon, grey)
    --     self:SetCompGrey(comp.txtNum, grey)
    -- end
    -- self:SetCompGrey(self.imgRankIcon, grey)
    local renders = self.gameObject:GetComponentsInChildren(Graphic, true)
    for i = 0, renders.Length - 1 do
        self:SetCompGrey(renders[i], grey)
    end
end

function RankItem:GetCurrentInfoType()
    return RankItem.GetInfoType(self.data.divisionInfo,self.data.trophyReward)
end

function RankItem:GetCurrentInfoTypeConfig()
    return DivisionDefine.InfoConfig[self:GetCurrentInfoType()]
end

function RankItem:GetRealSize()
    local config = self:GetCurrentInfoTypeConfig()
    local w,h = config.width,config.height
    if self.isDivision then
        local rewardConfig = DivisionDefine.InfoConfig[DivisionDefine.InfoType.RewardInfo]
        if mod.DivisionProxy:ContainAward(self.realData.division) then
            w=config.width
            h=config.height+rewardConfig.height
        end
    end
    return {w=w,h=h}
end

function RankItem:GetProgressbarPos()
    return self.rectProgressbar.anchoredPosition
end

function RankItem:SetProgressbarLength(length)
    local origin = self.rectProgressbar.sizeDelta
    UnityUtils.SetSizeDelata(self.rectProgressbar, origin.x, length)
end

function RankItem:FixProgressbarPos()
    local config = self:GetCurrentInfoTypeConfig()
    local x,y = config.centerX,config.centerY
    UnityUtils.SetAnchoredPosition(self.rectProgressbar, x, y)
end

function RankItem:FixProgressbarLengthByNextItem(curHolderRect,nextHolderRect,nextItem)
    local y1 = curHolderRect.anchoredPosition.y
    local y2 = nextHolderRect.anchoredPosition.y
    local config1 = self:GetCurrentInfoTypeConfig()
    local config2 = nextItem:GetCurrentInfoTypeConfig()
    y1 = y1 + config1.centerY
    y2 = y2 + config2.centerY
    self:SetProgressbarLength(math.abs(y1-y2))
end

function RankItem:OnRankInfoButtonClick()
    print("点击了段位信息按钮")
end

function RankItem:OnRewardButtonClick(index)
    local trophyRewardId = self.realData.id
    local requiredNum = self.realData.trophy
    local belongDivision = self.data.belongDivision

    if not trophyRewardId then return end

    local status = mod.DivisionProxy:GetTrophyRewardState(trophyRewardId)

    --可领
    if status == DivisionDefine.RewardStatus.Unclaimed then
        mod.DivisionFacade:SendMsg(10601,trophyRewardId)
    else
        --点击左右小按钮
        if index > 0 then
            --未解锁或者已领
            local rewardInfo = self.data.trophyReward
            local rewardLen = #rewardInfo.item_list
            index = MathUtils.Clamp(index, 0, rewardLen)
            local itemInfo = rewardInfo.item_list[index]
            self:ShowPreviewWindow(itemInfo[1],index)
        else
        --点击大按钮
            --未解锁
            if status == DivisionDefine.RewardStatus.Lock then
                if self.roleData.division < belongDivision then
                    local divisionName = Config.DivisionData.data_division_info[belongDivision].remark
                    SystemMessage.Show(TI18N(string.format("段位达到%s开放",divisionName)))
                elseif self.roleData.trophy < requiredNum then
                    SystemMessage.Show(TI18N(string.format("奖杯数达到%s可领取",requiredNum)))
                end
            end
        end
    end
end

function RankItem:ShowPreviewWindow(itemId,index)
    local parent = self.rewardComps[index].btn.transform
    mod.TipsCtrl:OpenTipsByItemId(itemId,parent)
end

function RankItem:OnClearData()
    self:RemoveRankCursors()
    self:ClearAllHeroModel()
    self:RemoveAllEffect()
    self:RecycleAllPropItem()
    self.enterAnimArgs = nil
end

function RankItem:OnRecycle()
    self:OnClearData()
end

function RankItem:__Delete()
    self:OnClearData()
end

function RankItem:GetModelHoldPos(index,total)
    local w = 150
    local y = 0
    local z = -100
    local max = RankItem.SINGLE_UNLOCK_CARD_SHOW
    local row = math.ceil(index / max)
    local col = (index - 1) % max + 1
    local midIndex
    local holder
    if total <= max then
        holder = self.rectSinglePivot
        midIndex = (total-1) / 2
    else
        if index > max then
            holder = self.rectMultiPivot2
        else
            holder = self.rectMultiPivot1
        end
        midIndex = (max-1) / 2
    end
    local x = ((col-1) - midIndex) * w
    return Vector3(x,y,z), holder
end

function RankItem:CreateHeroModel(heroId)
    do
        return HeroTpose.New(), true --TODO
    end
    local key = RankItem.GetHeroTposeKey(heroId)
    local poolExistNum = PoolManager.Instance.poolDict[PoolType.hero_tpose]:ExistNum(key)
    local isNew = false
    local tpose
    if poolExistNum > 0 then
        tpose = PoolManager.Instance:Pop(PoolType.hero_tpose,key)
    else
        tpose = HeroTpose.New()
        isNew = true
    end
    return tpose, isNew
end

function RankItem:LoadHeroModel(heroId,index,total)
    local unitData = ConfigUtil.GetUnitDataByItemId(heroId)
    assert(unitData, string.format("无法找到UnitData[%s]",tostring(heroId)))
    local tpose,isNew = self:CreateHeroModel(heroId)
    local setting = {}
    setting.modelId = unitData.model_id
    setting.animId = unitData.anim_id
    setting.skinId = unitData.skin_id
    setting.args = {tpose=tpose, heroId=heroId, index=index, total=total, isNew=isNew}
    tpose:Load(setting, self:ToFunc("OnHeroModelLoaded"))
    return tpose
end

function RankItem:OnHeroModelLoaded(args)
    local tpose, heroId, index, total, isNew = args.tpose, args.heroId, args.index, args.total, args.isNew
    local pos,parent = self:GetModelHoldPos(index,total)
    tpose.transform:SetParent(parent)
    tpose.transform.localPosition = pos
    tpose.transform:SetLocalEulerAngles(0,180,0)
    BaseUtils.ChangeLayers(tpose.gameObject,GDefine.Layer.ui)
    if isNew then
        local key = RankItem.GetHeroTposeKey(heroId)
        if not self.tbHeroModel[key] then
            self.tbHeroModel[key] = {}
        end
        table.insert(self.tbHeroModel[key], tpose)
    end
end

function RankItem:ClearAllHeroModel()
    for key, list in pairs(self.tbHeroModel or {}) do
        for _, tpose in pairs(list or {}) do
            -- PoolManager.Instance:Push(PoolType.hero_tpose,key,tpose) --TODO
            tpose:Delete()
        end
    end
    self.tbHeroModel = {}
end

function RankItem:LoadEffect(effectId,parent,x,y,offsetOrder)
    local order = self.rootCanvas.sortingOrder + (offsetOrder or 1)
    self:LoadUIEffect({
        confId = effectId,
        parent = parent,
        order = order,
        onComplete = self:ToFunc("PlayAnimFinish"),
        pos = {x=x,y=y},
    },true)
end

function RankItem:RecycleEffect(effectId)
end

function RankItem:BeforePlayEnterAnim()
    -- self:PlayAnim("canvas_group_0")
    self.objRankInfo:SetActive(false)
    self.objRewardInfo:SetActive(false)
    self.objUnlockInfo:SetActive(false)
end

function RankItem:PlayEnterAnim(args)
    self.enterAnimArgs = args
    local tpe = self:GetCurrentInfoType()
    if tpe == DivisionDefine.InfoType.RankInfo then
        self:PlayRankInfoAnim()
    elseif tpe == DivisionDefine.InfoType.RewardInfo then
        self.objRewardInfo:SetActive(true)
        self:PlayAnim("reward_info")
    elseif tpe == DivisionDefine.InfoType.UnlockInfo then
        self.objUnlockInfo:SetActive(true)
        self:PlayAnim("unlock_info_bg_single")
        self:AddTimer("rank_item_enter_anim",1,0.3,self:ToFunc("PlayRankInfoAnim"))
    elseif tpe == DivisionDefine.InfoType.UnlockInfoMulti then
        self.objUnlockInfo:SetActive(true)
        self:PlayAnim("unlock_info_bg_multi")
        self:AddTimer("rank_item_enter_anim",1,0.3,self:ToFunc("PlayRankInfoAnim"))
    end
end

function RankItem:PlayRankInfoAnim()
    self.objRankInfo:SetActive(true)
    local args = self.enterAnimArgs
    if args and args.type == RankWindow.JumpType.LvUp then
        self:SetCompGrey(self.imgRankIcon1,true)
        self:PlayAnim("rank_info_refresh")
    else
        self:PlayAnim("rank_info")
    end
end

function RankItem:OnAnimEffectPlay(name,data)
    self:LoadUIEffectByAnimData(data,true)
end

--#region 静态方法

function RankItem.GetInfoType(divisionInfo,trophyReward)
    local tpe = DivisionDefine.InfoType.RankInfo
    if not TableUtils.IsEmpty(divisionInfo) then
        if not TableUtils.IsEmpty(divisionInfo.unlock_list) then
            tpe = DivisionDefine.InfoType.UnlockInfo
            local len = #divisionInfo.unlock_list
            if len > RankItem.SINGLE_UNLOCK_CARD_SHOW then
                tpe = DivisionDefine.InfoType.UnlockInfoMulti
            end
        end
    elseif not TableUtils.IsEmpty(trophyReward) then
        tpe = DivisionDefine.InfoType.RewardInfo
    end
    return tpe
end

function RankItem.Create(template)
    local rankItem = RankItem.New()
    rankItem:SetObject(GameObject.Instantiate(template))
    rankItem:Show()
    return rankItem
end

function RankItem.CalcSize(divisionInfo,trophyReward)
    local tpe = RankItem.GetInfoType(divisionInfo,trophyReward)
    return {w=DivisionDefine.InfoConfig[tpe].width,h=DivisionDefine.InfoConfig[tpe].height}
end

function RankItem.CalcCursorPosY(trophy,paddingTop,gapY,viewportHeight)
    local y = 0
    local showList = mod.DivisionProxy:GetShowList()
    local lastCenter
    local lastY
    local lastTro
    local offset = 0
    local lastH = 0

    for i, data in ipairs(showList or {}) do
        local tpe = RankItem.GetInfoType(data.divisionInfo, data.trophyReward)
        local config = DivisionDefine.InfoConfig[tpe]
        local tro = data.divisionInfo and data.divisionInfo.trophy or
            (data.trophyReward and data.trophyReward.trophy)
        assert(tro,"数据异常")
        y = y + config.height
        if tro <= trophy and not data.isDivisionReward then
            if lastCenter then
                local progress = (trophy - tro) / (lastTro - tro)
                local length = (y + config.centerY) - (lastY + lastCenter)
                offset = progress * length
            end
            break
        end
        y = y + gapY
        lastCenter = config.centerY
        lastY = y
        lastTro = tro
        lastH = config.height --TODO 这里要考虑段位包含奖励的情况
    end
    local v = paddingTop + y - lastH - offset - viewportHeight / 2
    return v
end

function RankItem.GetHeroTposeKey(heroId)
    local unitData = ConfigUtil.GetUnitDataByItemId(heroId)
    assert(unitData, string.format("无法找到UnitData[%s]",tostring(heroId)))
    return string.format("%s_%s_%s",unitData.model_id,unitData.skin_id,unitData.anim_id)
end

--#endregion