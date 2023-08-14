MoveAnchor3dXAnim = BaseClass("MoveAnchor3dXAnim",AnimBaseTween)

function MoveAnchor3dXAnim:__Init(rectTransform,toX,time)
    self.rectTransform = rectTransform
    self.toX = toX
    self.time = time
end

function MoveAnchor3dXAnim:__Delete()
    
end

function MoveAnchor3dXAnim:OnTween()
    local tween = self.rectTransform:DOAnchorPos3DX(self.toX,self.time)
    return tween
end

function MoveAnchor3dXAnim.Create(root,animData,nodes,animNodes)
    local rectTransform = AnimUtils.GetComponent(root,animData.path,RectTransform)
    local anim = MoveAnchor3dXAnim.New(rectTransform,animData.toX,animData.time)
    return anim
end