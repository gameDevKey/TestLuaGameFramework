CustomSelectItem = BaseClass("CustomSelectItem", BaseView)

function CustomSelectItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
    self.judgeOwned = false
    self.onlyPreview = false
end

function CustomSelectItem:__CacheObject()
    self.btn = self:Find("btn_select",Button)
    self.imgIcon = self:Find("img_icon",Image)
    self.imgQuality = self:Find("img_quality",Image)
    self.txtNum = self:Find("image_27/txt_amount",Text)
    self.objSelect = self:Find("img_select").gameObject
    self.objMask = self:Find("img_mask").gameObject
end

function CustomSelectItem:__Create()
end

function CustomSelectItem:__BindListener()
    self.btn:SetClick(self:ToFunc("OnSelect"))
end

--[[
    data = {
        item_id
        count
    }
]]--
function CustomSelectItem:SetData(data, index)
    self.data = data
    self.index = index
    self:RefreshAllStyle()
end

function CustomSelectItem:SetSelectCallback(func)
    self.cbSelect = func
end

function CustomSelectItem:RefreshAllStyle()
    local grey = not self:IsValidate()
    self.objMask:SetActive(grey)
    local config = Config.ItemData.data_item_info[self.data.item_id]
    assert(config, string.format("配置不存在,无法显示自选物品[%s]",tostring(self.data.item_id)))
    local icon
    if config.type == GDefine.ItemType.unitCard then
        icon = AssetPath.GetUnitIconHeadObliqueSquare(tostring(config.icon))
    else
        icon = AssetPath.GetItemIcon(tostring(config.icon))
    end
    self:SetSprite(self.imgIcon, icon)
    self:SetSprite(self.imgQuality,AssetPath.QualityToUnitDetailsIconBg[config.quality])
    self.txtNum.text = string.format("x%d",self.data.count)
end

function CustomSelectItem:OnReset()
    self.data = nil
    self.index = nil
end

function CustomSelectItem:OnRecycle()
end

-- 判断是否已拥有
function CustomSelectItem:IsOwned()
    return mod.CollectionProxy:GetDataById(self.data.item_id) ~= nil
end

function CustomSelectItem:IsValidate()
    if self.onlyPreview then
        return true
    end
    return not self.judgeOwned or self:IsOwned()
end

function CustomSelectItem:OnSelect()
    if self.onlyPreview then
        return
    end
    local validate = self:IsValidate()
    if self.cbSelect then
        self.cbSelect(self, validate)
    end
    if validate then
        self.objSelect:SetActive(true)
    end
end

function CustomSelectItem:OnUnselect()
    if self.onlyPreview then
        return
    end
    self.objSelect:SetActive(false)
end

function CustomSelectItem:SetJudgeOwned(judge)
    self.judgeOwned = judge
end

function CustomSelectItem:SetOnlyPreview(preview)
    self.onlyPreview = preview
end

--#region 静态方法

function CustomSelectItem.Create(template)
    local item = CustomSelectItem.New()
    item:SetObject(GameObject.Instantiate(template))
    item:Show()
    return item
end

--#endregion