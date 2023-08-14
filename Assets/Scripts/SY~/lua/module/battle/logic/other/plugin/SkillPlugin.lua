SkillPlugin = BaseClass("SkillPlugin",SECBPlugin)

function SkillPlugin:__Init()
    self.skillCacheDicts = {}
end

function SkillPlugin:__Delete()
    for key, skill in pairs(self.skillCacheDicts) do
        skill:Delete()
    end
end

function SkillPlugin:AddSkillCache(key,skill)
    if self.skillCacheDicts[key] then
        assert(false,string.format("skillCacheDicts中已存在key为[%s]的skill",key))
        return
    end
    self.skillCacheDicts[key] = skill
end

function SkillPlugin:RemoveSkillCache(key)
    if not self.skillCacheDicts[key] then
        assert(false,string.format("skillCacheDicts中不存在key为[%s]的skill",key))
        return
    end
    self.skillCacheDicts[key] = nil
end