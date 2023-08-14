ToAlphaAnim = BaseClass("ToAlphaAnim",AnimBaseTween)

--Text Image CanvasGroup Outline
function ToAlphaAnim:__Init(object,toAlpha,time)
    self.object = object
    self.toAlpha = toAlpha
    self.time = time
end

function ToAlphaAnim:__Delete()
    
end

function ToAlphaAnim:OnTween()
    local tween = self.object:DOFade(self.toAlpha,self.time)
    return tween
end

function ToAlphaAnim.Create(root,animData,nodes,animNodes)
    local component = AnimUtils.GetComponent(root,animData.path,animData.component)
    local anim = ToAlphaAnim.New(component,animData.toAlpha,animData.time)
    return anim
end