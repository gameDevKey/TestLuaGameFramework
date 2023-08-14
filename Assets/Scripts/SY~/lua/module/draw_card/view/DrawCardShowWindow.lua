DrawCardShowWindow = BaseClass("DrawCardShowWindow",BaseWindow)

function DrawCardShowWindow:__Init()
    self:SetAsset("ui/prefab/draw_card/draw_card_show_window.prefab",AssetType.Prefab)
    self.timer = nil
end

function DrawCardShowWindow:__Delete()
end

function DrawCardShowWindow:__CacheObject()
    self.canvasNormal = self:Find("normal_style/canvas_chest",Canvas)
    self.canvasSpecial = self:Find("special_style/canvas_chest",Canvas)
    self.objNormalStyle = self:Find("normal_style").gameObject
    self.objSpecialStyle = self:Find("special_style").gameObject

    self.canvasItem = self:Find("item",Canvas)
    self.txtName = self:Find("item/txt_name",Text)
    self.imgQuality = self:Find("item/img_quality",Image)
    self.imgIcon = self:Find("item/img_icon",Image)
    self.txtNum = self:Find("item/img_num/txt_num",Text)

    self.btnPass = self:Find("image_7/btn_pass",Button)
    self.btnNext = self:Find("btn_next",Button)
end

function DrawCardShowWindow:__BindListener()
    self.btnPass:SetClick(self:ToFunc("OnPassButtonClick"))
    self.btnNext:SetClick(self:ToFunc("OnNextButtonClick"))
    self:AddAnimEffectListener("draw_card_show_view_orange",self:ToFunc("OnAnimEffectPlay"))
    self:AddAnimEffectListener("draw_card_show_view_purple",self:ToFunc("OnAnimEffectPlay"))
    self:AddAnimEffectListener("draw_card_show_view_blue",self:ToFunc("OnAnimEffectPlay"))
end

function DrawCardShowWindow:__BindEvent()
end

function DrawCardShowWindow:__Create()
end

function DrawCardShowWindow:__Show()
    self.data = self.args
    self.currentShowIndex = 0
    self.canvasNormal.sortingOrder = self.rootCanvas.sortingOrder + GDefine.EffectOrderAdd
    self.canvasSpecial.sortingOrder = self.rootCanvas.sortingOrder + GDefine.EffectOrderAdd
    self.canvasItem.sortingOrder = self.rootCanvas.sortingOrder + GDefine.EffectOrderAdd
    self:ShowNextItem()
end

function DrawCardShowWindow:ShowNextItem()
    self:RemoveAllEffect()
    self:StopTimer()
    local data = self.data.item_list[self.currentShowIndex + 1]
    if not data then
        self:OnShowFinish()
        return
    end
    self.currentShowIndex = self.currentShowIndex + 1
    local itemId = data.item_id
    local count = data.count
    local itemConf = Config.ItemData.data_item_info[itemId]
    local quality = itemConf.quality
    self.txtName.text = itemConf.name
    self.txtNum.text = count
    self:SetSprite(self.imgIcon, AssetPath.GetDrawCardIconPath(itemId))
    self:SetSprite(self.imgQuality, AssetPath.GetDrawCardQuailtyPath(quality))
    self:StartTimer(2, self:ToFunc("ShowNextItem"))
    if itemConf.quality >= GDefine.Quality.orange then
        self:PlayAnim("draw_card_show_view_orange")
        self.objNormalStyle:SetActive(false)
        self.objSpecialStyle:SetActive(true)
        AudioManager.Instance:PlayUI(5)
    else
        if itemConf.quality == GDefine.Quality.purple then
            self:PlayAnim("draw_card_show_view_purple")
        else
            self:PlayAnim("draw_card_show_view_blue")
        end
        self.objNormalStyle:SetActive(true)
        self.objSpecialStyle:SetActive(false)
    end
end

function DrawCardShowWindow:StartTimer(delay, fn)
    self:StopTimer()
    self.timer = TimerManager.Instance:AddTimer(1, delay, fn)
end

function DrawCardShowWindow:StopTimer()
    if self.timer then
        TimerManager.Instance:RemoveTimer(self.timer)
        self.timer = nil
    end
end

function DrawCardShowWindow:__Hide()
    self:StopTimer()
end

function DrawCardShowWindow:OnPassButtonClick()
    self:OnShowFinish()
end

function DrawCardShowWindow:OnNextButtonClick()
    self:ShowNextItem()
end

function DrawCardShowWindow:OnShowFinish()
    self:RemoveAllEffect()
    self:StopTimer()
    -- ViewManager.Instance:CloseWindow(DrawCardShowWindow) --总览窗口关闭后再关，不然会看到抽卡界面
    ViewManager.Instance:OpenWindow(DrawCardSummaryWindow, self.data)
end

function DrawCardShowWindow:OnAnimEffectPlay(animName,data)
    self:LoadUIEffectByAnimData(data,true)
end