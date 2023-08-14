RotationLocalZAnim = BaseClass("RotationLocalZAnim",AnimBaseTween)

function RotationLocalZAnim:__Init(transform,toZ,time)
    self.transform = transform
    self.toZ = toZ
    self.time = time
end

function RotationLocalZAnim:__Delete()
    
end

function RotationLocalZAnim:OnTween()
    local tween = DOTweenEx.DOLocalRotateZ(self.transform,self.toZ,self.time)
    return tween
end

function RotationLocalZAnim.Create(root,animData,nodes,animNodes)
    local transform = AnimUtils.GetComponent(root,animData.path)
    local anim = RotationLocalZAnim.New(transform,animData.toZ,animData.time)
    return anim
end