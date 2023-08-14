DrawCardSummaryWindow = BaseClass("DrawCardSummaryWindow",BaseWindow)

DrawCardSummaryWindow.AnimType = {
    "summary_window_normal_purple_mode_1",
    "summary_window_normal_mode_1",
    "summary_window_normal_mode_10",
    "summary_window_special_mode_1",
    "summary_window_special_mode_10",
}

function DrawCardSummaryWindow:__Init()
    self:SetAsset("ui/prefab/draw_card/draw_card_summary_window.prefab",AssetType.Prefab)
    self:AddAsset(AssetPath.drawCardItemAnimCtrl,AssetType.Object)
    self.tbItem = {}
end

function DrawCardSummaryWindow:__Delete()
end

function DrawCardSummaryWindow:__CacheObject()
    self.objNormalStyle = self:Find("normal_style").gameObject
    self.objSpecialStyle = self:Find("special_style").gameObject
    self.transContent = self:Find("content")
    self.btnAgain = self:Find("btn_again",Button)
    self.btnConfirm = self:Find("btn_confirm",Button)
    self.imgCost = self:Find("btn_again/img_cost/content/img_s_cost",Image)
    self.txtCost = self:Find("btn_again/img_cost/content/txt_s_cost",Text)
    self.objOr = self:Find("btn_again/img_cost/content/txt_or").gameObject
    self.imgCost2 = self:Find("btn_again/img_cost/content/img_s_cost2",Image)
    self.txtCost2 = self:Find("btn_again/img_cost/content/txt_s_cost2",Text)
    self.objSingle = self:Find("btn_again/img_single").gameObject
    self.objMulti = self:Find("btn_again/img_multi").gameObject
    self.objTips = self:Find("btn_again/txt_tips").gameObject
    self.canvasContent = self:Find("content",Canvas)

    self.objReddot = self:Find("btn_again/img_m_reddot").gameObject
    self.txtTips = self:Find("btn_again/txt_single",Text)
    self.template = self:Find("content/draw_card_award_item").gameObject
    self.template:SetActive(false)

    self.tbPosTrans = {}
    local modes = {1, 10}
    for _, mode in ipairs(modes) do
        self.tbPosTrans[mode] = {}
        local modePath = string.format("content/mode_"..mode)
        local transMode = self:Find(modePath)
        for i = 1, mode do
            self.tbPosTrans[mode][i] = transMode:Find("pos_"..i)
        end
    end
end

function DrawCardSummaryWindow:GetPosByMode(mode, index)
    local pos = self.tbPosTrans[mode] and self.tbPosTrans[mode][index]
    if not pos then
        LogErrorAny("无法找到抽卡总览挂载点 Mode=",mode,"Index=",index)
        pos = self.transContent
    end
    return pos
end

function DrawCardSummaryWindow:__BindListener()
    self.btnAgain:SetClick(self:ToFunc("OnAgainButtonClick"))
    self.btnConfirm:SetClick(self:ToFunc("OnComfirmButtonClick"))
end

function DrawCardSummaryWindow:__BindEvent()
end

function DrawCardSummaryWindow:__Create()
    for _, name in pairs(DrawCardSummaryWindow.AnimType) do
        self:AddAnimEffectListener(name,self:ToFunc("OnAnimEffectPlay"))
    end
end

function DrawCardSummaryWindow:__Show()
    self.canvasContent.sortingOrder = self:GetOrder() + GDefine.EffectOrderAdd
    self.data = self.args
    local isSpecial = mod.DrawCardProxy:ContainQuailtyCard(self.data.item_list, GDefine.Quality.orange)
    self.objNormalStyle:SetActive(not isSpecial)
    self.objSpecialStyle:SetActive(isSpecial)
    self:RecycleAllItem()
    local len = #self.data.item_list
    self.isMulti = len > 1
    self.drawType = self.isMulti and GDefine.DrawCardType.Multi or GDefine.DrawCardType.Single
    if self.isMulti then
        self.txtTips.text = TI18N("招募10次")
    else
        self.txtTips.text = TI18N("招募")
    end
    self.objMulti:SetActive(self.isMulti)
    self.objTips:SetActive(self.isMulti)
    self.objSingle:SetActive(not self.isMulti)
    local anim = self:GetAsset(AssetPath.drawCardItemAnimCtrl)
    for i, _data in ipairs(self.data.item_list or {}) do
        local item = DrawCardSummaryItem.Create(self.template)
        item.transform:SetParent(self:GetPosByMode(len, i))
        item.transform:Reset()
        item:SetAnim(AssetPath.drawCardItemAnimCtrl,anim)
        item:SetData(_data, i, self)
        table.insert(self.tbItem, item)
    end
    self:PlayEnterAnim()
    mod.DrawCardFacade:SendEvent(DrawCardWindow.Event.RefreshDrawButtonStyle,
        self.drawType, self.imgCost, self.txtCost, self.objReddot, self.objOr, self.imgCost2, self.txtCost2)
end

function DrawCardSummaryWindow:PlayEnterAnim()
    local animIndex = 1
    if self.isMulti then
        local hasOrange = mod.DrawCardProxy:ContainQuailtyCard(self.data.item_list, GDefine.Quality.orange)
        animIndex = hasOrange and 5 or 3
    else
        local hasOrange = mod.DrawCardProxy:ContainQuailtyCard(self.data.item_list, GDefine.Quality.orange)
        if hasOrange then
            animIndex = 4
        else
            local hasPurple = mod.DrawCardProxy:ContainQuailtyCard(self.data.item_list, GDefine.Quality.purple)
            if hasPurple then
                animIndex = 1
            else
                animIndex = 2
            end
        end
    end
    self:PlayAnim(DrawCardSummaryWindow.AnimType[animIndex])
end

function DrawCardSummaryWindow:__Hide()
    self:RecycleAllItem()
end

function DrawCardSummaryWindow:RecycleAllItem()
    for _, item in ipairs(self.tbItem or {}) do
        item:OnRecycle()
        item:Destroy()
    end
    self.tbItem = {}
end

function DrawCardSummaryWindow:OnAgainButtonClick()
    ViewManager.Instance:CloseWindow(DrawCardSummaryWindow)
    ViewManager.Instance:CloseWindow(DrawCardShowWindow)
    mod.DrawCardFacade:SendEvent(DrawCardWindow.Event.OnDrawCardButtonClick,self.drawType)
end

function DrawCardSummaryWindow:OnComfirmButtonClick()
    ViewManager.Instance:CloseWindow(DrawCardSummaryWindow)
    ViewManager.Instance:CloseWindow(DrawCardShowWindow)
end

function DrawCardSummaryWindow:OnAnimEffectPlay(name,data)
    self:LoadUIEffectByAnimData(data,true)
end