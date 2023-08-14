ClientAnimComponent = BaseClass("ClientAnimComponent",SECBClientComponent)

function ClientAnimComponent:__Init()
    self.AnimComponent = nil
    self.animName = ""
    self.timeScale = 1
    self.moveTimeScale = 1
    self.animator = nil
    self.tempAnimator = nil

    self.pauseLockNum = 0
end

function ClientAnimComponent:__Delete()
    self.animator = nil
    self.tempAnimator = nil
end

function ClientAnimComponent:OnCreate()

end

function ClientAnimComponent:OnInit()
    self.AnimComponent = self.clientEntity.entity.AnimComponent

    self:MoveSpeedChange()
    if self.clientEntity.entity.AttrComponent then
        self.clientEntity.entity.AttrComponent:AddChangeListener(GDefine.Attr.move_speed,self:ToFunc("MoveSpeedChange"))
    end
end

function ClientAnimComponent:AddPauseLockNum(val)
    self.pauseLockNum = self.pauseLockNum + val
    if self.pauseLockNum == 0 then
        self:SetAnimSpeed()
    elseif self.pauseLockNum == 1 then
        self:SetAnimSpeed()
    end
end

function ClientAnimComponent:MoveSpeedChange()
    local moveSpeed = self.clientEntity.entity.AttrComponent:GetValue(GDefine.Attr.move_speed)
    self.moveTimeScale = 1--+ (moveSpeed - BattleDefine.AttrRatio) * 0.000025
    if self.moveTimeScale < 0 then
        self.moveTimeScale = 0
    elseif self.moveTimeScale > 3 then
        self.moveTimeScale = 3
    end
    
    self:SetAnimSpeed()
    --
end

function ClientAnimComponent:SetAnimator(animator)
    self.animator = animator
    self:PlayAnim(self.animName)
    self:SetTimeScale(self.timeScale)
end

function ClientAnimComponent:SetTempAnimator(tempAnimator)
    self.tempAnimator = tempAnimator
    self:PlayAnim(self.animName)
    self:SetTimeScale(self.timeScale)
end

function ClientAnimComponent:PlayAnim(animName)
    if animName == "" then
        return
    end
    self.animName = animName

    local animator = self.tempAnimator or self.animator

    if not animator then
        return
    end

	local layer = self.AnimComponent.layer
    
    animator:Play(animName)
    animator:CrossFadeInFixedTime(animName,0.1,layer,0)
	-- local time = self:GetTransition(layer,self.lastName,name)
	-- self.lastName = name
	-- animator:CrossFade(name,time,layer,0)

    self:SetAnimSpeed()
end

function ClientAnimComponent:GetClipTime(clip)
    local animator = self.tempAnimator or self.animator
    if animator then
        return BaseUtils.GetAnimatorClipTime(animator,clip)
    else
        return 0
    end
end

function ClientAnimComponent:SetTimeScale(timeScale)
    self.timeScale = timeScale
    self:SetAnimSpeed()
end

function ClientAnimComponent:SetAnimSpeed()
    local animator = self.tempAnimator or self.animator
    if animator then
        local timeScale = 1
        if self.pauseLockNum == 0 then
            timeScale = self.animName == BattleDefine.Anim.run and self.moveTimeScale or self.timeScale
        else
            timeScale = 0
        end
        animator.speed = timeScale
    end
end