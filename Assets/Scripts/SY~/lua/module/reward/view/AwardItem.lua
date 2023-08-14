AwardItem = BaseClass("AwardItem", BaseView)

function AwardItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
end

function AwardItem:__CacheObject()
    self.qualityBg = self:Find("img_bg",Image)
    self.imgIcon = self:Find("img_icon",Image)
    self.txtAmount = self:Find("num_node/num",Text)
    self.objProgress = self:Find("img_progress_bg").gameObject
    self.imgProgress = self:Find("img_progress_bg/img_progress_fill",Image)
    self.txtProgress = self:Find("img_progress_bg/txt_progress",Text)
    self.transEffectPos = self:Find("effect_pos")
    self.canvasGroup = self:Find(nil,CanvasGroup)
end

function AwardItem:__Create()
    self:AddAnimEffectListener("award_item",self:ToFunc("OnAnimEffectPlay"))
    self:AddAnimDelayPlayListener("award_window",self:ToFunc("OnAnimDelayPlay"))
end

function AwardItem:__BindListener()
end

--[[
    data = {
        count = 100,
        item_id = 2,
    }
]]--
function AwardItem:SetData(data, index, parentWindow)
    self.data = data
    self.index = index
    self.rootCanvas = parentWindow.rootCanvas
    local config = Config.ItemData.data_item_info[data.item_id]
    if not config then
        error(string.format("配置不存在,无法显示奖励[%s]",tostring(data.item_id)))
    end
    local icon = AssetPath.GetItemIcon(tostring(config.icon))
    self:SetSprite(self.imgIcon, icon)

    local quality = (data.quality and data.quality ~= 0) and data.quality or config.quality
    self:SetSprite(self.qualityBg,AssetPath.QualityToItemSquare[quality])

    self.txtAmount.text = string.format("x%d",data.count)
    self:TryShowProgress(0.7)
end

function AwardItem:OnReset()
    self.data = nil
    self.index = nil
end

function AwardItem:TryShowProgress(time)
    local unitConfig = ConfigUtil.GetUnitDataByItemId(self.data.item_id)
    if not unitConfig then
        self.objProgress:SetActive(false)
        return
    end
    self.objProgress:SetActive(true)
    local unitData = mod.CollectionProxy:GetDataById(unitConfig.id)
    local ownedAmount,maxAmount,percent = ConfigUtil.GetUnitItemOwnedAmount(unitConfig.id)
    local getAmount = self.data.count
    local preAmount = MathUtils.Clamp(ownedAmount - getAmount, 0)
    if unitData.level == 1 and preAmount <= 1 then
        -- 新获得
        self.objProgress:SetActive(false)
    else
        -- 再次获得
        self.objProgress:SetActive(true)
        self.txtProgress.text = string.format("%d/%d",ownedAmount,maxAmount)
        local anim = ToIntValueAnim.New(preAmount,ownedAmount,time,function (v)
            local p = v / maxAmount
            self.imgProgress.fillAmount = p
        end)
        anim:Play()
    end
end

function AwardItem:OnAnimEffectPlay(animName,data)
    self:LoadUIEffectByAnimData(data,true)
end

function AwardItem:OnAnimDelayPlay()
    self:PlayAnim("award_item")
end

function AwardItem:OnRecycle()
    self:RemoveAllEffect()
end

--#region 静态方法

function AwardItem.Create(template)
    local awardItem = AwardItem.New()
    awardItem:SetObject(GameObject.Instantiate(template))
    awardItem:Show()
    return awardItem
end

--#endregion