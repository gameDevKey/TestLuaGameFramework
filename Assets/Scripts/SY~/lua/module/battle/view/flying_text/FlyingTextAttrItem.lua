FlyingTextAttrItem = BaseClass("FlyingTextAttrItem",BaseView)

FlyingTextAttrItem.poolKey = "flying_text_attr_item"

function FlyingTextAttrItem:__Init()
    self.anim = nil
    self.beginPos = nil
    self.showText = nil
    self.showLevel = nil -- 展示等级，等级越高，位置越矮

    self.iconPath = {
        [GDefine.Attr.max_hp] = UITex("battle/104"),
        [GDefine.Attr.atk] = UITex("battle/105"),
    }
end

function FlyingTextAttrItem:__Delete()
    self:RemoveAnim()
end

function FlyingTextAttrItem:__CacheObject()
    self.attrIcon = self:Find("icon",Image)
    self.attrText = self:Find("text",Text)
    self.canvasGroup = self:Find(nil,CanvasGroup)
end

function FlyingTextAttrItem:__Show()
    local path = self.iconPath[self.attrId]
    self:SetSprite(self.attrIcon,path)
    self.attrText.text = self.showText

    self.canvasGroup.alpha = 0
    self.beginPos = self.rectTrans.anchoredPosition
    UnityUtils.SetAnchoredPosition(self.transform,self.beginPos.x,self.beginPos.y + (self.showLevel * 25)-30)

    self:CreateAnim()
    self.anim:Play()
end

function FlyingTextAttrItem:__Hide()
    self:RemoveAnim()
end

function FlyingTextAttrItem:RemoveAnim()
    if self.anim then
        self.anim:Delete()
        self.anim = nil
    end
end

function FlyingTextAttrItem:CreateAnim()
    local anim1 = TweenCanvasGroupAlphaAnim.New(self.canvasGroup,255,0.3)
    local anim4 = TweenDelayAnim.New(0.3)

    self.anim = TweenSequenceAnim.New({anim1,anim4})
    self.anim:SetComplete(self:ToFunc("PlayAnimComplete"))
end

function FlyingTextAttrItem:PlayAnimComplete()
    mod.BattleFacade:SendEvent(FlyingTextView.Event.FinishFlyingText,self)
end

function FlyingTextAttrItem:OnReset()
end

function FlyingTextAttrItem.Create(args)
    local item = PoolManager.Instance:Pop(PoolType.base_view,FlyingTextAttrItem.poolKey)
    if not item then
        item = FlyingTextAttrItem.New()
        local template = BattleDefine.uiObjs["template/fly_text/attr"]
        item:SetObject(GameObject.Instantiate(template))
    end

    item.attrId = args.attrId
    item.showText = args.showText
    item.showLevel = args.showLevel
    return item
end