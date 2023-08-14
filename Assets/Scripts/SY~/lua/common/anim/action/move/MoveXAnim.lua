MoveXAnim = BaseClass("MoveXAnim",AnimBaseTween)

function MoveXAnim:__Init(transform,toX,time)
    self.transform = transform
    self.toX = toX
    self.time = time
end

function MoveXAnim:__Delete()
    
end

function MoveXAnim:OnTween()
    local tween = self.transform:DOMoveX(self.toX,self.time)
    return tween
end

function MoveXAnim.Create(root,animData,nodes,animNodes)
    local transform = AnimUtils.GetComponent(root,animData.path)
    local anim = MoveXAnim.New(transform,animData.toX,animData.time)
    return anim
end