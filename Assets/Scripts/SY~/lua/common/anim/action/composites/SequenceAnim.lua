SequenceAnim = BaseClass("SequenceAnim",AnimBase)

function SequenceAnim:__Init(anims)
    self.anims = anims
    self.animNum = #anims
    self.index = 0
    self.isComplete = false
    for i,anim in ipairs(self.anims) do anim:SetBaseComplete(self:ToFunc("OnPlayComplete")) end
end

function SequenceAnim:__Delete()
    
end

function SequenceAnim:Play()
    self:PlayAnim()
end

function SequenceAnim:PlayAnim()
    self.index = self.index + 1
    self.isComplete = self.index > self.animNum

    if self.isComplete then
        self:Complete()
    else
        self.anims[self.index]:Play()
    end
end

function SequenceAnim:OnPlayComplete()
    self:PlayAnim()
end

function SequenceAnim:Complete()
    self.index = 0
    self:BaseComplete()
end

function SequenceAnim:Stop()
    if self.index <= 0 or self.isComplete then return end
    self.anims[self.index]:Stop()
    self.index = self.index - 1
end

function SequenceAnim:Reset()
    if self.index <= 0 or self.isComplete then return end
    self.anims[self.index]:Reset()
    self.index = 0
end

--重新启动,还未播放完成,才能生效
function SequenceAnim:Restart()
    if self.index <= 0 or self.isComplete then return end
    self.anims[self.index]:Reset()
    self.index = self.index - 1
    self:Play()
end


function SequenceAnim:Clean()
    for i,anim in ipairs(self.anims) do anim:Clean() end
    self.index = 0
    self.isComplete = false
end

function SequenceAnim:Destroy()
    for _,anim in ipairs(self.anims) do anim:Destroy() end
    self:Delete()
end

function SequenceAnim.Create(root,animData,nodes,animNodes)
    local anims = {}
    for _,id in ipairs(animData.childs) do table.insert(anims,AnimUtils.CreateAnim(root,nodes[id],nodes,animNodes)) end
    local anim = SequenceAnim.New(anims)
    return anim
end