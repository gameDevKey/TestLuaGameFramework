ToTextAlphaAnim = BaseClass("ToTextAlphaAnim",AnimBaseTween)

--Text Image CanvasGroup Outline
function ToTextAlphaAnim:__Init(object,toAlpha,time)
    self.object = object
    self.toAlpha = toAlpha
    self.time = time
end

function ToTextAlphaAnim:__Delete()
    
end

function ToTextAlphaAnim:OnTween()
    local tween = self.object:DOFade(self.toAlpha,self.time)
    return tween
end

function ToTextAlphaAnim.Create(root,animData,nodes,animNodes)
    local component = AnimUtils.GetComponent(root,animData.path,Text)
    local anim = ToTextAlphaAnim.New(component,animData.toAlpha,animData.time)
    return anim
end