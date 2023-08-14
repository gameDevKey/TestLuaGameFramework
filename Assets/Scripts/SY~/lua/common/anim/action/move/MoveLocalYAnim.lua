MoveLocalYAnim = BaseClass("MoveLocalYAnim",AnimBaseTween)

function MoveLocalYAnim:__Init(transform,toY,time)
    self.transform = transform
    self.toY = toY
    self.time = time
end

function MoveLocalYAnim:__Delete()
    
end

function MoveLocalYAnim:OnTween()
    local tween = self.transform:DOLocalMoveY(self.toY,self.time)
    return tween
end

function MoveLocalYAnim.Create(root,animData,nodes,animNodes)
    local transform = AnimUtils.GetComponent(root,animData.path)
    local anim = MoveLocalYAnim.New(transform,animData.toY,animData.time)
    return anim
end