TweenMoveAnchorXAnim = BaseClass("TweenMoveAnchorXAnim",TweenAnimBase)

---锚点移动动画(X轴)
---@param transform RectTransform
---@param toValue float
---@param time number
function TweenMoveAnchorXAnim:__Init(transform,toValue,time)
end

function TweenMoveAnchorXAnim:__Delete()
end

function TweenMoveAnchorXAnim:OnCreate(transform,toValue,time)
    local vec = Vector2(toValue, transform.anchoredPosition.y)
    return DOTweenAnimEx.CreateMoveAnchorAnim(transform,vec,time)
end