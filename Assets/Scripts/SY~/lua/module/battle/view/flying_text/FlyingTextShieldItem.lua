FlyingTextShieldItem = BaseClass("FlyingTextShieldItem",BaseView)
FlyingTextShieldItem.poolKey = "flying_text_shield_item"

function FlyingTextShieldItem:__Init()
    self.anim = nil
end

function FlyingTextShieldItem:__Delete()
    self:RemoveAnim()
end

function FlyingTextShieldItem:__CacheObject()
    self.txtVal = self:Find(nil,Text)
end

function FlyingTextShieldItem:__Show()
    self.txtVal.text = self.value
    self.beginPos = self.rectTrans.anchoredPosition
    self:CreateAnim()
    self.anim:SetComplete(self:ToFunc("PlayAnimComplete"))
    self.anim:Play()
end

function FlyingTextShieldItem:__Hide()
    self:RemoveAnim()
end

function FlyingTextShieldItem:RemoveAnim()
    if self.anim then
        self.anim:Delete()
        self.anim = nil
    end
end

function FlyingTextShieldItem:CreateAnim()
    self.anim = FlyingTextUtils.GetHealAnimTween(self.rectTrans,self.txtVal,self.beginPos)
end

function FlyingTextShieldItem:PlayAnimComplete()
    mod.BattleFacade:SendEvent(FlyingTextView.Event.FinishFlyingText,self)
end

function FlyingTextShieldItem:OnReset()
end

function FlyingTextShieldItem.Create(args)
    local item = PoolManager.Instance:Pop(PoolType.base_view,FlyingTextShieldItem.poolKey)
    if not item then
        item = FlyingTextShieldItem.New()
        local template = BattleDefine.uiObjs["template/fly_text/shield"]
        item:SetObject(GameObject.Instantiate(template))
    end

    item.value = string.format("s-%d",args.value)
    return item
end