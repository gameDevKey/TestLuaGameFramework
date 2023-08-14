TipsCtrl = BaseClass("TipsCtrl",Controller)

function TipsCtrl:__Init()

end

function TipsCtrl:__Delete()

end

function TipsCtrl:__InitComplete()

end

function TipsCtrl:OpenItemTips(data,parent)
    local conf = Config.ItemData.data_item_info[data.item_id]
    if not conf then
        LogErrorAny("无法获取ItemData:",data.item_id)
        return
    end
    if conf.type == GDefine.ItemType.equip then
        local equipTips = EquipTips.New()
        equipTips:SetParent(UIDefine.canvasRoot)
        equipTips:SetData(data,parent)
        equipTips:Show()
    else
        local equipTips = PropTips.New()
        equipTips:SetParent(UIDefine.canvasRoot)
        equipTips:SetData(data,parent)
        equipTips:Show()
    end
end

function TipsCtrl:OpenSkillTips(data,parent)
    local skillTips = SkillTips.New()
    skillTips:SetParent(UIDefine.canvasRoot)
    skillTips:SetData(data,parent)
    skillTips:Show()
end


function TipsCtrl:OpenTipsWindowById(tipsId,parent)
    ViewManager.Instance:CloseWindow(DescTipsWindow)
    ViewManager.Instance:OpenWindow(DescTipsWindow, {
        tipsId = tipsId, parent = parent
    })
end

function TipsCtrl:OpenTipsWindow(title,content,parent)
    ViewManager.Instance:CloseWindow(DescTipsWindow)
    ViewManager.Instance:OpenWindow(DescTipsWindow, {
        title = title, content = content, parent = parent
    })
end

--点击道具弹出提示的统一处理
function TipsCtrl:OpenTipsByItemId(itemId,parent)
    parent = parent or UIDefine.canvasRoot
    local itemInfo = Config.ItemData.data_item_info[itemId]
    if itemInfo then
        if itemInfo.type == GDefine.ItemType.chest then
            local cfg = mod.ChestProxy:GetChestCfgById(itemId)--TODO ItemId就是ChestId，讨论过不做映射了，先这样处理吧
            ViewManager.Instance:OpenWindow(ChestDetailsWindow,{cfg=cfg})
        elseif itemInfo.type == GDefine.ItemType.unitCard then
            local panel = BattleHeroDetailsPanel.New()
            panel:SetParent(UIDefine.canvasRoot)
            panel:SetMainData(itemInfo.item_attr,1,1)
            panel:SetDestroyOnClose(true)
            panel:Show()
        else
            -- self:OpenTipsWindow(itemInfo.name,itemInfo.desc,parent)
            if itemInfo.type ~= GDefine.ItemType.equip then
                local equipTips = PropTips.New()
                equipTips:SetParent(UIDefine.canvasRoot)
                equipTips:SetData({item_id = itemId},parent)
                equipTips:Show()
            else
                LogErrorAny("装备类型道具Tips未处理")
            end
        end
    else
        LogErrorAny("道具弹出提示错误: 找不到ItemData", itemId, parent)
    end
end