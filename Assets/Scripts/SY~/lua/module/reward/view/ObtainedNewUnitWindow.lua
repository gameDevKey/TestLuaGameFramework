ObtainedNewUnitWindow = BaseClass("ObtainedNewUnitWindow",BaseWindow)

function ObtainedNewUnitWindow:__Init()
    self:SetAsset("ui/prefab/reward/obtained_new_unit_window.prefab",AssetType.Prefab)
end

function ObtainedNewUnitWindow:__Delete()
end

function ObtainedNewUnitWindow:__CacheObject()
    self.btnClose = self:Find("panel_bg",Button)
    self.iconBg = self:Find("main/icon_bg",Image)
    self.icon = self:Find("main/icon",Image)
    self.unitName = self:Find("main/name",Text)
end

function ObtainedNewUnitWindow:__BindListener()
    self.btnClose:SetClick(self:ToFunc("OnCloseButtonClick"))
end

function ObtainedNewUnitWindow:__BindEvent()
    
end

function ObtainedNewUnitWindow:__Create()
    self:Find("main/title",Text).text = TI18N("获得卡牌")
end

function ObtainedNewUnitWindow:__Show()
    self.newUnlockUnits = self.args.newUnlockUnits
    self:SetIconCon(self.newUnlockUnits[1])
end

function ObtainedNewUnitWindow:SetIconCon(unitId)
    table.remove(self.newUnlockUnits)

    local cfg = Config.UnitData.data_unit_info[unitId]
    self:SetSprite(self.iconBg,AssetPath.QualityToUnitItemBg[cfg.quality],true)
    self:SetSprite(self.icon, AssetPath.GetUnitIconCollection(cfg.head), true)
    self.unitName.text = TI18N(cfg.name)
end

function ObtainedNewUnitWindow:OnCloseButtonClick()
    if next(self.newUnlockUnits) ~= nil then
        self:SetIconCon(self.newUnlockUnits[1])
    else
        ViewManager.Instance:CloseWindow(ObtainedNewUnitWindow)
    end
end