TweenScaleAnim = BaseClass("TweenScaleAnim",TweenAnimBase)

---缩放动画
---@param transform Transform
---@param toValue Vector3
---@param time number
function TweenScaleAnim:__Init(transform,toValue,time)
end

function TweenScaleAnim:__Delete()
end

function TweenScaleAnim:OnCreate(...)
    return DOTweenAnimEx.CreateScaleAnim(...)
end