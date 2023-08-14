MoveAnchorYAnim = BaseClass("MoveAnchorYAnim",AnimBaseTween)

function MoveAnchorYAnim:__Init(rectTransform,toY,time)
    self.rectTransform = rectTransform
    self.toY = toY
    self.time = time
end

function MoveAnchorYAnim:__Delete()
    
end

function MoveAnchorYAnim:OnTween()
    local tween = self.rectTransform:DOAnchorPosY(self.toY,self.time)
    return tween
end

function MoveAnchorYAnim.Create(root,animData,nodes,animNodes)
    local rectTransform = AnimUtils.GetComponent(root,animData.path,RectTransform)
    local anim = MoveAnchorYAnim.New(rectTransform,animData.toY,animData.time)
    return anim
end