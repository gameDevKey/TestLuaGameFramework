MoveAnchor3dZAnim = BaseClass("MoveAnchor3dZAnim",AnimBaseTween)

function MoveAnchor3dZAnim:__Init(rectTransform,toZ,time)
    self.rectTransform = rectTransform
    self.toZ = toZ
    self.time = time
end

function MoveAnchor3dZAnim:__Delete()
    
end

function MoveAnchor3dZAnim:OnTween()
    local tween = self.rectTransform:DOAnchorPos3DZ(self.toZ,self.time)
    return tween
end

function MoveAnchor3dZAnim.Create(root,animData,nodes,animNodes)
    local rectTransform = AnimUtils.GetComponent(root,animData.path,RectTransform)
    local anim = MoveAnchor3dZAnim.New(rectTransform,animData.toZ,animData.time)
    return anim
end