ToVector2Anim = BaseClass("ToVector2Anim",AnimBaseTween)

--Quaternion string Vector2 Vector3 Vector4 Color Rect RectOffset
function ToVector2Anim:__Init(fromValue,toValue,time,valueCb)
    self.fromValue = fromValue
    self.toValue = toValue
    self.time = time
    self.valueCb = valueCb
end

function ToVector2Anim:__Delete()
    
end


function ToVector2Anim:OnTween()
    local tween = DOTweenEx.ToValue(self.fromValue,self.toValue,self.time,self.valueCb)
    return tween
end

function ToVector2Anim:SetValueCb(valueCb)
    self.valueCb = valueCb
end

function ToVector2Anim.Create(root,animData,nodes,animNodes)
    local anim = ToVector2Anim.New(animData.fromValue,animData.toValue,animData.time)
    return anim
end