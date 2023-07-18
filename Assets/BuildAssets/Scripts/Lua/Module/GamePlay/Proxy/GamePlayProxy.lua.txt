GamePlayProxy = SingletonClass("GamePlayProxy",ProxyBase)

function GamePlayProxy:OnInitComplete()
end

function GamePlayProxy:OnDelete()
end

function GamePlayProxy:GetSkillData(skillId)
    --Test
    local data = {}
    data.skillId = skillId
    data.skillLv = 1
    data.cd = 1000
    return data
end

return GamePlayProxy