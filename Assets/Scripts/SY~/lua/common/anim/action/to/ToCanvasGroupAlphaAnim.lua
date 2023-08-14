ToCanvasGroupAlphaAnim = BaseClass("ToCanvasGroupAlphaAnim",AnimBaseTween)

--Text Image CanvasGroup Outline
function ToCanvasGroupAlphaAnim:__Init(object,toAlpha,time)
    self.object = object
    self.toAlpha = toAlpha
    self.time = time
end

function ToCanvasGroupAlphaAnim:__Delete()
    
end

function ToCanvasGroupAlphaAnim:OnTween()
    local tween = self.object:DOFade(self.toAlpha,self.time)
    return tween
end

function ToCanvasGroupAlphaAnim.Create(root,animData,nodes,animNodes)
    local component = AnimUtils.GetComponent(root,animData.path,CanvasGroup)
    local anim = ToCanvasGroupAlphaAnim.New(component,animData.toAlpha,animData.time)
    return anim
end