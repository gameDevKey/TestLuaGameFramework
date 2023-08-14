RaceTypeNumCond = BaseClass("RaceTypeNumCond",HaloCondBase)

function RaceTypeNumCond:__Init()
    self.requiredTypeNum = {}
    self.curTypeNum = nil
end

function RaceTypeNumCond:OnInit()
    local eventParam = {}
    eventParam.camp = self.halo.camp
    eventParam.raceTypeList = {}
    for k, v in pairs(self.halo.conf.cond_args) do
        -- local subCond = {}
        -- for k1, v1 in pairs(v) do -- TODO 三重括号 or
        --     subCond[v1[1]] = v1[2]
        --     table.insert(eventParam.raceTypeList,v1[1])
        -- end
        table.insert(eventParam.raceTypeList,v[1])
        self.requiredTypeNum[v[1]] = v[2]
    end
    self:AddEvent(BattleEvent.place_unit,self:ToFunc("OnEvent"),eventParam)
    self:AddEvent(BattleEvent.cancel_unit,self:ToFunc("OnEvent"),eventParam)
    self:OnEvent()
end

function RaceTypeNumCond:OnEvent()
    local curTypeNum = self.world.BattleHaloSystem:GetCurTypeNum(self.halo.roleUid)

    -- TODO 三重括号 or
    -- local validList = {}
    -- for i = 1, #self.requiredTypeNum do
    --     local subValid = true
    --     local subCond = self.requiredTypeNum[i]
    --     -- LogTable("curTypeNum",curTypeNum)--TODO Log
    --     -- LogTable("subCond",subCond)--TODO Log
    --     for k, v in pairs(subCond) do
    --         if not curTypeNum[k] then
    --             -- LogError("not curTypeNum["..k.."]")--TODO Log
    --             subValid = false
    --         else
    --             if curTypeNum[k] < v then
    --                 -- LogError("curTypeNum[v[1]] < v[2]",curTypeNum[k],v)--TODO Log
    --                 subValid = false
    --             end
    --         end
    --     end
    --     table.insert(validList,subValid)
    -- end
    -- local valid = false
    -- for k, v in pairs(validList) do
    --     if v then
    --         valid = true
    --         break
    --     end
    -- end

    local valid = true
    for k, v in pairs(self.requiredTypeNum) do
        if not curTypeNum[k] then
            valid = false
            break
        else
            if curTypeNum[k] < v then
                valid = false
                break
            end
        end
    end
    self:SetIsValid(valid)
    -- LogError(">>>>>>>>>>Final Valid",tostring(valid))--TODO Log
end