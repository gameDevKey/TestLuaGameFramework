ChangeScaleBuffBehavior = BaseClass("ChangeScaleBuffBehavior",BuffBehavior)

function ChangeScaleBuffBehavior:__Init()
    self.addState = false
end

function ChangeScaleBuffBehavior:__Delete()
end

function ChangeScaleBuffBehavior:OnExecute()
    if not self.addState then
        self.addState = true
        local ratio = self.actionParam.ratio
        self.entity.TransformComponent:SetScaleByOffset(ratio)
    end
    return true
end

function ChangeScaleBuffBehavior:OnDestroy()
    if self.addState then
        self.addState = false
        local ratio = self.actionParam.ratio
        self.entity.TransformComponent:SetScaleByOffset(-ratio)
    end
end