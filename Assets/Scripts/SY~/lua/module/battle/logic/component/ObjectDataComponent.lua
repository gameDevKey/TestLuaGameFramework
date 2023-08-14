ObjectDataComponent = BaseClass("ObjectDataComponent",SECBComponent)

function ObjectDataComponent:__Init()
    self.objectData = nil
    self.baseConf = nil
    self.unitConf = nil

    self.roleUid = nil
    self.group = nil
    self.grid = nil
end

function ObjectDataComponent:__Delete()
end

function ObjectDataComponent:SetObjectData(data)
    self.objectData = data
end

function ObjectDataComponent:SetRoleUid(roleUid)
    self.roleUid = roleUid
end

function ObjectDataComponent:SetGroup(group)
    self.group = group
end

function ObjectDataComponent:SetGrid(grid)
    self.grid = grid
end

function ObjectDataComponent:SetBaseConf(conf)
    self.baseConf = conf
end

function ObjectDataComponent:SetUnitConf(conf)
    self.unitConf = conf
end

function ObjectDataComponent:GetStar()
    return self.objectData.star
end

function ObjectDataComponent:IsSameWalkType(walkType)
    return self.unitConf.walk_type == walkType
end

function ObjectDataComponent:GetWalkType()
    return self.unitConf.walk_type
end

function ObjectDataComponent:GetLifeType()
    return self.unitConf.life_type
end

function ObjectDataComponent:GetJob()
    return self.unitConf.job
end

function ObjectDataComponent:OnInit()

end

function ObjectDataComponent:GetSlot()
    return self.objectData.slot
end