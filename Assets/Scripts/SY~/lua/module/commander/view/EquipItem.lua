EquipItem = BaseClass("EquipItem", BaseView)

function EquipItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
    self.data = nil
    self.enableTips = true
end

function EquipItem:__CacheObject()
    self.qualityBg = self:Find("quality_bg",Image)
    self.equipIcon = self:Find("icon", Image)
    self.equipLev = self:Find("lev", Text)
end

function EquipItem:__BindListener()
    self:Find("btn",Button):SetClick(self:ToFunc("ItemClick"))
end


function EquipItem:SetData(data)
    self.data = data
    self.conf = Config.ItemData.data_item_info[data.item_id]
    self:SetQualityBg()
    self:SetEquipIcon()
    self:SetLev(self.data.level)
end

function EquipItem:SetQualityBg()
    self:SetSprite(self.qualityBg,CommanderDefine.QualityToIconBg[self.data.quality or self.conf.quality])
end

function EquipItem:SetEquipIcon()
    self:SetSprite(self.equipIcon, AssetPath.GetItemIcon(self.conf.icon),true)
end

function EquipItem:SetLev(lev)
    self.equipLev.text = lev
end

function EquipItem:SetClickCb(cb)

end

function EquipItem:EnableTips(flag)
    self.enableTips = flag
end

function EquipItem:ItemClick()
    if self.enableTips then
        mod.TipsCtrl:OpenItemTips(self.data,self.transform)
    end
end

function EquipItem:SetSize(w,h)
    UnityUtils.SetSizeDelata(self.transform, w, h)
    self.transform:SetLocalScale(w / 86,h / 87,1)
end

function EquipItem.Create(template)
    local equipItem = nil--PoolManager.Instance:Pop(PoolType.base_view, EquipItem.poolKey)
    if not equipItem then
        equipItem = EquipItem.New()
        equipItem:SetObject(GameObject.Instantiate(template))
    end
    return equipItem
end

