ObtainSecView = BaseClass("ObtainSecView",BaseWindow)

function ObtainSecView:__Init()
    self:SetAsset("ui/prefab/obtain/obtain_seconditem_window.prefab", AssetType.Prefab)
end

function ObtainSecView:__CacheObject()
    self.numText = self:Find("main/head_item/num_text",Text)
    self.levelText = self:Find("main/head_item/level_text",Text)
    self.nameText = self:Find("main/head_item/name_text",Text)
    self.sliderFill = self:Find("main/head_item/slider/mask/fill",Image)
    self.raceType = self:Find("main/head_item/race_type",Image)
    self.headItem = self:Find("main/head_item/head_img",Image)
    self.headFrame = self:Find("main/head_item/head_frame",Image)
    self.sliderMask = self:Find("main/head_item/slider/mask")
    self.quantity = self:Find("main/head_item/slider/quantity",Text)
end

function ObtainSecView:__BindListener()
    self:Find("bg",Button):SetClick(self:ToFunc("CloseClick"))
end

function ObtainSecView:__Show()
    self:SetOther()
end

function ObtainSecView:SetOther()
    local cardItemData = mod.ObtainSecProxy:SetCradData(1014)
    self.nameText.text = cardItemData.cfg.name
    self.levelText.text = cardItemData.cardData.level
    self.numText.text = string.format("×%s",cardItemData.cardData.count) 

    self:SetSprite(self.sliderFill,AssetPath.QualityToSliderFill[cardItemData.cfg.quality])
    self:SetSprite(self.headFrame,AssetPath.QualityToFrame[cardItemData.cfg.quality])
    local key = cardItemData.cardData.unit_id.."_"..cardItemData.cardData.level+1
    local nextLevInfo = Config.UnitData.data_unit_lev_info[key]
    local consume = 0
    local val = 0
    local quantityText = ""
    if not nextLevInfo then
        val = 1
        quantityText = TI18N("已满级")
        self.sliderFill.gameObject:SetActive(false)
    else
        consume = nextLevInfo.lv_up_count
        val = consume > 0 and cardItemData.cardData.count/consume or cardItemData.cardData.count
        quantityText = cardItemData.cardData.count.."/"..consume
        isEnough = cardItemData.cardData.count >= consume
        self.sliderFill.gameObject:SetActive(true)
    end
    if val < 0 then
        val = 0
    end
    if val > 1 then
        val = 1
    end
    local width = self.sliderFill.transform.sizeDelta.x
    local height = self.sliderMask.sizeDelta.y
    UnityUtils.SetSizeDelata(self.sliderMask,width*val,height)

    self.quantity.text = quantityText
    if cardItemData.cfg.race_type and cardItemData.cfg.race_type > 0 then
        self:SetSprite(self.raceType,AssetPath.RaceTypeToIcon[cardItemData.cfg.race_type],true)
        self.raceType.gameObject:SetActive(true)
    else
        self.raceType.gameObject:SetActive(false)
    end
    self:SetSprite(self.headItem,AssetPath.GetUnitIconHead(cardItemData.cardData.unit_id,false),false)
end

function ObtainSecView:CloseClick()
    ViewManager.Instance:CloseWindow(ObtainSecView)
end