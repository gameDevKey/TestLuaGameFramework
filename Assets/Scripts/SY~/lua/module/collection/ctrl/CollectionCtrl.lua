CollectionCtrl = BaseClass("CollectionCtrl",Controller)

function CollectionCtrl:__Init()
end

function CollectionCtrl:__Delete()
end

function CollectionCtrl:UpgradeCard(id)
    mod.CollectionFacade:SendMsg(10202, id)
end

function CollectionCtrl:ReplaceEmbattleCard(id)
    mod.CollectionFacade:SendEvent(CollectionEmbattleView.Event.ReplaceEmbattleCard, id)
end

function CollectionCtrl:CancelOperate()
    mod.BattleFacade:SendEvent(BattleFacade.Event.CancelOperate)
end

function CollectionCtrl:SwitchBesideUnitDetails(unitId, besideFlag)
    local findList = nil
    local isEmbattled = mod.CollectionProxy:IsEmbattled(unitId)
    if isEmbattled then
        findList = mod.CollectionProxy:GetEmbattleGroupData().embattleGroupData
    else
        findList = mod.CollectionProxy:GetSortedOrder()
    end

    if #findList <= 1 then
        return
    end

    local index = nil
    for i, v in ipairs(findList) do
        local tempUnitId = isEmbattled and v.unit_id or v
        if tempUnitId == unitId then
            index = i
        end
    end

    index = index + besideFlag
    if index < 1 then
        index = #findList
    elseif index > #findList then
        index = 1
    end

    mod.CollectionFacade:SendEvent(CollectionDetailsWindow.Event.ResetDetailsData, isEmbattled and findList[index].unit_id or findList[index])
end