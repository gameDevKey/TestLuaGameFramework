CampComponent = BaseClass("CampComponent",SECBComponent)

function CampComponent:__Init()
    self.camp = nil
    self.tempCamp = nil
end

function CampComponent:__Delete()
end

function CampComponent:OnInit()

end

function CampComponent:SetCamp(camp)
    self.camp = camp
end

function CampComponent:SetTempCamp(camp)
    self.tempCamp = camp
end

function CampComponent:GetCamp()
    return self.tempCamp or self.camp
end

function CampComponent:GetEnemyCamp()
    return self.camp == BattleDefine.Camp.attack and BattleDefine.Camp.defence or BattleDefine.Camp.attack
end

function CampComponent.GetEnemyCampByCamp(camp)
    return camp == BattleDefine.Camp.attack and BattleDefine.Camp.defence or BattleDefine.Camp.attack
end

function CampComponent:IsCamp(camp)
    return self:GetCamp() == camp
end

---是否某个玩家的阵营
---@param roleUid number 玩家Uid
---@return boolean
function CampComponent:IsLocalCamp(roleUid)
    roleUid = roleUid or self.world.BattleDataSystem.roleUid
    local selfCamp = self.world.BattleDataSystem:GetCampByRoleUid(roleUid)
    return self:IsCamp(selfCamp)
end