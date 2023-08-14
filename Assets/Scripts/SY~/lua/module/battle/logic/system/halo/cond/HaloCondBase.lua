HaloCondBase = BaseClass("HaloCondBase",SECBBase)

function HaloCondBase:__Init()
    self.halo = nil
    self.isActive = false
    self.eventUids = {}
end

function HaloCondBase:__Delete()
    
end

function HaloCondBase:Init(halo)
    self.halo = halo
    self:OnInit()
end

function HaloCondBase:AddEvent(event,callBack,args)
    local uid = self.world.EventTriggerSystem:AddListener(event,callBack,args)
    table.insert(self.eventUids,uid)
end

function HaloCondBase:ClearEvent()
    for _, uid in ipairs(self.eventUids) do
        self.world.EventTriggerSystem:RemoveListener(uid)
    end
    self.eventUids = {}
end


function HaloCondBase:Destroy()
    self:ClearEvent()
    self:OnDestroy()
end

--
function HaloCondBase:OnInit()
end

function HaloCondBase:SetIsValid(flag)
    self.halo.isValid = flag
end

function HaloCondBase:OnDestroy()
end