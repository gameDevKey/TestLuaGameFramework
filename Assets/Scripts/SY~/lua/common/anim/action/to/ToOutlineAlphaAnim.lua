ToOutlineAlphaAnim = BaseClass("ToOutlineAlphaAnim",AnimBaseTween)

--Text Image CanvasGroup Outline
function ToOutlineAlphaAnim:__Init(object,toAlpha,time)
    self.object = object
    self.toAlpha = toAlpha
    self.time = time
end

function ToOutlineAlphaAnim:__Delete()
    
end

function ToOutlineAlphaAnim:OnTween()
    local tween = self.object:DOFade(self.toAlpha,self.time)
    return tween
end

function ToOutlineAlphaAnim.Create(root,animData,nodes,animNodes)
    local component = AnimUtils.GetComponent(root,animData.path,Outline)
    local anim = ToOutlineAlphaAnim.New(component,animData.toAlpha,animData.time)
    return anim
end