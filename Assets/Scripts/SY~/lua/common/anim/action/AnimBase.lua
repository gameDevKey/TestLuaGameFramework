AnimBase = BaseClass("AnimBase")

function AnimBase:__Init()
    self.id = nil
    self.onBaseComplete = nil
    self.onBaseCompleteArgs = nil

    self.onComplete = nil
    self.onCompleteArgs = nil
end

function AnimBase:__Delete()
    self:Clean()
end

function AnimBase:SetId(id)
    self.id = id
end

function AnimBase:SetBaseComplete(cb,args)
    self.onBaseComplete = cb
    self.onBaseCompleteArgs = args
end

function AnimBase:SetComplete(cb,args)
    self.onComplete = cb
    self.onCompleteArgs = args
end

function AnimBase:BaseComplete()
   self:NoticeBaseComplete()
   self:NoticeComplete()
end

function AnimBase:NoticeComplete()
    if not self.onComplete then return end
    self.onComplete(self.onCompleteArgs)
end

function AnimBase:NoticeBaseComplete()
    if not self.onBaseComplete then return end
    self.onBaseComplete(self.onBaseCompleteArgs)
end

function AnimBase:Destroy()
    self:Delete()
end

function AnimBase:SetAttr(name,value)
    self[name] = value
end

function AnimBase:BaseCreate(animData)
end

function AnimBase:Stop()end
function AnimBase:Reset()end
function AnimBase:Clean()end
function AnimBase:Restart()end