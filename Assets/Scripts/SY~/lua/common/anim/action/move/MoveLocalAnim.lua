MoveLocalAnim = BaseClass("MoveLocalAnim",AnimBaseTween)

function MoveLocalAnim:__Init(transform,toPos,time)
    self.transform = transform
    self.toPos = toPos
    self.time = time
end

function MoveLocalAnim:__Delete()
    
end


function MoveLocalAnim:OnTween()
    local tween = self.transform:DOLocalMove(self.toPos,self.time)
    return tween
end

function MoveLocalAnim.Create(root,animData,nodes,animNodes)
    local transform = AnimUtils.GetComponent(root,animData.path)
    local anim = MoveLocalAnim.New(transform,animData.toPos,animData.time)
    return anim
end