PlayUIEffectGuideNode = BaseClass("PlayUIEffectGuideNode",BaseGuideNode)

function PlayUIEffectGuideNode:__Init()
    self.effect = nil
end

function PlayUIEffectGuideNode:OnStart()
    local x,y = self:GetTargetPos()

    local offsetOrder = self.actionParam.offsetOrder or 0
    local order = ViewDefine.Layer["PlayerGuideView_Effect"] + offsetOrder
    order = MathUtils.Clamp(order, 0, 32767)

    local setting = {}
    setting.confId = self.actionParam.effectId
    setting.parent = PlayerGuideDefine.contentTrans
    setting.order = order
    setting.onLoad = self:ToFunc("OnEffectLoad")

	self.effect = UIEffect.New()
    self.effect:Init(setting)
    local scale = self.actionParam.scale
    if scale then
        self.effect:SetScale(scale.x,scale.y,scale.z)
    end
    self.effect:SetPos(x,y)
    self.effect:Play()
end

function PlayUIEffectGuideNode:OnEffectLoad(id,effect)
    if self.actionParam.text then
        local txt = effect.effect.gameObject:GetComponentInChildren(Text,true)
        if txt then
            txt.lineSpacing = self.actionParam.lineSpacing or 1
            txt.text = self.actionParam.text
            local textPos = self.actionParam.textPos
            if textPos then
                local rect = txt:GetComponent(RectTransform)
                UnityUtils.SetAnchoredPosition(rect, textPos.x, textPos.y)
            end
        end
    end
end

function PlayUIEffectGuideNode:OnDestroy()
    if self.effect then
        self.effect:Delete()
        self.effect = nil
    end
end