ToColorAnim = BaseClass("ToColorAnim",AnimBaseTween)

--Quaternion string Vector2 Vector3 Vector4 Color Rect RectOffset
function ToColorAnim:__Init(fromValue,toValue,time,valueCb)
    self.fromValue = fromValue
    self.toValue = toValue
    self.time = time
    self.valueCb = valueCb
end

function ToColorAnim:OnTween()
    local tween = DOTweenEx.ToValue(self.fromValue,self.toValue,self.time,self.valueCb)
    return tween
end

function ToColorAnim:SetValueCb(valueCb)
    self.valueCb = valueCb
end

function ToColorAnim.Create(root,animData,nodes,animNodes)
    local anim = ToColorAnim.New(animData.fromValue,animData.toValue,animData.time)
    return anim
end