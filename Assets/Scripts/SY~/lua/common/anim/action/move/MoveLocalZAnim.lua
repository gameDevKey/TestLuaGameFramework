MoveLocalZAnim = BaseClass("MoveLocalZAnim",AnimBaseTween)

function MoveLocalZAnim:__Init(transform,toZ,time)
    self.transform = transform
    self.toZ = toZ
    self.time = time
end

function MoveLocalZAnim:__Delete()
    
end

function MoveLocalZAnim:OnTween()
    local tween = self.transform:DOLocalMoveZ(self.toZ,self.time)
    return tween
end

function MoveLocalZAnim.Create(root,animData,nodes,animNodes)
    local transform = AnimUtils.GetComponent(root,animData.path)
    local anim = MoveLocalZAnim.New(transform,animData.toZ,animData.time)
    return anim
end