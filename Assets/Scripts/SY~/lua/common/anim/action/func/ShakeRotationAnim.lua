ShakeRotationAnim = BaseClass("ShakeRotationAnim",AnimBaseTween)

function ShakeRotationAnim:__Init(transform,time,strength,vibrato,randomness,fadeOut)
    self.transform = transform
    self.time = time
    self.strength = strength
    self.vibrato = vibrato or 10
    self.randomness = randomness or 90
    self.fadeOut = fadeOut or true
end

function ShakeRotationAnim:__Delete()
    
end


function ShakeRotationAnim:OnTween()
    local tween = self.transform:DOShakeRotation(self.time,self.strength,self.vibrato,self.randomness,self.fadeOut)
    return tween
end

function ShakeRotationAnim.Create(root,animData,nodes,animNodes)
    local anim = ShakeRotationAnim.New(animData.time,animData.strength,animData.vibrato,animData.randomness,animData.fadeOut)
    return anim
end