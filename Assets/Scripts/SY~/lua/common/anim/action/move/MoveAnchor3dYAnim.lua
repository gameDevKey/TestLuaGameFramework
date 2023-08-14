MoveAnchor3dYAnim = BaseClass("MoveAnchor3dYAnim",AnimBaseTween)

function MoveAnchor3dYAnim:__Init(rectTransform,toY,time)
    self.rectTransform = rectTransform
    self.toY = toY
    self.time = time
end

function MoveAnchor3dYAnim:__Delete()
    
end

function MoveAnchor3dYAnim:OnTween()
    local tween = self.rectTransform:DOAnchorPos3DY(self.toY,self.time)
    return tween
end

function MoveAnchor3dYAnim.Create(root,animData,nodes,animNodes)
    local rectTransform = AnimUtils.GetComponent(root,animData.path,RectTransform)
    local anim = MoveAnchor3dYAnim.New(rectTransform,animData.toY,animData.time)
    return anim
end