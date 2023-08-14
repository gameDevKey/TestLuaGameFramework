DrawCardWindow = BaseClass("DrawCardWindow",BaseWindow)

--消耗优先级
DrawCardWindow.CostPriority = {
    [GDefine.ItemId.DrawCardTicket] = 3,
    [GDefine.ItemId.Diamond] = 2,
    [GDefine.ItemId.Gold] = 1,
}

DrawCardWindow.Event = EventEnum.New(
    "RefreshDrawButtonStyle",
    "RefreshProgressStyle",
    "OnDrawCardButtonClick"
)

function DrawCardWindow:__Init()
    self:SetAsset("ui/prefab/draw_card/draw_card_window.prefab",AssetType.Prefab)
    self.tbChestItem = {}
    self.tbCurrencyItem = {}
end

function DrawCardWindow:__Delete()
end

function DrawCardWindow:__CacheObject()
    self.objMain = self:Find("main").gameObject
    self.imgProgress = self:Find("main/img_pgr/pgr_bg/pgr_fill",Image)
    self.txtProgress = self:Find("main/img_pgr/image_12/txt_progress",Text)
    self.txtPgrTips = self:Find("main/img_pgr/image_12/text_21",Text)

    self.btnInfos = {
        [GDefine.DrawCardType.Single] = {
            btn = self:Find("main/btn_single",Button),
            imgCost = self:Find("main/btn_single/img_cost/content/img_s_cost",Image),
            txtCost = self:Find("main/btn_single/img_cost/content/txt_s_cost",Text),
            objOr = self:Find("main/btn_single/img_cost/content/txt_or").gameObject,
            imgCost2 = self:Find("main/btn_single/img_cost/content/img_s_cost2",Image),
            txtCost2 = self:Find("main/btn_single/img_cost/content/txt_s_cost2",Text),
            txtTips = self:Find("main/btn_single/txt_single",Text),
            objReddot = self:Find("main/btn_single/img_s_reddot").gameObject,
        },
        [GDefine.DrawCardType.Multi] = {
            btn = self:Find("main/btn_multi",Button),
            imgCost = self:Find("main/btn_multi/img_cost/content/img_s_cost",Image),
            txtCost = self:Find("main/btn_multi/img_cost/content/txt_s_cost",Text),
            objOr = self:Find("main/btn_multi/img_cost/content/txt_or").gameObject,
            imgCost2 = self:Find("main/btn_multi/img_cost/content/img_s_cost2",Image),
            txtCost2 = self:Find("main/btn_multi/img_cost/content/txt_s_cost2",Text),
            txtTips = self:Find("main/btn_multi/txt_multi",Text),
            objReddot = self:Find("main/btn_multi/img_m_reddot").gameObject,
        },
    }

    self.rectChestParent = self:Find("main/img_pgr/acc_content",RectTransform)
    self.templateChest = self:Find("main/img_pgr/acc_content/draw_card_acc_item").gameObject
    self.templateChest:SetActive(false)

    self.btnBack = self:Find("main/btn_back",Button)

    self.canvasChest = self:Find("main/image_1/chest_canvas",Canvas)

    self.canvasCurrency = self:Find("canvas_currency",Canvas)
    self.templateCurrency = self:Find("canvas_currency/content/currency_item").gameObject
    self.templateCurrency:SetActive(false)
end

function DrawCardWindow:__Create()
end

function DrawCardWindow:__BindListener()
    for poolId, cmp in pairs(self.btnInfos) do
        cmp.btn:SetClick(self:ToFunc("OnDrawCardButtonClick"),poolId)
    end
    self.btnBack:SetClick(self:ToFunc("OnBackButtonClick"))
    self:AddAnimEffectListener("draw_card_window",self:ToFunc("OnAnimEffectPlay"))
end

function DrawCardWindow:__BindEvent()
    self:BindEvent(DrawCardWindow.Event.RefreshDrawButtonStyle)
    self:BindEvent(DrawCardWindow.Event.RefreshProgressStyle)
    self:BindEvent(DrawCardWindow.Event.OnDrawCardButtonClick)
    EventManager.Instance:AddEvent(EventDefine.refresh_role_item, self:ToFunc("OnRoleItemRefresh"))
end

function DrawCardWindow:OnRoleItemRefresh(changeList)
    local refresh = false
    for poolId, data in pairs(self.tbCostData or {}) do
        if changeList[data.id]  then
            refresh = true
            break
        end
    end
    if refresh then
        self:RefreshStyle()
    end
end

--获取卡池对应的消耗列表
--优先显示抽卡券(召唤道具)
function DrawCardWindow:GetConsumeList(poolId)
    local conf = Config.DrawCardData.data_card_pool[poolId]
    local consumes = {conf.consume_1,conf.consume_2}
    local result = nil
    local costData = {}
    for i, _list in ipairs(consumes) do
        local index = i
        for _, data in ipairs(_list) do
            local id = data[1]
            local num = data[2]
            local own = mod.RoleItemProxy:GetItemNum(id)
            if not result then
                result = {id=id,num=num,own=own,index=index}
            end
            if own > 0 then
                local p1 = DrawCardWindow.CostPriority[id]
                local p2 = DrawCardWindow.CostPriority[result.id]
                if p1 > p2 then
                    result = {id=id,num=num,own=own,index=index}
                end
            end
            table.insert(costData, {id=id,num=num,own=own,index=index})
        end
    end
    table.sort(costData,function (a,b)
        return DrawCardWindow.CostPriority[a.id] > DrawCardWindow.CostPriority[b.id]
    end)
    return result,costData
end

function DrawCardWindow:__Show()
    self.canvasChest.sortingOrder = self.rootCanvas.sortingOrder + GDefine.EffectOrderAdd
    self.canvasCurrency.sortingOrder = self.rootCanvas.sortingOrder + GDefine.EffectOrderAdd
    self.tbCostData = {}
    self.tbAllCostData = {}
    self:SetCurrencyShowList({GDefine.ItemId.Diamond,GDefine.ItemId.DrawCardTicket})
    self:CreateCurrencyItems()
    self:RefreshStyle()
end

function DrawCardWindow:__Hide()
    self:RemoveAccDrawChests()
end

function DrawCardWindow:RefreshStyle()
    self:RefreshProgressStyle()
    for poolId, cmp in pairs(self.btnInfos) do
        self:RefreshDrawButtonStyle(poolId, cmp.imgCost, cmp.txtCost, cmp.objReddot, cmp.objOr, cmp.imgCost2, cmp.txtCost2)
    end
    self:RefreshAllCurrency()
end

function DrawCardWindow:RefreshProgressStyle()
    local accDrawId = mod.DrawCardProxy:GetAccDrawId(GDefine.DrawCardType.Single) --TODO 直接用单抽对应的那个，后面单抽和十连不是同个卡池再改
    local state = mod.DrawCardProxy.accRewardState[accDrawId]
    local rewardValue = state and state.value or 0
    local maxValue = self:LoadAccDrawChests(accDrawId,self.rectChestParent)
    local percent = rewardValue / maxValue
    self.imgProgress.fillAmount = percent
    self.txtProgress.text = string.format("%d/%d",rewardValue,maxValue)
end

function DrawCardWindow:LoadAccDrawChests(accDrawId, parentRect)
    self:RemoveAccDrawChests()
    local maxNeed = 0
    local grades = Config.DrawCardData.data_acc_draw_grades[accDrawId]
    for i, grade in ipairs(grades) do
        local gradeConf = Config.DrawCardData.data_acc_draw[accDrawId .. "_" .. grade]
        local item = DrawCardAccChestItem.Create(self.templateChest)
        item:SetData(gradeConf, i)
        item.transform:SetParent(parentRect)
        item.transform.localScale = Vector3.one
        table.insert(self.tbChestItem, item)
        if maxNeed < gradeConf.need_count then
            maxNeed = gradeConf.need_count
        end
    end
    local length = parentRect.rect.width
    for _, item in ipairs(self.tbChestItem) do
        local percent = 1
        if maxNeed > 0 then
            percent = item.data.need_count / maxNeed
        end
        UnityUtils.SetAnchoredPosition(item.rectTrans,percent * length, 0)
    end
    return maxNeed
end

function DrawCardWindow:RemoveAccDrawChests()
    for _, item in ipairs(self.tbChestItem) do
        item:OnRecycle()
        item:Destroy()
    end
    self.tbChestItem = {}
end

function DrawCardWindow:RefreshDrawButtonStyle(poolId, img, txt, reddot, objOr, img2, txt2)
    local data,costs = self:GetConsumeList(poolId)
    self.tbCostData[poolId] = data
    self.tbAllCostData[poolId] = costs
    if data and costs then
        local satisfyCount = 0
        for _, ss in ipairs(costs) do
            if ss.own >= ss.num then
                satisfyCount = satisfyCount + 1
            end
        end
        local showReddot = false
        local showMultiCost = false
        if satisfyCount >= 2 then --多种支付方式都满足，只显示优先级最高的
            local itemId = data.id
            local num = data.num
            local icon = AssetPath.GetCurrencyIconByItemId(itemId)
            self:SetSprite(img, icon)
            local color = "FFFFFF"
            txt.text = string.format("<color=\"#%s\">%d</color>",color, num)
            showReddot = itemId == GDefine.ItemId.DrawCardTicket
        else                    --全部支付方式都显示
            for i, ss in ipairs(costs) do
                local itemId = ss.id
                local num = ss.num
                local owned = ss.own
                local icon = AssetPath.GetCurrencyIconByItemId(itemId)
                local _img = i == 1 and img or img2
                self:SetSprite(_img, icon)
                local color = owned < num and "FF0000" or "FFFFFF"
                local _txt = i == 1 and txt or txt2
                _txt.text = string.format("<color=\"#%s\">%d</color>",color, num)
                if not showReddot then
                    showReddot = itemId == GDefine.ItemId.DrawCardTicket and owned >= num
                end
            end
            showMultiCost = TableUtils.GetTableLength(costs) > 1
        end
        objOr:SetActive(showMultiCost)
        img2.gameObject:SetActive(showMultiCost)
        txt2.gameObject:SetActive(showMultiCost)
        if reddot then
            reddot:SetActive(showReddot)
        end
    else
        error(string.format("无法获得卡池[%s]所对应的消耗列表",poolId))
    end
end

function DrawCardWindow:OnDrawCardButtonClick(poolId)
    local datas = self.tbAllCostData[poolId]

    -- LogYqh("OnDrawCardButtonClick",poolId,datas)

    if TableUtils.GetTableLength(datas) > 1 then
        local first = datas[1]
        local second = datas[2]
        if first.id == GDefine.ItemId.DrawCardTicket then
            if first.own >= first.num  then
                mod.DrawCardFacade:SendMsg(11201, poolId, first.index)
                return
            end
            if second.own >= second.num then
                local data = {}
                data.content = "英魂币不足，是否消耗1800钻石招募？"
                data.notShowKey = "sell_equip"
                data.onConfirm = function ()
                    mod.DrawCardFacade:SendMsg(11201, poolId, second.index)
                end
                SystemDialog.Show(data)
            else
                SystemMessage.Show("钻石和英魂币不足！")
            end
        else
            LogErrorAny("购买逻辑未处理!",datas)
        end
    else
        local first = datas[1]
        if first.own >= first.num then
            mod.DrawCardFacade:SendMsg(11201, poolId, first.index)
        else
            SystemMessage.Show("钻石不足")
        end
    end
end

function DrawCardWindow:OnBackButtonClick()
    ViewManager.Instance:CloseWindow(DrawCardWindow)
end

function DrawCardWindow:OnCustomWindowClose()
    mod.DrawCardProxy:ClearSelectHeroData()
end

function DrawCardWindow:OnAnimEffectPlay(animName,data)
    self:LoadUIEffectByAnimData(data,true)
end

function DrawCardWindow:SetCurrencyShowList(items)
    self.currencyItems = items
end

function DrawCardWindow:CreateCurrencyItems()
    self:RecycleAllCurrencyItem()
    for _,id in ipairs(self.currencyItems or {}) do
        local obj = GameObject.Instantiate(self.templateCurrency)
        obj:SetActive(true)
        local img = obj.transform:Find("icon"):GetComponent(Image)
        local txt = obj.transform:Find("num"):GetComponent(Text)
        obj.transform:SetParent(self.templateCurrency.transform.parent)
        obj.transform:Reset()
        self.tbCurrencyItem[id] = {
            obj = obj,
            img = img,
            txt = txt,
        }
    end
end

function DrawCardWindow:RefreshAllCurrency()
    for id, item in pairs(self.tbCurrencyItem) do
        self:RefreshCurrencyItem(id)
    end
end

function DrawCardWindow:RefreshCurrencyItem(itemId)
    local item = self.tbCurrencyItem[itemId]
    if item then
        self:SetSprite(item.img, AssetPath.GetCurrencyIconByItemId(itemId))
        item.txt.text = mod.RoleItemProxy:GetItemNum(itemId)
    end
end

function DrawCardWindow:RecycleAllCurrencyItem()
    for id, item in pairs(self.tbCurrencyItem) do
        GameObject.Destroy(item.obj)
    end
    self.tbCurrencyItem = {}
end