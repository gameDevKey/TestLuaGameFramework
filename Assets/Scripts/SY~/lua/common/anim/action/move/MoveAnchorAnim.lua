MoveAnchorAnim = BaseClass("MoveAnchorAnim",AnimBaseTween)

function MoveAnchorAnim:__Init(rectTransform,toPos,time)
    self.rectTransform = rectTransform
    self.toPos = toPos
    self.time = time
end

function MoveAnchorAnim:__Delete()
    
end

function MoveAnchorAnim:OnTween()
    local tween = self.rectTransform:DOAnchorPos(self.toPos,self.time)
    return tween
end

function MoveAnchorAnim.Create(root,animData,nodes,animNodes)
    local rectTransform = AnimUtils.GetComponent(root,animData.path,RectTransform)
    local anim = MoveAnchorAnim.New(rectTransform,animData.toPos,animData.time)
    return anim
end