GuideFinder = Class("GuideFinder", GuideModuleBase)

function GuideFinder:OnInit(clip, args, callback)
    self.clip = clip
    self.args = args
    self.callback = callback
end

function GuideFinder:OnInitComplete()
end

function GuideFinder:OnDelete()
end

function GuideFinder:Finish(result)
    if self.callback then
        self.callback(result, self)
    end
end

return GuideFinder
