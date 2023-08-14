RotationLocalAnim = BaseClass("RotationLocalAnim",AnimBaseTween)

function RotationLocalAnim:__Init(transform,toValue,time)
    self.transform = transform
    self.toValue = toValue
    self.time = time
end

function RotationLocalAnim:__Delete()
    
end

function RotationLocalAnim:OnTween()
    local tween = self.transform:DOLocalRotate(self.toValue,self.time)
    return tween
end

function RotationLocalAnim.Create(root,animData,nodes,animNodes)
    local transform = AnimUtils.GetComponent(root,animData.path)
    local anim = RotationLocalAnim.New(transform,animData.toValue,animData.time)
    return anim
end