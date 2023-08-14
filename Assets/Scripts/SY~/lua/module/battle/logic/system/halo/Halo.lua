Halo = BaseClass("Halo",SECBBase)

function Halo:__Init()
    self.uid = 0
    self.roleUid = nil
    self.camp = nil
    self.unitId = nil
    self.haloId = 0
    self.haloLev = 0
    self.conf = nil
    self.condAction = nil
    self.isValid = false
    self.eventList = {}
end

function Halo:__Delete()
    if self.condAction then
        self.condAction:Delete()
    end
end

function Halo:Init(haloInfo,uid,roleUid,camp,unitId,skill)
    -- LogTable("Halo.haloInfo",haloInfo)
    self.haloId = haloInfo[1]
    self.haloLev = haloInfo[2]
    self.uid = uid
    self.roleUid = roleUid
    self.camp = camp
    self.unitId = unitId
    self.from = {roleUid = roleUid,camp = camp,unitId = unitId,skill = skill}
    self.conf = self.world.BattleConfSystem:HaloData_data_halo_info(self.haloId,self.haloLev)
    if self.conf == nil then
        assert(false,string.format("不存在的光环配置[光环Id:%s]",self.haloId))
    end

    self:InitCond()
    if not self.condAction then
        self.isValid = true
    end
end

function Halo:InitCond()
    local confCond = self.conf.cond_type
    if StringUtils.IsEmpty(confCond) then
        return
    end

    local class = nil
    if MagicEventDefine.HaloCondIndex[confCond] then
        class = _G[MagicEventDefine.HaloCondIndex[confCond]]
    end
    if class == nil then
        assert(false,string.format("光环触发条件，不存在映射[映射条件:%s]",tostring(confCond)))
    end

    self.condAction = class.New()
    self.condAction:SetWorld(self.world)
    self.condAction:Init(self)
end

function Halo:UpdateLogic()
    if self.condAction then
        self.condAction:Update()
    end
end

function Halo:OnActive()
    for _, eventId in ipairs(self.conf.event_list) do
        local event = self.world.BattleMagicEventSystem:AddMagicEvent(eventId,self.from)
        table.insert(self.eventList,event.uid)
    end
end

function Halo:InActive()
    for _, v in ipairs(self.eventList) do
        self.world.BattleMagicEventSystem:RemoveMagicEvent(v)
    end
    self.eventList = {}
end

function Halo:Destroy()
    self:InActive()
    if self.condAction then
        self.condAction:Destroy()
    end
end