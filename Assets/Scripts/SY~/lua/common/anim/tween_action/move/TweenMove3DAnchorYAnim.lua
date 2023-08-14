TweenMove3DAnchorYAnim = BaseClass("TweenMove3DAnchorYAnim",TweenAnimBase)

---3D锚点移动动画(Y轴)
---@param transform RectTransform
---@param toValue float
---@param time number
function TweenMove3DAnchorYAnim:__Init(transform,toValue,time)
end

function TweenMove3DAnchorYAnim:__Delete()
end

function TweenMove3DAnchorYAnim:OnCreate(transform,toValue,time)
    local vec = Vector3(transform.anchoredPosition3D.x, toValue, transform.anchoredPosition3D.z)
    return DOTweenAnimEx.CreateMoveAnchor3DAnim(transform,vec,time)
end