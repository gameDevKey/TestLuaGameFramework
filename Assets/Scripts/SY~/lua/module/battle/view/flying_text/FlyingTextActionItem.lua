FlyingTextActionItem = BaseClass("FlyingTextActionItem",BaseView)
FlyingTextActionItem.poolKey = "flying_text_action_item"

function FlyingTextActionItem:__Init()
    self.beginPos = nil
end

function FlyingTextActionItem:__Delete()
    self:RemoveAnim()
end

--用于获取组件,在第一次创建的时候调用，只会调用一次
function FlyingTextActionItem:__CacheObject()
    self.numText = self:Find(nil,Text)
end

function FlyingTextActionItem:__Show()
    self.numText.text = self.showText
    self.beginPos = self.rectTrans.anchoredPosition

    self:CreateAnim()
    self.textAnim:Play()
end

function FlyingTextActionItem:CreateAnim()
    UnityUtils.SetTextColor(self.numText,1,1,1,1)

    UnityUtils.SetLocalScale(self.rectTrans,2,2,1)
    UnityUtils.SetTextColor(self.numText,1,1,1,0)

    local anim1 = TweenMoveAnchorAnim.New(self.rectTrans,Vector2(self.beginPos.x,self.beginPos.y + 30),0.6)

    local anim2 = TweenScaleAnim.New(self.rectTrans,Vector3(0.95,0.95,1),0.3)
    anim2:SetEase(DG.Tweening.Ease.OutQuad)
        
    local anim3 = TweenGraphicAlphaAnim.New(self.numText,255,0.3)

    self.textAnim = TweenParallelAnim.New({anim1,anim2,anim3})
    self.textAnim:SetComplete(self:ToFunc("PlayAnimComplete"))
end

function FlyingTextActionItem:PlayAnimComplete()
    mod.BattleFacade:SendEvent(FlyingTextView.Event.FinishFlyingText,self)
end

function FlyingTextActionItem:__Hide()
    self:RemoveAnim()
end

function FlyingTextActionItem:RemoveAnim()
    if self.textAnim then
        self.textAnim:Delete()
        self.textAnim = nil
    end
end

function FlyingTextActionItem:OnReset()

end

function FlyingTextActionItem.Create(args,onComplete)
    local showText = nil
    local changeValue = args.value
    if changeValue > 0 then --加行动
        showText = string.format("+%s",changeValue)
    elseif changeValue < 0 then
        showText = changeValue
    end

    local item = PoolManager.Instance:Pop(PoolType.base_view,FlyingTextActionItem.poolKey)
    if not item then
        item = FlyingTextActionItem.New()
        item:SetObject(GameObject.Instantiate(BattleDefine.uiObjs["template/fly_text/action"]))
    end

    item.showText = showText
    return item
end