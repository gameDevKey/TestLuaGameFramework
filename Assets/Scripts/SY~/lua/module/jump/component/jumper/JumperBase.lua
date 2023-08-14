JumperBase = BaseClass("JumperBase")

function JumperBase:__Init()
    self.jumpId = nil
    self.info = nil
    self.conf = nil
end

function JumperBase:__Delete()

end

function JumperBase:Init(jumpId,info,...)
    self.jumpId = jumpId
    self.info = info
    self.conf = Config.JumpData.data_jump_info[guideId]
    self:OnInit(...)
end

function JumperBase:Start()
    self:OnStart()    
end

function JumperBase:Destroy()
    self:OnDestroy()
    self:Delete()
end

----------------------------------------------------------------------------------
function JumperBase:OnInit()
end

function JumperBase:OnStart()
end

function JumperBase:OnDestroy()
end