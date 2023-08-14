TweenMove3DAnchorXAnim = BaseClass("TweenMove3DAnchorXAnim",TweenAnimBase)

---3D锚点移动动画(X轴)
---@param transform RectTransform
---@param toValue float
---@param time number
function TweenMove3DAnchorXAnim:__Init(transform,toValue,time)
end

function TweenMove3DAnchorXAnim:__Delete()
end

function TweenMove3DAnchorXAnim:OnCreate(transform,toValue,time)
    local vec = Vector3(toValue, transform.anchoredPosition3D.y, transform.anchoredPosition3D.z)
    return DOTweenAnimEx.CreateMoveAnchor3DAnim(transform,vec,time)
end