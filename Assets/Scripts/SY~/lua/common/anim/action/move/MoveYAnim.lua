MoveYAnim = BaseClass("MoveYAnim",AnimBaseTween)

function MoveYAnim:__Init(transform,toY,time)
    self.transform = transform
    self.toY = toY
    self.time = time
end

function MoveYAnim:__Delete()
    
end

function MoveYAnim:OnTween()
    local tween = self.transform:DOMoveY(self.toY,self.time)
    return tween
end

function MoveYAnim.Create(root,animData,nodes,animNodes)
    local transform = AnimUtils.GetComponent(root,animData.path)
    local anim = MoveYAnim.New(transform,animData.toY,animData.time)
    return anim
end