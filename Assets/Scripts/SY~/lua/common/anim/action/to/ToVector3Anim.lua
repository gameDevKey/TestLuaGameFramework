ToVector3Anim = BaseClass("ToVector3Anim",AnimBaseTween)

--Quaternion string Vector2 Vector3 Vector4 Color Rect RectOffset
function ToVector3Anim:__Init(fromValue,toValue,time,valueCb)
    self.fromValue = fromValue
    self.toValue = toValue
    self.time = time
    self.valueCb = valueCb
end

function ToVector3Anim:__Delete()
    
end


function ToVector3Anim:OnTween()
    local tween = DOTweenEx.ToValue(self.fromValue,self.toValue,self.time,self.valueCb)
    return tween
end

function ToVector3Anim:SetValueCb(valueCb)
    self.valueCb = valueCb
end

function ToVector3Anim.Create(root,animData,nodes,animNodes)
    local anim = ToVector3Anim.New(animData.fromValue,animData.toValue,animData.time)
    return anim
end