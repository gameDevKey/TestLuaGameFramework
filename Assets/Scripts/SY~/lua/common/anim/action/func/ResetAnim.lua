ResetAnim = BaseClass("ResetAnim",AnimBase)

function ResetAnim:__Init(root,resetFunc)
    self.root = root
    self.resetFunc = resetFunc
end

function ResetAnim:__Delete()
    
end

function ResetAnim:Play()
    if self.resetFunc then self.resetFunc(self.root) end
    self:BaseComplete()
end

function ResetAnim.Create(root,animData,nodes,animNodes)
    local anim = ResetAnim.New(root,animData.resetFunc)
    return anim
end