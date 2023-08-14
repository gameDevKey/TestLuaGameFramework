PveRemindCtrl = BaseClass("PveRemindCtrl",Controller)

function PveRemindCtrl:__Init()
end

function PveRemindCtrl:__Delete()

end

function PveRemindCtrl:__InitComplete()

end

function PveRemindCtrl:CheckPveSweep(info,data,protoId)
    if not mod.BattlePveProxy.pveProgress then
        return
    end

    local pveProgress = mod.BattlePveProxy.pveProgress

    local curConf = pveProgress.pve_id == 0 and Config.PveData.data_pve[1] or Config.PveData.data_pve[pveProgress.pve_id]
    local consumeGroup = curConf.sweep_consume_group
    local maxCount = Config.PveData.data_pve_sweep_max_count[consumeGroup]
    local sweepNum = maxCount - pveProgress.sweep_count
    local consumeKey = consumeGroup.."_"..tostring(pveProgress.sweep_count+1)
    local consumeConf = Config.PveData.data_pve_sweep_consume[consumeKey]
    if not consumeConf then
        consumeConf = Config.PveData.data_pve_sweep_consume[consumeGroup.."_"..tostring(pveProgress.sweep_count)]
    end
    local consume = consumeConf.consume
    if sweepNum <= 0 then
        info:SetFlag(false)
    else
        if TableUtils.IsEmpty(consume) then
            info:SetFlag(true)
        else
            local costItemId = consume[1][1]
            local costItemNum = consume[1][2]
            local itemNum = mod.RoleItemProxy:GetItemNum(costItemId)
            info:SetFlag(itemNum >= costItemNum)
        end
    end
end

function PveRemindCtrl:CheckPveAward(info,data,protoId)
    local pveProgress = mod.BattlePveProxy.pveProgress
    local nextChapterRewardPveId,nextChapterRewardPveConf = mod.BattlePveProxy:GetNextChapterRewardInfo(pveProgress.chapter_reward_top_pve_id)
    if not nextChapterRewardPveId or not nextChapterRewardPveConf then
        info:SetFlag(false)
    else
        local diff = nextChapterRewardPveId - pveProgress.pve_id
        info:SetFlag(diff <= 0)
    end
end