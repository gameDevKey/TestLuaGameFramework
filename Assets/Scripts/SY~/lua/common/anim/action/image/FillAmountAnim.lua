FillAmountAnim = BaseClass("FillAmountAnim",AnimBaseTween)

function FillAmountAnim:__Init(image,toValue,time)
    self.image = image
    self.toValue = toValue
    self.time = time
end

function FillAmountAnim:__Delete()
    
end

function FillAmountAnim:OnTween()
    local tween = self.image:DOFillAmount(self.toValue,self.time)
    return tween
end

function FillAmountAnim.Create(root,animData,nodes,animNodes)
    local image = AnimUtils.GetComponent(root,animData.path,Image)
    local anim = FillAmountAnim.New(image,animData.toValue,animData.time)
    return anim
end