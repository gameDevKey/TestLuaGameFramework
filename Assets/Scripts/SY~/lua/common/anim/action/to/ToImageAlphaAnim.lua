ToImageAlphaAnim = BaseClass("ToImageAlphaAnim",AnimBaseTween)

--Text Image CanvasGroup Outline
function ToImageAlphaAnim:__Init(object,toAlpha,time)
    self.object = object
    self.toAlpha = toAlpha
    self.time = time
end

function ToImageAlphaAnim:__Delete()
    
end

function ToImageAlphaAnim:OnTween()
    local tween = self.object:DOFade(self.toAlpha,self.time)
    return tween
end

function ToImageAlphaAnim.Create(root,animData,nodes,animNodes)
    local component = AnimUtils.GetComponent(root,animData.path,Image)
    local anim = ToImageAlphaAnim.New(component,animData.toAlpha,animData.time)
    return anim
end