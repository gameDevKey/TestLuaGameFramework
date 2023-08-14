RotationAnim = BaseClass("RotationAnim",AnimBaseTween)

function RotationAnim:__Init(transform,toValue,time)
    self.transform = transform
    self.toValue = toValue
    self.time = time
end

function RotationAnim:__Delete()
    
end

function RotationAnim:OnTween()
    local tween = self.transform:DORotate(self.toValue,self.time)
    return tween
end

function RotationAnim.Create(root,animData,nodes,animNodes)
    local transform = AnimUtils.GetComponent(root,animData.path)
    local anim = RotationAnim.New(transform,animData.toValue,animData.time)
    return anim
end