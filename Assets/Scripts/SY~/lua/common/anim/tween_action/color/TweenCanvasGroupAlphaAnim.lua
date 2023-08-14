TweenCanvasGroupAlphaAnim = BaseClass("TweenCanvasGroupAlphaAnim",TweenAnimBase)

---CanvasGroup透明度渐变动画
---@param canvasGroup CanvasGroup
---@param alpha number 透明度(0~255)
---@param time number
function TweenCanvasGroupAlphaAnim:__Init(canvasGroup,alpha,time)
end

function TweenCanvasGroupAlphaAnim:__Delete()
end

function TweenCanvasGroupAlphaAnim:OnCreate(canvasGroup,alpha,time)
    return DOTweenAnimEx.CreateCanvasGroupAlphaAnim(canvasGroup,alpha/255,time)
end