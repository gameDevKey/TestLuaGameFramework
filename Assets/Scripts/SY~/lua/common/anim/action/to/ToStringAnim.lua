ToStringAnim = BaseClass("ToStringAnim",AnimBaseTween)

--Quaternion string Vector2 Vector3 Vector4 Color Rect RectOffset
function ToStringAnim:__Init(fromValue,toValue,time,valueCb)
    self.fromValue = fromValue
    self.toValue = toValue
    self.time = time
    self.valueCb = valueCb
end

function ToStringAnim:__Delete()
    
end

function ToStringAnim:OnTween()
    local tween = DOTweenEx.ToValue(self.fromValue,self.toValue,self.time,self.valueCb)
    return tween
end

function ToStringAnim:SetValueCb(valueCb)
    self.valueCb = valueCb
end

function ToStringAnim.Create(root,animData,nodes,animNodes)
    local anim = ToStringAnim.New(animData.fromValue,animData.toValue,animData.time)
    return anim
end