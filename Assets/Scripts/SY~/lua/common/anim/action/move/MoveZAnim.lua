MoveZAnim = BaseClass("MoveZAnim",AnimBaseTween)

function MoveZAnim:__Init(transform,toZ,time)
    self.transform = transform
    self.toZ = toZ
    self.time = time
end

function MoveZAnim:__Delete()
    
end

function MoveZAnim:OnTween()
    local tween = self.transform:DOMoveZ(self.toZ,self.time)
    return tween
end

function MoveZAnim.Create(root,animData,nodes,animNodes)
    local transform = AnimUtils.GetComponent(root,animData.path)
    local anim = MoveZAnim.New(transform,animData.toZ,animData.time)
    return anim
end