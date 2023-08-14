CallBackAnim = BaseClass("CallBackAnim",AnimBaseTween)

function CallBackAnim:__Init(time,cb)
    self.time = time
    self.callBack = cb
end

function CallBackAnim:__Delete()
    
end

function CallBackAnim:OnTween()
    local tween = DOTweenEx.Delay(self.time)
    tween:OnStepComplete(self:ToFunc("OnTrigger"))
    return tween
end

function CallBackAnim:OnTrigger()
    if not self.callBack then return end
    self.callBack()
end

function CallBackAnim:SetCallBack(cb)
    self.callBack = cb
end

function CallBackAnim.Create(root,animData,nodes,animNodes)
    local anim = CallBackAnim.New(animData.time)
    return anim
end