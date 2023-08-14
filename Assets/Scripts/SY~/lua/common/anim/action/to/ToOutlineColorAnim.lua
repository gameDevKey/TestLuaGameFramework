ToOutlineColorAnim = BaseClass("ToOutlineColorAnim",AnimBaseTween)

--Text Outline Image
function ToOutlineColorAnim:__Init(object,toColor,time)
    self.object = object
    self.toColor = toColor
    self.time = time
end

function ToOutlineColorAnim:__Delete()
    
end

function ToOutlineColorAnim:OnTween()
    local tween = self.object:DOColor(self.toColor,self.time)
    return tween
end

function ToOutlineColorAnim.Create(root,animData,nodes,animNodes)
    local component = AnimUtils.GetComponent(root,animData.path,Outline)
    local anim = ToOutlineColorAnim.New(component,animData.toColor,animData.time)
    return anim
end