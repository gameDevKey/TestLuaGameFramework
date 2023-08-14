MoveAnchor3dAnim = BaseClass("MoveAnchor3dAnim",AnimBaseTween)

function MoveAnchor3dAnim:__Init(rectTransform,toPos,time)
    self.rectTransform = rectTransform
    self.toPos = toPos
    self.time = time
end

function MoveAnchor3dAnim:__Delete()
    
end

function MoveAnchor3dAnim:OnTween()
    local tween = self.rectTransform:DOAnchorPos3D(self.toPos,self.time)
    return tween
end

function MoveAnchor3dAnim.Create(root,animData,nodes,animNodes)
    local rectTransform = AnimUtils.GetComponent(root,animData.path,RectTransform)
    local anim = MoveAnchor3dAnim.New(rectTransform,animData.toPos,animData.time)
    return anim
end