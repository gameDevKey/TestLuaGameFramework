ShopRemindCtrl = BaseClass("ShopRemindCtrl",Controller)

function ShopRemindCtrl:__Init()
end

function ShopRemindCtrl:__Delete()

end

function ShopRemindCtrl:__InitComplete()

end

function ShopRemindCtrl:ShopNewUnit(info,data,protoId)
    for i, v in ipairs(ShopDefine.ShopOrder) do
        local shopData = mod.ShopProxy.shopData[v]
        for ii, gridData in ipairs(shopData) do
            local remindKey = ShopDefine.ShopType.choiceness.."_"..gridData.gridId
            if not gridData.itemInfo then
                info:SetFlag(false, remindKey)
            else
                local itemConf = Config.ItemData.data_item_info[gridData.itemInfo.itemId]
                if not mod.CollectionProxy:GetDataById(itemConf.item_attr) and itemConf.type == GDefine.ItemType.unitCard then
                    info:SetFlag(true, remindKey)
                else
                    info:SetFlag(false, remindKey)
                end
            end
        end
    end
end

function ShopRemindCtrl:ShopFreeCanBuy(info,data,protoId)

    for i, v in ipairs(ShopDefine.ShopOrder) do
        local shopData = mod.ShopProxy.shopData[v]
        for ii, gridData in ipairs(shopData) do
            local remindKey = v.."_"..gridData.gridId
            if not gridData.itemInfo then
                info:SetFlag(false, remindKey)
                return
            end
            if gridData.isBuy and gridData.isBuy == ShopDefine.IsBuy then
                info:SetFlag(false, remindKey)
            elseif TableUtils.IsEmpty(gridData.itemInfo.cost) and gridData.itemInfo.realCurrency == 0 then
                info:SetFlag(true, remindKey)
            end
        end
    end
end