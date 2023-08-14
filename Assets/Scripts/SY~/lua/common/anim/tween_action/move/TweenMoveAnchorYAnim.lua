TweenMoveAnchorYAnim = BaseClass("TweenMoveAnchorYAnim",TweenAnimBase)

---锚点移动动画(Y轴)
---@param transform RectTransform
---@param toValue float
---@param time number
function TweenMoveAnchorYAnim:__Init(transform,toValue,time)
end

function TweenMoveAnchorYAnim:__Delete()
end

function TweenMoveAnchorYAnim:OnCreate(transform,toValue,time)
    local vec = Vector2(transform.anchoredPosition.x, toValue)
    return DOTweenAnimEx.CreateMoveAnchorAnim(transform,vec,time)
end