TweenMove3DAnchorAnim = BaseClass("TweenMove3DAnchorAnim",TweenAnimBase)

---3D锚点移动动画
---@param transform RectTransform
---@param toValue Vector3
---@param time number
function TweenMove3DAnchorAnim:__Init(transform,toValue,time)
end

function TweenMove3DAnchorAnim:__Delete()
end

function TweenMove3DAnchorAnim:OnCreate(...)
    return DOTweenAnimEx.CreateMoveAnchor3DAnim(...)
end