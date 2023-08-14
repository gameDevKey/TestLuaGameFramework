SelectAnim = BaseClass("SelectAnim",AnimBase)

function SelectAnim:__Init(anims,defaultIndex,onSelect)
    self.anims = anims
    self.animNum = #anims
    self.defaultIndex = defaultIndex
    self.onSelect = onSelect
    self.playIndex = nil
    for i,anim in ipairs(self.anims) do anim:SetBaseComplete(self:ToFunc("OnPlayComplete")) end
end

function SelectAnim:__Delete()
    
end

function SelectAnim:Play()
    if self.onSelect then self.playIndex = self.onSelect() end
    if not self.playIndex then self.playIndex = self.defaultIndex end

    if not self.playIndex or self.playIndex < 1 or self.playIndex > self.animNum then
        self:BaseComplete()
    else
        self.anims[self.playIndex]:Play()
    end
end

function SelectAnim:OnPlayComplete()
    self.playIndex = nil
    self:BaseComplete()
end

function SelectAnim:Stop()
    if not self.playIndex then return end
    self.anims[self.playIndex]:Stop()
    self.playIndex = nil
end

function SelectAnim:Reset()
    if not self.playIndex then return end
    self.anims[self.playIndex]:Stop()
    self.playIndex = nil
end

--重新启动,还未播放完成,才能生效
function SelectAnim:Restart()
    if not self.playIndex then return end
    self.anims[self.playIndex]:Reset()
    self.playIndex = nil
    self:Play()
end

function SelectAnim:Clean()
    if not self.playIndex then return end
    self.anims[self.playIndex]:Clean()
    self.playIndex = nil
end

function SelectAnim:Destroy()
    if not self.playIndex then return end
    self.anims[self.playIndex]:Destroy()
    self.playIndex = nil
    self:Delete()
end

function SelectAnim.Create(root,animData,nodes,animNodes)
    local anims = {}
    for _,id in ipairs(animData.childs) do table.insert(anims,AnimUtils.CreateAnim(root,nodes[id],nodes,animNodes)) end
    local anim = SelectAnim.New(anims,animData.defaultIndex)
    return anim
end