RotationZAnim = BaseClass("RotationZAnim",AnimBaseTween)

function RotationZAnim:__Init(transform,toZ,time)
    self.transform = transform
    self.toZ = toZ
    self.time = time
end

function RotationZAnim:__Delete()
    
end

function RotationZAnim:OnTween()
    local tween = DOTweenEx.DORotateZ(self.transform,self.toZ,self.time)
    return tween
end

function RotationZAnim.Create(root,animData,nodes,animNodes)
    local transform = AnimUtils.GetComponent(root,animData.path)
    local anim = RotationZAnim.New(transform,animData.toZ,animData.time)
    return anim
end