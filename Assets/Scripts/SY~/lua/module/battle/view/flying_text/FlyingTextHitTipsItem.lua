FlyingTextHitTipsItem = BaseClass("FlyingTextHitTipsItem",BaseView)
FlyingTextHitTipsItem.poolKey = "flying_text_hit_tips_item"

function FlyingTextHitTipsItem:__Init()
    self.anim = nil
    self.tipsChar = nil
end

function FlyingTextHitTipsItem:__Delete()
    self:RemoveAnim()
end

function FlyingTextHitTipsItem:__CacheObject()
    self.tipsText = self:Find(nil,Text)
end

function FlyingTextHitTipsItem:__Show()
    self.tipsText.text = self.tipsChar
    self.beginPos = self.rectTrans.anchoredPosition
    
   
    self:CreateAnim()
    self.anim:Play()
end

function FlyingTextHitTipsItem:__Hide()
    self:RemoveAnim()
end

function FlyingTextHitTipsItem:CreateAnim()
    UnityUtils.SetTextColor(self.tipsText,1,1,1,0)

    local anim1 = TweenMoveAnchorAnim.New(self.rectTrans,Vector2(self.beginPos.x,self.beginPos.y + 30),0.6)
    
    local anim2 = TweenGraphicAlphaAnim.New(self.tipsText,255,0.3)

    self.anim = TweenParallelAnim.New({anim1,anim2})
    self.anim:SetComplete(self:ToFunc("PlayAnimComplete"))
end

function FlyingTextHitTipsItem:RemoveAnim()
    if self.anim then
        self.anim:Delete()
        self.anim = nil
    end
end

function FlyingTextHitTipsItem:PlayAnimComplete()
    mod.BattleFacade:SendEvent(FlyingTextView.Event.FinishFlyingText,self)
end

function FlyingTextHitTipsItem:OnReset()
end

function FlyingTextHitTipsItem.Create(args)
    local item = PoolManager.Instance:Pop(PoolType.base_view,FlyingTextHitTipsItem.poolKey)
    if not item then
        item = FlyingTextHitTipsItem.New()
        local template = BattleDefine.uiObjs["template/fly_text/hit_tips"]
        item:SetObject(GameObject.Instantiate(template))
    end

    item.tipsChar = args.char
    return item
end