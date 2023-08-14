ToVector4Anim = BaseClass("ToVector4Anim",AnimBaseTween)

--Quaternion string Vector2 Vector3 Vector4 Color Rect RectOffset
function ToVector4Anim:__Init(fromValue,toValue,time,valueCb)
    self.fromValue = fromValue
    self.toValue = toValue
    self.time = time
    self.valueCb = valueCb
end

function ToVector4Anim:__Delete()
    
end

function ToVector4Anim:OnTween()
    local tween = DOTweenEx.ToValue(self.fromValue,self.toValue,self.time,self.valueCb)
    return tween
end

function ToVector4Anim:SetValueCb(valueCb)
    self.valueCb = valueCb
end

function ToVector4Anim.Create(root,animData,nodes,animNodes)
    local anim = ToVector4Anim.New(animData.fromValue,animData.toValue,animData.time)
    return anim
end