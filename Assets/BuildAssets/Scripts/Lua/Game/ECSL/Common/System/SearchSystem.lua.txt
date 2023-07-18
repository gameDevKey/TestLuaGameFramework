SearchSystem = Class("SearchSystem",ECSLSystem)

function SearchSystem:OnInit()
end

function SearchSystem:OnDelete()
end

function SearchSystem:OnUpdate()
end

function SearchSystem:OnEnable()
end

---搜索所有符合条件的实体
---@param searchData table { entityUid, rangeData, matchPattern, ... }
----@inparam rangeData:table  { type, radius/... }
function SearchSystem:FindEntity(searchData)
    local entitys = self.world.EntitySystem:GetEntitys()
    local result = {}
    local data = {result=result,searchData=searchData}
    entitys:RangeByCallObject(CallObject.New(self:ToFunc("OnFindEntityByIter"),nil,data))
    return result
end

function SearchSystem:OnFindEntityByIter(args,iter)
    local result = args.result
    local searchData = args.searchData
    local range = searchData.rangeData
    local match = searchData.matchPattern
    local finderEntity = self.world.EntitySystem:GetEntity(searchData.entityUid)
    local curEntity = iter.value
    if not finderEntity or not curEntity or finderEntity == curEntity then
        return
    end
    if range then
        if range.type == RangeConfig.Type.Circle then
            -- 目标与我的距离小于等于半径
            local radius = range.radius
            local dis = ECSLUtil.GetEntityDis(finderEntity,curEntity)
            print("距离",finderEntity.uid,curEntity.uid,'==',dis)
            if dis <= radius then
                table.insert(result, curEntity:GetUid())
            end
        end
        --TODO...
    end
    --TODO match...
end

return SearchSystem