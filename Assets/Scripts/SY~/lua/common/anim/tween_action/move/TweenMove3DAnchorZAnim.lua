TweenMove3DAnchorZAnim = BaseClass("TweenMove3DAnchorZAnim",TweenAnimBase)

---3D锚点移动动画(Z轴)
---@param transform RectTransform
---@param toValue float
---@param time number
function TweenMove3DAnchorZAnim:__Init(transform,toValue,time)
end

function TweenMove3DAnchorZAnim:__Delete()
end

function TweenMove3DAnchorZAnim:OnCreate(transform,toValue,time)
    local vec = Vector3(transform.anchoredPosition3D.x, transform.anchoredPosition3D.y, toValue)
    return DOTweenAnimEx.CreateMoveAnchor3DAnim(transform,vec,time)
end