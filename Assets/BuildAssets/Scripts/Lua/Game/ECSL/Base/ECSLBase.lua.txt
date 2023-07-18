ECSLBase = Class("ECSLBase",nil,{IWorld})
ECSLBase.TYPE = ECSLConfig.Type.Nil

function ECSLBase:OnInit()
    self:SetUid()
end

function ECSLBase:OnDelete()
end

function ECSLBase:SetUid(uid)
    self.uid = uid or ECSLUtil.GetUid(self.TYPE)
end

function ECSLBase:GetUid()
    return self.uid
end

return ECSLBase
