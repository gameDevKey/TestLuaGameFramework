ToImageColorAnim = BaseClass("ToImageColorAnim",AnimBaseTween)

--Text Outline Image
function ToImageColorAnim:__Init(object,toColor,time)
    self.object = object
    self.toColor = toColor
    self.time = time
end

function ToImageColorAnim:__Delete()
    
end

function ToImageColorAnim:OnTween()
    local tween = self.object:DOColor(self.toColor,self.time)
    return tween
end

function ToImageColorAnim.Create(root,animData,nodes,animNodes)
    local component = AnimUtils.GetComponent(root,animData.path,Image)
    local anim = ToImageColorAnim.New(component,animData.toColor,animData.time)
    return anim
end