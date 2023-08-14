ObtainSecProxy = BaseClass("ObtainSecProxy",Proxy)

function ObtainSecProxy:__Init()
    self.confObtainData = {}
end

function ObtainSecProxy:__InitProxy()
    --self:BindMsg(10106)
end

function ObtainSecProxy:__InitComplete()
    self.SetData(self)
end

function ObtainSecProxy:SetData()
    
end

function ObtainSecProxy:SetCradData(unitId)
    local cfg = Config.UnitData.data_unit_info[unitId]
    local cardData = mod.BackpackProxy:GetDataById(unitId)
    local allData = {}
    allData.cfg = cfg
    allData.cardData = cardData
    return allData
end