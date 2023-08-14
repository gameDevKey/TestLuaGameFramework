ToTextColorAnim = BaseClass("ToTextColorAnim",AnimBaseTween)

--Text Outline Image
function ToTextColorAnim:__Init(object,toColor,time)
    self.object = object
    self.toColor = toColor
    self.time = time
end

function ToTextColorAnim:__Delete()
    
end

function ToTextColorAnim:OnTween()
    local tween = self.object:DOColor(self.toColor,self.time)
    return tween
end

function ToTextColorAnim.Create(root,animData,nodes,animNodes)
    local component = AnimUtils.GetComponent(root,animData.path,Text)
    local anim = ToTextColorAnim.New(component,animData.toColor,animData.time)
    return anim
end