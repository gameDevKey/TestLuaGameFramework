RotationLocalYAnim = BaseClass("RotationLocalYAnim",AnimBaseTween)

function RotationLocalYAnim:__Init(transform,toY,time)
    self.transform = transform
    self.toY = toY
    self.time = time
end

function RotationLocalYAnim:__Delete()
    
end

function RotationLocalYAnim:OnTween()
    local tween = DOTweenEx.DOLocalRotateY(self.transform,self.toY,self.time)
    return tween
end

function RotationLocalYAnim.Create(root,animData,nodes,animNodes)
    local transform = AnimUtils.GetComponent(root,animData.path)
    local anim = RotationLocalYAnim.New(transform,animData.toY,animData.time)
    return anim
end