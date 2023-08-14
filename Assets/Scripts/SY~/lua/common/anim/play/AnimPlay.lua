AnimPlay = BaseClass("AnimPlay")

function AnimPlay:__Init()
    self.anims = {} -- 保存n组动画
    self.animArray = {} --数组形式保存,为了一些地方保证顺序执行
    self.animNodes = {}

    self.playRecords = {}
    self.playingAnims = {}
    self.resetDataAnims = {}

    self.onResetData = nil
    self.onResetDataArgs = nil

    self.onComplete = nil
    self.onCompleteArgs = nil
end

function AnimPlay:__Delete()
    
end

--cb
function AnimPlay:LoadAnim(name,root,preNotices)
    root = root.transform
    local config = GetClass(name)
    for _,v in ipairs(config.anims) do
        local animData = v.nodes[v.rootId]
        local anim = AnimUtils.CreateAnim(root,animData,v.nodes,self.animNodes,loadNotices)
        self:AddAnim(anim,v.name)
    end
end

function AnimPlay:Destroy()
    for i,v in ipairs(self.animArray) do
        v.anim:Destroy()
    end
end

function AnimPlay:SetResetData(cb,args)
    self.onResetData = cb
    self.onResetDataArgs = args
end

function AnimPlay:SetComplete(cb,args)
    self.onComplete = cb
    self.onCompleteArgs = args
end

function AnimPlay:AddAnim(anim,animName)
    if not animName then animName = self:GetDefaultName() end
    assert(not self.anims[animName],string.format("已存在动画组名[%s]",animName))
    anim:SetBaseComplete(self:ToFunc("OnComolete"),animName)
    self.anims[animName] = anim
    table.insert(self.animArray,{animName = animName,anim = anim} )
end

--播放
function AnimPlay:Play(animName)
    if not animName then animName = self:GetDefaultName() end
    assert(self.anims[animName] ~= nil,string.format("不存在动画组[%s]",animName))
    self:PlayAnim(animName)
end

function AnimPlay:PlayAll()
    for i,v in ipairs(self.animArray) do
        self:PlayAnim(v.animName)
    end
end

function AnimPlay:PlayAnim(animName)
    if self.playingAnims[animName] then return end
    self.playingAnims[animName] = true
    self:NoticeResetData(animName)
    self.anims[animName]:Play()
    if not self.playRecords[animName] then self.playRecords[animName] = true end
end

function AnimPlay:OnComolete(animName)
    self.playingAnims[animName] = nil
    self.resetDataAnims[animName] = nil
    self:NoticeComplete(animName)
end

--停止动画
function AnimPlay:Stop(animName)
    if not animName then animName = self:GetDefaultName() end
    assert(self.anims[animName] ~= nil,string.format("不存在动画组[%s]",animName))
    self:StopAnim(animName)
end

function AnimPlay:StopAll()
    for i,v in ipairs(self.animArray) do
        self:StopAnim(v.animName)
    end
end

function AnimPlay:StopAnim(animName)
    if not self.playingAnims[animName] then return end
    self.anims[animName]:Stop()
    self.playingAnims[animName] = nil
end

--重置
function AnimPlay:Reset(animName)
    if not animName then animName = self:GetDefaultName() end
    assert(self.anims[animName] ~= nil,string.format("不存在动画组[%s]",animName))
    self:ResetAnim(animName)
end

function AnimPlay:ResetAll()
    for i,v in ipairs(self.animArray) do
        self:ResetAnim(v.animName)
    end
end

function AnimPlay:ResetAnim(animName)
    if not self.playingAnims[animName] then return end
    self.anims[animName]:Reset()
    self.playingAnims[animName] = nil
end

--清理
function AnimPlay:Clean(animName)
    if not animName then animName = self:GetDefaultName() end
    assert(self.anims[animName] ~= nil,string.format("不存在动画组[%s]",animName))
    self:CleanAnim(animName)
end

function AnimPlay:CleanAll()
    for i,v in ipairs(self.animArray) do
        self:CleanAnim(v.animName)
    end
end

function AnimPlay:CleanAnim(animName)
    if not self.playRecords[animName] then return end
    self.anims[animName]:Clean()
    self.playRecords[animName] = nil
    self.playingAnims[animName] = nil
    self.resetDataAnims[animName] = nil
end

function AnimPlay:NoticeResetData(animName)
    if not self.onResetData then return end
    if self.resetDataAnims[animName] then return end
    self.resetDataAnims[animName] = true
    self.onResetData(animName,self.onResetDataArgs)
end

function AnimPlay:NoticeComplete(animName)
    if not self.onComplete then return end
    self.onComplete(animName,self.onCompleteArgs)
end

function AnimPlay:GetDefaultName()
    return "default"
end

function AnimPlay:GetAnimNode(id)
    return self.animNodes[id]
end