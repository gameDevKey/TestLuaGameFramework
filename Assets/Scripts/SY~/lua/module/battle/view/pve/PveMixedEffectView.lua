PveMixedEffectView = BaseClass("PveMixedEffectView",ExtendView)

PveMixedEffectView.Event = EventEnum.New(
    "PlayUIEffect"
)

function PveMixedEffectView:__Init()
end

function PveMixedEffectView:__CacheObject()
    self.animRoot = self:Find("main/tips_node")
end

function PveMixedEffectView:__BindEvent()
    self:BindEvent(PveMixedEffectView.Event.PlayUIEffect)
end

function PveMixedEffectView:__Hide()
end

function PveMixedEffectView:PlayUIEffect(effectId,callback)
    self:LoadUIEffect({
        confId = effectId,
        parent = self.animRoot,
        order = self:GetOrder() + 1,
        onComplete = callback,
    },true)
end