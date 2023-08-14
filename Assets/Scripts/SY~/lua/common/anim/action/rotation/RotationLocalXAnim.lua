RotationLocalXAnim = BaseClass("RotationLocalXAnim",AnimBaseTween)

function RotationLocalXAnim:__Init(transform,toX,time)
    self.transform = transform
    self.toX = toX
    self.time = time
end

function RotationLocalXAnim:__Delete()
    
end

function RotationLocalXAnim:OnTween()
    local tween = DOTweenEx.DOLocalRotateX(self.transform,self.toX,self.time)
    return tween
end

function RotationLocalXAnim.Create(root,animData,nodes,animNodes)
    local transform = AnimUtils.GetComponent(root,animData.path)
    local anim = RotationLocalXAnim.New(transform,animData.toX,animData.time)
    return anim
end