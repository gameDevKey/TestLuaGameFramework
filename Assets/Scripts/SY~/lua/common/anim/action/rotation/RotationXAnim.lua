RotationXAnim = BaseClass("RotationXAnim",AnimBaseTween)

function RotationXAnim:__Init(transform,toX,time)
    self.transform = transform
    self.toX = toX
    self.time = time
end

function RotationXAnim:__Delete()
    
end

function RotationXAnim:OnTween()
    local tween = DOTweenEx.DORotateX(self.transform,self.toX,self.time)
    return tween
end

function RotationXAnim.Create(root,animData,nodes,animNodes)
    local transform = AnimUtils.GetComponent(root,animData.path)
    local anim = RotationXAnim.New(transform,animData.toX,animData.time)
    return anim
end