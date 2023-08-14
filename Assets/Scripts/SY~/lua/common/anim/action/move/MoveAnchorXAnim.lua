MoveAnchorXAnim = BaseClass("MoveAnchorXAnim",AnimBaseTween)

function MoveAnchorXAnim:__Init(rectTransform,toX,time)
    self.rectTransform = rectTransform
    self.toX = toX
    self.time = time
end

function MoveAnchorXAnim:__Delete()
    
end

function MoveAnchorXAnim:OnTween()
    local tween = self.rectTransform:DOAnchorPosX(self.toX,self.time)
    return tween
end

function MoveAnchorXAnim.Create(root,animData,nodes,animNodes)
    local rectTransform = AnimUtils.GetComponent(root,animData.path,RectTransform)
    local anim = MoveAnchorXAnim.New(rectTransform,animData.toX,animData.time)
    return anim
end