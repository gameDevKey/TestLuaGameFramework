ScaleZAnim = BaseClass("ScaleZAnim",AnimBaseTween)

function ScaleZAnim:__Init(transform,toZ,time)
    self.transform = transform
    self.toZ = toZ
    self.time = time
end

function ScaleZAnim:__Delete()
    
end

function ScaleZAnim:OnTween()
    local tween = self.transform:DOScaleZ(self.toZ,self.time)
    return tween
end

function ScaleZAnim.Create(root,animData,nodes,animNodes)
    local transform = AnimUtils.GetComponent(root,animData.path)
    local anim = ScaleZAnim.New(transform,animData.toZ,animData.time)
    return anim
end