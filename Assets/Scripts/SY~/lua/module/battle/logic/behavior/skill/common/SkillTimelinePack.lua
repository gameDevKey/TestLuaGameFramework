SkillTimelinePack = BaseClass("SkillTimelinePack",SECBBehaviorPack)

function SkillTimelinePack:__Init()
end

function SkillTimelinePack:__Delete()
    if self.skillTimeline then
        self.skillTimeline:Delete()
    end
end

function SkillTimelinePack:OnInit(actConf,entity,skill,cb)
    self.skillTimeline = SkillTimeline.New()
    self.skillTimeline:SetWorld(self.world)
    self.skillTimeline:Init(actConf,entity,skill)
    self.skillTimeline:SetComplete(cb)
end

function SkillTimelinePack:OnStart(targetEntityUids,transInfo)
    self.skillTimeline:Start(targetEntityUids,transInfo)
end

function SkillTimelinePack:OnUpdate()
    if self.skillTimeline and not self.skillTimeline:IsFinish() then
        self.skillTimeline:Update(self.world.opts.frameDeltaTime)
    end
end

