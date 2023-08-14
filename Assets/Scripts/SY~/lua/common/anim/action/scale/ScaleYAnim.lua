ScaleYAnim = BaseClass("ScaleYAnim",AnimBaseTween)

function ScaleYAnim:__Init(transform,toY,time)
    self.transform = transform
    self.toY = toY
    self.time = time
end

function ScaleYAnim:__Delete()
    
end

function ScaleYAnim:OnTween()
    local tween = self.transform:DOScaleY(self.toY,self.time)
    return tween
end

function ScaleYAnim.Create(root,animData,nodes,animNodes)
    local transform = AnimUtils.GetComponent(root,animData.path)
    local anim = ScaleYAnim.New(transform,animData.toY,animData.time)
    return anim
end