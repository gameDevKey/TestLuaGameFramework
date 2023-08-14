TweenDelayAnim = BaseClass("TweenDelayAnim",TweenAnimBase)

---延时
---@param time number
function TweenDelayAnim:__Init(time)
end

function TweenDelayAnim:__Delete()
end

function TweenDelayAnim:OnCreate(...)
    return DOTweenAnimEx.CreateDelayAnim(...)
end