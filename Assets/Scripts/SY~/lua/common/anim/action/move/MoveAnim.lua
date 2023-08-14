MoveAnim = BaseClass("MoveAnim",AnimBaseTween)

function MoveAnim:__Init(transform,toPos,time)
    self.transform = transform
    self.toPos = toPos
    self.time = time
end

function MoveAnim:__Delete()
    
end

function MoveAnim:OnTween()
    local tween = self.transform:DOMove(self.toPos,self.time)
    return tween
end

function MoveAnim.Create(root,animData,nodes,animNodes)
    local transform = AnimUtils.GetComponent(root,animData.path)
    local anim = MoveAnim.New(transform,animData.toPos,animData.time)
    return anim
end