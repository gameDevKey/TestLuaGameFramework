HeroItem = BaseClass("HeroItem", BaseView)
HeroItem.Width = 95
HeroItem.Height = 97

function HeroItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
    self.data = nil
    self.onClick = nil
end

function HeroItem:__CacheObject()
    self.imgQuality = self:Find(nil,Image)
    self.imgIcon = self:Find("img_icon",Image)
    self.txtLv = self:Find("txt_lv",Text)
    self.btn = self:Find(nil,Button)
end

function HeroItem:__BindListener()
    self.btn:SetClick(self:ToFunc("OnClick"))
end

--[[
    data = {
        isEmpty : boolean
        unit_id : integer
        unit_level : integer
        onClick : function
    }
]]--
function HeroItem:SetData(data,index)
    self.data = data
    self.index = index
    self.unitConf = data.unit_id and Config.UnitData.data_unit_info[data.unit_id]
    self.itemConf = data.unit_id and Config.ItemData.data_item_info[data.unit_id]
    self:RefreshAll()
end

function HeroItem:RefreshAll()
    self:SetClickCb(self.data.onClick)
    if self.data.isEmpty then
        self.imgIcon.gameObject:SetActive(false)
        self:SetSprite(self.imgQuality,AssetPath.QualityToItemSquare[GDefine.Quality.green], false)
        self.txtLv.text = ""
    else
        self.imgIcon.gameObject:SetActive(true)
        if self.unitConf then
            self:SetSprite(self.imgQuality,AssetPath.QualityToItemSquare[self.unitConf.quality], false)
        else
            LogErrorAny("设置品质底图失败, 请配置英雄",self.data.unit_id,"所对应的品质")
        end
        if self.itemConf then
            self:SetSprite(self.imgIcon, AssetPath.GetUnitIconHead(self.itemConf.icon), false)
        else
            LogErrorAny("设置卡牌图标失败, 请配置英雄",self.data.unit_id,"所对应的道具图标")
        end
        self.txtLv.text = ("Lv." .. (self.data.unit_level or self.data.level)) or ""
    end
end

function HeroItem:SetClickCb(cb)
    self.onClick = cb
    -- self.btn.enabled = self.onClick ~= nil
end

function HeroItem:OnClick()
    if self.onClick then
        self.onClick()
    end
end

function HeroItem:SetSize(w,h)
    self.transform:SetLocalScale(w / HeroItem.Width,h / HeroItem.Height,1)
end

function HeroItem:SetScale(x,y)
    self.transform:SetLocalScale(x,y,1)
end

function HeroItem.Create()
    local item = HeroItem.New()
    item:SetObject(GameObject.Instantiate(PreloadManager.Instance:GetAsset(AssetPath.heroItem)))
    item:Show()
    return item
end

