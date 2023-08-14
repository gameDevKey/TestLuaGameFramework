ScaleXAnim = BaseClass("ScaleXAnim",AnimBaseTween)

function ScaleXAnim:__Init(transform,toX,time)
    self.transform = transform
    self.toX = toX
    self.time = time
end

function ScaleXAnim:__Delete()
    
end

function ScaleXAnim:OnTween()
    local tween = self.transform:DOScaleX(self.toX,self.time)
    return tween
end

function ScaleXAnim.Create(root,animData,nodes,animNodes)
    local transform = AnimUtils.GetComponent(root,animData.path)
    local anim = ScaleXAnim.New(transform,animData.toX,animData.time)
    return anim
end