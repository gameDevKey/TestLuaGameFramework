FlyingTextStateItem = BaseClass("FlyingTextStateItem",BaseView)

FlyingTextStateItem.poolKey = "flying_text_state_item"

function FlyingTextStateItem:__Init()
    self.anim = nil
    self.state = nil
end

function FlyingTextStateItem:__Delete()
    self:RemoveAnim()
end

function FlyingTextStateItem:__CacheObject()
    self.img = self:Find("img",Image)
    self.canvasGroup = self:Find(nil,CanvasGroup)
end

function FlyingTextStateItem:__Show()
    local path = AssetPath.GetFlyingTextStateImg(self.state)
    self:SetSprite(self.img,path,true)
    self.canvasGroup.alpha = 0
    self.beginPos = self.rectTrans.anchoredPosition

    self:CreateAnim()
    self.anim:Play()
end

function FlyingTextStateItem:__Hide()
    self:RemoveAnim()
end

function FlyingTextStateItem:RemoveAnim()
    if self.anim then
        self.anim:Delete()
        self.anim = nil
    end
end

function FlyingTextStateItem:CreateAnim()
    local anim1 = TweenCanvasGroupAlphaAnim.New(self.canvasGroup,255,0.1)
    local anim2 = TweenDelayAnim.New(0.2)

    local anim3 = TweenCanvasGroupAlphaAnim.New(self.canvasGroup,0,0.4)
    local anim4 = TweenMoveAnchorAnim.New(self.rectTrans,Vector2(self.beginPos.x + 40,self.beginPos.y + 30),0.3)

    local anim5 = TweenParallelAnim.New({anim3,anim4})

    self.anim = TweenSequenceAnim.New({anim1,anim2,anim5})
    self.anim:SetComplete(self:ToFunc("PlayAnimComplete"))
end

function FlyingTextStateItem:PlayAnimComplete()
    mod.BattleFacade:SendEvent(FlyingTextView.Event.FinishFlyingText,self)
end

function FlyingTextStateItem:OnReset()
    -- self:RemoveSprite(self.img)
end

function FlyingTextStateItem.Create(args)
    local item = PoolManager.Instance:Pop(PoolType.base_view,FlyingTextStateItem.poolKey)
    if not item then
        item = FlyingTextStateItem.New()
        local template = BattleDefine.uiObjs["template/fly_text/state"]
        item:SetObject(GameObject.Instantiate(template))
    end
    item.state = args.state
    return item
end