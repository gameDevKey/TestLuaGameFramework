ObtainProxy = BaseClass("ObtainProxy",Proxy)

function ObtainProxy:__Init()
    self.confObtainData = {}
end

function ObtainProxy:__InitProxy()
    --self:BindMsg(10106)
end

function ObtainProxy:__InitComplete()
    self.SetData(self)
end

function ObtainProxy:SetData()
    
end

function ObtainProxy:SetCradData(unitId)
    local cfg = Config.UnitData.data_unit_info[unitId]
    local cardData = mod.BackpackProxy:GetDataById(unitId)
    local allData = {}
    allData.cfg = cfg
    allData.cardData = cardData
    return allData
end