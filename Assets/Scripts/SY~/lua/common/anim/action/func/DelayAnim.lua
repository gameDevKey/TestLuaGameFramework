DelayAnim = BaseClass("DelayAnim",AnimBaseTween)

function DelayAnim:__Init(time)
    self.time = time
end

function DelayAnim:__Delete()
    
end

function DelayAnim:SetTime(time)
    self.time = time
end

function DelayAnim:OnTween()
    local tween = DOTweenEx.Delay(self.time)
    return tween
end

function DelayAnim.Create(root,animData,nodes,animNodes)
    local anim = DelayAnim.New(animData.time)
    return anim
end