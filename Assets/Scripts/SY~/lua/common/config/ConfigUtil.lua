ConfigUtil = StaticClass("ConfigUtil")

---通过ItemId获取UnitData数据
---@param itemId any
---@return unknown
function ConfigUtil.GetUnitDataByItemId(itemId)
    local itemConfig = Config.ItemData.data_item_info[itemId]
    if not itemConfig then
        assert(false, string.format("无法找到ItemData[%s]",tostring(itemId)))
    end
    local unitConfig = Config.UnitData.data_unit_info[itemConfig.item_attr]
    return unitConfig
end

---获取卡牌拥有数量/上限/百分比
---@param unit_id any
---@return integer ownedAmount
---@return integer maxAmount
---@return integer percent
function ConfigUtil.GetUnitItemOwnedAmount(unit_id)
    local unitData = mod.CollectionProxy:GetDataById(unit_id)
    local level = unitData.level
    local ownedAmount = unitData.count
    local maxAmount = 0
    local percent = 1
    local key = string.format("%s_%s",tostring(unit_id),tostring(level+1))
    local nextLevInfo = Config.UnitData.data_unit_lev_info[key]
    if nextLevInfo then
        maxAmount = nextLevInfo.lv_up_count
        if maxAmount > 0 then
            percent = MathUtils.Clamp(ownedAmount/maxAmount,0,1)
        end
    end
    return ownedAmount,maxAmount,percent
end