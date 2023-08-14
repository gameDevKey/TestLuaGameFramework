ToSizeDeltaAnim = BaseClass("ToSizeDeltaAnim",AnimBaseTween)

function ToSizeDeltaAnim:__Init(rectTransform,toValue,time)
    self.rectTransform = rectTransform
    self.toValue = toValue
    self.time = time
end

function ToSizeDeltaAnim:OnTween()
    local tween = self.rectTransform:DOSizeDelta(self.toValue,self.time)
    return tween
end

function ToSizeDeltaAnim.Create(root,animData,nodes,animNodes)
    local rectTransform = AnimUtils.GetComponent(root,animData.path)
    local anim = ToSizeDeltaAnim.New(rectTransform,animData.toValue,animData.time)
    return anim
end