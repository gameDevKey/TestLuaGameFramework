RotationYAnim = BaseClass("RotationYAnim",AnimBaseTween)

function RotationYAnim:__Init(transform,toY,time)
    self.transform = transform
    self.toY = toY
    self.time = time
end

function RotationYAnim:__Delete()
    
end


function RotationYAnim:OnTween()
    local tween = DOTweenEx.DORotateY(self.transform,self.toY,self.time)
    return tween
end

function RotationYAnim.Create(root,animData,nodes,animNodes)
    local transform = AnimUtils.GetComponent(root,animData.path)
    local anim = RotationYAnim.New(transform,animData.toY,animData.time)
    return anim
end