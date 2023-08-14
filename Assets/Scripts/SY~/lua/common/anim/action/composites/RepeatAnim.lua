RepeatAnim = BaseClass("RepeatAnim",AnimBase)

--循环节点,只能有一个子节点
function RepeatAnim:__Init(anim,repeatNum)
    self.anim = anim
    self.repeatNum = repeatNum or 1
    self.repeatCount = 0
    self.playCount = 0
    self.isComplete = false
    if self.anim then self.anim:SetBaseComplete(self:ToFunc("OnPlayComplete")) end
end

function RepeatAnim:__Delete()
    
end

function RepeatAnim:Play()
    if not self.anim then
        self:Complete()
    else
        self:PlayAnim()
    end
end

function RepeatAnim:PlayAnim()
    self.playCount = self.playCount + 1
    self.anim:Play()
end

function RepeatAnim:OnPlayComplete()
    self.repeatCount = self.repeatCount + 1
    self.isComplete = self.repeatNum > 0 and self.repeatCount >= self.repeatNum

    if self.isComplete then
        self:Complete()
    else
        self:PlayAnim()
    end
end

function RepeatAnim:Complete()
    self.isComplete = false
    self.playCount = 0
    self.repeatCount = 0
    self:BaseComplete()
end

function RepeatAnim:Stop()
    if self.playCount <= 0 or self.isComplete then return end
    self.anim:Stop()
end

function RepeatAnim:Reset()
    if self.playCount <= 0 or self.isComplete then return end
    self.anim:Reset()
    self.playCount = 0
    self.repeatCount = 0
end

function RepeatAnim:Restart()
    if self.playCount <= 0 or self.isComplete then return end
    self.anim:Reset()
    self.playCount = 0
    self.repeatCount = 0
    self:Play()
end

function RepeatAnim:Clean()
    self.anim:Clean()
    self.repeatCount = 0
    self.playCount = 0
    self.isComplete = false
end

function RepeatAnim:Destroy()
    if self.anim then self.anim:Destroy() end
    self:Delete()
end

function RepeatAnim.Create(root,animData,nodes,animNodes)
    assert(#animData.childs <= 1,string.format("循环组件只能有一个子节点[%s]",animData.id))
    local childAnim = AnimUtils.CreateAnim(root,nodes[animData.childs[1]],nodes,animNodes)
    local anim = RepeatAnim.New(childAnim,animData.repeatNum)
    return anim
end