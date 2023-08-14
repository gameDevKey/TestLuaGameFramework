ParallelAnim = BaseClass("ParallelAnim",AnimBase)

function ParallelAnim:__Init(anims)
    self.anims = anims
    self.animNum = #anims
    self.completeNum = 0
    self.completes = {}
    self.isComplete = false
    for i,anim in ipairs(self.anims) do anim:SetBaseComplete(self:ToFunc("OnPlayComplete"),i) end
end

function ParallelAnim:__Delete()
    for i,anim in ipairs(self.anims) do 
        anim:Delete()
    end
end

function ParallelAnim:Play()
    if self.animNum <= 0 then
        self:Complete()
    else
        for i,anim in ipairs(self.anims) do
            if not self.completes[i] then
                anim:Play() 
            end
        end
    end
end

function ParallelAnim:OnPlayComplete(index)
    self.completes[index] = true
    self.completeNum = self.completeNum + 1
    self.isComplete = self.completeNum >= self.animNum
    if self.isComplete then self:Complete() end
end

function ParallelAnim:Complete()
    self.completeNum = 0
    self.isComplete = false
    self.completes = {}
    self:BaseComplete()
end

function ParallelAnim:Stop()
    if self.animNum <= 0 or self.isComplete then return end
    for i,anim in ipairs(self.anims) do
        if not self.completes[i] then
            anim:Stop() 
        end
    end
end

function ParallelAnim:Reset()
    if self.animNum <= 0 or self.isComplete then return end
    for i,anim in ipairs(self.anims) do
        if not self.completes[i] then
            anim:Reset()
        end
    end
end

function ParallelAnim:Restart()
    if self.animNum <= 0 or self.isComplete then return end
    for i,anim in ipairs(self.anims) do
        if not self.completes[i] then
            anim:Reset() 
        end
    end
    self:Play()
end

function ParallelAnim:Clean()
    for i,anim in ipairs(self.anims) do anim:Clean() end
    self.completeNum = 0
    self.completes = {}
    self.isComplete = false
end

function ParallelAnim:Destroy()
    for _,anim in ipairs(self.anims) do anim:Destroy() end
    self:Delete()
end

function ParallelAnim.Create(root,animData,nodes,animNodes)
    local anims = {}
    for _,id in ipairs(animData.childs) do table.insert(anims,AnimUtils.CreateAnim(root,nodes[id],nodes,animNodes)) end
    local anim = ParallelAnim.New(anims)
    return anim
end