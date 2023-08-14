TweenColorAnim = BaseClass("TweenColorAnim",TweenAnimBase)

---颜色渐变动画
---@param graphic Graphic
---@param toValue Color
---@param time number
function TweenColorAnim:__Init(graphic,toValue,time)
end

function TweenColorAnim:__Delete()
end

function TweenColorAnim:OnCreate(...)
    return DOTweenAnimEx.CreateColorAnim(...)
end