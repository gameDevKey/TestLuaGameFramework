TweenMoveAnchorAnim = BaseClass("TweenMoveAnchorAnim",TweenAnimBase)

---锚点移动动画
---@param transform RectTransform
---@param toValue Vector2
---@param time number
function TweenMoveAnchorAnim:__Init(transform,toValue,time)
end

function TweenMoveAnchorAnim:__Delete()
end

function TweenMoveAnchorAnim:OnCreate(...)
    return DOTweenAnimEx.CreateMoveAnchorAnim(...)
end