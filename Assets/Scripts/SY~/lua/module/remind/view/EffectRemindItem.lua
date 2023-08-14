EffectRemindItem = BaseClass("EffectRemindItem", RemindBase)

function EffectRemindItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
    self:SetAsset("ui/prefab/common/effect_remind_item.prefab")

    self.effectSetting = nil
    self.effect = nil
end

function EffectRemindItem:__Delete()
    if self.effect then
        self.effect:Delete()
    end
end

function EffectRemindItem:__CacheObject()

end

function EffectRemindItem:__BindListener()

end

function EffectRemindItem:__Create()

end

function EffectRemindItem:__Show()
    if not self.effectSetting then
        return
    end

    self.effectSetting.parent = self.transform

    self.effect = UIEffect.New()
    self.effect:Init(self.effectSetting)
    self.effect:Play()
end

function EffectRemindItem:SetEffect(effectSetting)
    self.effectSetting = effectSetting
end