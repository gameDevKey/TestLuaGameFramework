ToValueAnim = BaseClass("ToValueAnim",AnimBaseTween)

--Quaternion string Vector2 Vector3 Vector4 Color Rect RectOffset
function ToValueAnim:__Init(fromValue,toValue,time,valueCb)
    self.fromValue = fromValue
    self.toValue = toValue
    self.time = time
    self.valueCb = valueCb
end

function ToValueAnim:__Delete()
    
end

function ToValueAnim:OnTween()
    local tween = DOTweenEx.ToValue(self.fromValue,self.toValue,self.time,self.valueCb)
    return tween
end

function ToValueAnim:SetValueCb(valueCb)
    self.valueCb = valueCb
end

function ToValueAnim.Create(root,animData,nodes,animNodes)
    local anim = ToValueAnim.New(animData.fromValue,animData.toValue,animData.time)
    return anim
end