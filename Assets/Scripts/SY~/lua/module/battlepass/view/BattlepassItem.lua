BattlepassItem = BaseClass("BattlepassItem", BaseView)
BattlepassItem.ColorReach = Color(154/255,102/255,31/255,255/255)
BattlepassItem.ColorUnReach = Color(78/255,102/255,150/255,255/255)

function BattlepassItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
    self:InitData()
end

function BattlepassItem:InitData()
    self.vipAwardState = GDefine.AwardState.Lock
    self.freeAwardState = GDefine.AwardState.Lock
    self.vipAwardInfo = {}
    self.freeAwardInfo = {}
    self.tbEffectUID = {}
end

function BattlepassItem:__CacheObject()
    self.canvasPgr = self:Find("canvas_pgr",Canvas)

    self.objBG = self:Find("img_bg").gameObject
    self.objLine = self:Find("img_line").gameObject
    
    self.objVip = self:Find("btn_vip_award").gameObject
    self.btnVip = self:Find("btn_vip_award",Button)
    self.imgVipIcon = self:Find("btn_vip_award/img_icon",Image)
    self.txtVipNum = self:Find("btn_vip_award/txt_num",Text)
    self.objVipRecv = self:Find("btn_vip_award/img_mask").gameObject
    self.objVipLock = self:Find("btn_vip_award/img_lock").gameObject

    self.objNormal = self:Find("btn_normal_award").gameObject
    self.btnNormal = self:Find("btn_normal_award",Button)
    self.imgNormalIcon = self:Find("btn_normal_award/img_icon",Image)
    self.txtNormalNum = self:Find("btn_normal_award/txt_num",Text)
    self.objNormalRecv = self:Find("btn_normal_award/img_mask").gameObject
    self.objNormalLock = self:Find("btn_normal_award/img_lock").gameObject

    self.objReach = self:Find("canvas_pgr/img_reach").gameObject
    self.txtLevel = self:Find("canvas_pgr/txt_level",Text)
    self.outlineLevel = self:Find("canvas_pgr/txt_level",Outline)

    self.imgPgrFill = self:Find("img_pgr/img_pgr_fill",Image)
    self.rectPgr = self:Find("img_pgr",RectTransform)
end

function BattlepassItem:__Create()
end

function BattlepassItem:__BindListener()
    self.btnVip:SetClick(self:ToFunc("OnAwardButtonClick"),true)
    self.btnNormal:SetClick(self:ToFunc("OnAwardButtonClick",false))
end

function BattlepassItem:SetData(data, index, parentWindow)
    self.data = data
    self.index = index
    self.rootCanvas = parentWindow.rootCanvas
    self.canvasPgr.sortingOrder = self.rootCanvas.sortingOrder + 1
    self:RefreshAllStyle()
end

function BattlepassItem:RefreshAllStyle()
    self:RefreshFreeAward()
    self:RefreshVipAward()
    self:RefreshPgr()
end

function BattlepassItem:RefreshPgr()
    local lv = self.data.level
    local lastConf = mod.BattlepassProxy:GetInfoConfig(self.data.season_id, lv - 1) or {}
    local lastNeedExp = lastConf.need_exp or 0
    local data = mod.BattlepassProxy:GetAllData()
    local playerLv = data.level
    local playerExp = data.exp
    local progress = 1
    if playerLv < lv then
        if lv - playerLv == 1 then
            if lastNeedExp > 0 then
                progress = playerExp / lastNeedExp
            end
        else
            progress = 0
        end
    end
    self.imgPgrFill.fillAmount = progress
    local color = lv <= playerLv and BattlepassItem.ColorReach or BattlepassItem.ColorUnReach
    self.txtLevel.text = lv
    self.outlineLevel.effectColor = color
    self.objReach:SetActive(lv <= playerLv)
    self.objLine:SetActive(lv == playerLv)
    self.objBG:SetActive(self.index % 2 == 1)
    local originLength = BattlepassWindow.ItemHeight
    local longLength = 1000
    local originWidth = self.rectPgr.rect.width
    UnityUtils.SetSizeDelata(self.rectPgr, originWidth, self.index == 1 and longLength or originLength)
end

function BattlepassItem:RefreshFreeAward()
    self:RefreshAwardStyle(false,self.txtNormalNum,self.imgNormalIcon,self.objNormalRecv,self.objNormalLock,self.objNormal)
end

function BattlepassItem:RefreshVipAward()
    self:RefreshAwardStyle(true,self.txtVipNum,self.imgVipIcon,self.objVipRecv,self.objVipLock,self.objVip)
end

function BattlepassItem:SetAwardState(isVip,state)
    if isVip then
        self.vipAwardState = state
    else
        self.freeAwardState = state
    end
end

function BattlepassItem:GetAwardState(isVip)
    if isVip then
        return self.vipAwardState
    end
    return self.freeAwardState
end

function BattlepassItem:RefreshAwardStyle(isVip,txtNum,imgIcon,objRecv,objLock,objRoot)
    local conf = mod.BattlepassProxy:GetInfoConfig(self.data.season_id, self.data.level)
    local data = isVip and conf.pay_reward[1] or conf.free_reward[1]
    local tbInfo = isVip and self.vipAwardInfo or self.freeAwardInfo
    tbInfo.Id = data[1]
    tbInfo.Count = data[2]
    tbInfo.CustomSelectId = -1
    local item = Config.ItemData.data_item_info[data[1]]
    local isCustom = mod.BattlepassProxy:IsCustomSelectAward(self.data.season_id, self.data.level,isVip)
    if isCustom then
        tbInfo.CustomSelectId = data[1]
    end
    self:SetSprite(imgIcon, AssetPath.GetBattlepassItemIcon(item.icon),true)
    txtNum.text = data[2] == 1 and "" or data[2]
    local awardState = mod.BattlepassProxy:GetAwardState(self.data.season_id, self.data.level, isVip)
    self:SetAwardState(isVip, awardState)
    objRecv:SetActive(awardState == GDefine.AwardState.Receive)
    local playerVip = mod.BattlepassProxy:IsVip()
    objLock:SetActive(isVip and not playerVip)
    if awardState == GDefine.AwardState.Unclaimed then
        local eff = self:LoadEffect(isVip,10025,objRoot.transform,{x=10,y=0},{x=1250,y=1250,z=1250})
        self.tbEffectUID[isVip and 1 or 0] = eff.uid
    else
        self:RemoveEffect(self.tbEffectUID[isVip and 1 or 0])
    end
end

function BattlepassItem:OnAwardButtonClick(isVip)
    local state = self:GetAwardState(isVip)
    if state ~= GDefine.AwardState.Unclaimed then
        local itemId = isVip and self.vipAwardInfo.Id or self.freeAwardInfo.Id
        local trans = isVip and self.btnVip.transform or self.btnNormal.transform
        mod.TipsCtrl:OpenTipsByItemId(itemId,trans)
        return
    end
    local selectId = isVip and self.vipAwardInfo.CustomSelectId or self.freeAwardInfo.CustomSelectId
    if selectId > 0 then
        self:ShowCustomSelectAwardWindow(selectId, self.data.level, isVip)
        return
    end
    mod.BattlepassFacade:SendMsg(11102, {
        {level = self.data.level, is_pay = isVip and 1 or 0, choose_list = {}}
    })
end

function BattlepassItem:ShowCustomSelectAwardWindow(itemId,level,isVip)
    local poolId = Config.ItemData.data_item_info[itemId].item_attr
    local poolConf = Config.ItemData.data_choose_pool[poolId]
    if not poolConf then
        LogErrorAny("无法获取道具对应的自选池数据 PoolID=",poolId,"ItemID=",itemId)
        return
    end
    local items = Config.ItemData.data_choose_items[poolId]
    if not items then
        LogErrorAny("无法获取道具对应的自选池内容数据 PoolID=",poolId,"ItemID=",itemId)
        return
    end
    local list = {}
    for _, data in ipairs(items) do
        table.insert( list, {
            item_id = data.item_id,
            count = data.item_count,
            source_id = itemId,
            level = level,
            isVip = isVip
        })
    end
    ViewManager.Instance:OpenWindow(CustomSelectWindow, {
        items = list,
        judgeOwned = poolConf.need_unit_active == 1,
        sortType = CustomSelectWindow.SortType.OwnedFirstAndItemOrder,
        cbItemSelect = self:ToFunc("OnCustomItemSelect"),
        cbSelect = self:ToFunc("OnCustomWindowSelect"),
        cbClose = self:ToFunc("OnCustomWindowClose"),
        isVip = isVip,
        onlyPreview = false,
    })
end

function BattlepassItem:OnCustomItemSelect(item,validate)
    if validate then
        mod.BattlepassProxy:SetSelectAwardData({
            key = item.data.source_id,
            val = item.data.item_id,
        },item.data.level, item.data.isVip)
    else
        SystemMessage.Show(TI18N("尚未获取该英雄!"))
    end
end

function BattlepassItem:OnCustomWindowSelect(args)
    local choose = mod.BattlepassProxy:GetSelectAwardData(self.data.level,args.isVip)
    if not choose then
        return
    end
    mod.BattlepassFacade:SendMsg(11102, {
        {level = self.data.level, is_pay = args.isVip and 1 or 0, choose_list = choose}
    })
end

function BattlepassItem:OnCustomWindowClose()
    mod.BattlepassProxy:ClearSelectAwardData()
end

function BattlepassItem:OnReset()
    self.data = nil
    self.index = nil
end

function BattlepassItem:OnRecycle()
    self:RemoveAllEffect()
    self:InitData()
end

function BattlepassItem:LoadEffect(isVip,id,parent,pos,scale)
    local order = self.rootCanvas.sortingOrder + 2
    return self:LoadUIEffect({
        confId = id,
        parent = parent,
        order = order,
        lastTime = 0,
        delayTime = 0,
        pos = pos,
        scale = scale,
    },false)
end

--#region 静态方法

function BattlepassItem.Create(template)
    local item = BattlepassItem.New()
    item:SetObject(GameObject.Instantiate(template))
    item:Show()
    return item
end

--#endregion