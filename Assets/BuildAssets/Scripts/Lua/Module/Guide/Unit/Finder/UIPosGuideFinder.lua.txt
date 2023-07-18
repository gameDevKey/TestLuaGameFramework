UIPosGuideFinder = Class("UIPosGuideFinder", GuideFinder)

function UIPosGuideFinder:OnInit()
    --TODO debug
    self.testTimer = 0
    self.testTime = 1
    self:Find(self.args.Type)
end

function UIPosGuideFinder:OnDelete()

end

function UIPosGuideFinder:Find(type)
    --TODO
end

function UIPosGuideFinder:OnUpdate(deltaTime)
    self.testTimer = self.testTimer + deltaTime
    if self.testTimer >= self.testTime then
        self:Finish({ x = 0, y = 0 })
    end
end

return UIPosGuideFinder
