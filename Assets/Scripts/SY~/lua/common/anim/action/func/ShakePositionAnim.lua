ShakePositionAnim = BaseClass("ShakePositionAnim",AnimBaseTween)

function ShakePositionAnim:__Init(transform,time,strength,vibrato,randomness,snapping,fadeOut)
    self.transform = transform
    self.time = time
    self.strength = strength
    self.vibrato = vibrato or 10
    self.randomness = randomness or 90
    self.snapping = snapping or snapping == nil
    self.fadeOut = fadeOut or true
end

function ShakePositionAnim:OnTween()
    local tween = self.transform:DOShakePosition(self.time,self.strength,self.vibrato,self.randomness,self.snapping,self.fadeOut)
    return tween
end

function ShakePositionAnim.Create(root,animData,nodes,animNodes)
    local anim = ShakePositionAnim.New(animData.time,animData.strength,animData.vibrato,animData.randomness,animData.snapping,animData.fadeOut)
    return anim
end