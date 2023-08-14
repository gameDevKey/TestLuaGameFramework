TweenGraphicAlphaAnim = BaseClass("TweenGraphicAlphaAnim",TweenAnimBase)

---Graphic透明度渐变动画
---@param graphic Graphic
---@param alpha number 透明度(0~255)
---@param time number
function TweenGraphicAlphaAnim:__Init(graphic,alpha,time)
end

function TweenGraphicAlphaAnim:__Delete()
end

function TweenGraphicAlphaAnim:OnCreate(graphic,alpha,time)
    local color = graphic.color
    local toColor = Color(color.r,color.g,color.b,alpha/255)
    return DOTweenAnimEx.CreateColorAnim(graphic,toColor,time)
end