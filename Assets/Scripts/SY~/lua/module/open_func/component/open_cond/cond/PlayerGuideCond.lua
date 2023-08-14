PlayerGuideCond = StaticClass("PlayerGuideCond")


function PlayerGuideCond.HasFinishGroup(cond)
    local maxGroup = -1
    for _,guideGroup in ipairs(mod.PlayerGuideProxy.guideDatas.guide_list or {}) do
        if guideGroup == cond.group then
            return true
        end
        if guideGroup > maxGroup then
            maxGroup = guideGroup
        end
    end
    if cond.group <= 0 then
        -- 判断是否完成了所有引导
        local maxConfigGroup = -1
        for group,_ in ipairs(mod.PlayerGuideData.data_guide_group_info or {}) do
            if group > maxConfigGroup then
                maxConfigGroup = group
            end
        end
        return maxConfigGroup == maxGroup
    end
    return false
end