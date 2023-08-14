AnimComponent = BaseClass("AnimComponent",SECBComponent)

function AnimComponent:__Init()
    self.frame = 0
    self.layer = 0
    self.animName = nil
    self.isPlay = false
end

function AnimComponent:__Delete()
end

function AnimComponent:PlayAnim(animName)
    self.frame = 0
    self.layer = 0
    self.animName = animName
    self.isPlay = true
end

function AnimComponent:OnUpdate()
	if self.isPlay then
        self.isPlay = false
        self.frame = 0
        --self.entity.MoveComponent:ApplyAnim()
        self:ClientPlayAnim()
	end
	self.frame = self.frame + 1
end

function AnimComponent:GetClipTime(clipAnim)
    return 1000
end

function AnimComponent:ClientPlayAnim()
    if self.entity.clientEntity then
        self.entity.clientEntity.ClientAnimComponent:PlayAnim(self.animName)
    end
end