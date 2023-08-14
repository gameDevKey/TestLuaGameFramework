NumScrollAnim = BaseClass("NumScrollAnim",AnimBaseTween)

function NumScrollAnim:__Init(toValue,time,textComponent)
    self.toValue = toValue
    self.time = time
    self.textComponent = textComponent
end

function NumScrollAnim:__Delete()
    
end

function NumScrollAnim:OnTween()
    local fromValue = tonumber(self.textComponent.text)
    local tween = DOTweenEx.ToValueInt(fromValue,self.toValue,self.time,self:ToFunc("ValueCallBack"))
    return tween
end

function NumScrollAnim:ValueCallBack(val)
    self.textComponent.text = val
end