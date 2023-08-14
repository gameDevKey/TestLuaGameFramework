FlyingTextSkillItem = BaseClass("FlyingTextSkillItem",BaseView)
FlyingTextSkillItem.poolKey = "flying_text_skill_item"

function FlyingTextSkillItem:__Init()
    self.anim = nil
    self.skillName = nil
end

function FlyingTextSkillItem:__Delete()
    self:RemoveAnim()
end

function FlyingTextSkillItem:__CacheObject()
    self.nameText = self:Find("text",Text)
    self.canvasGroup = self:Find(nil,CanvasGroup)
end

function FlyingTextSkillItem:__Show()
    self.nameText.text = self.skillName
    self.canvasGroup.alpha = 0
    self.beginPos = self.rectTrans.anchoredPosition

    self:CreateAnim()
    self.anim:Play()
end

function FlyingTextSkillItem:__Hide()
    self:RemoveAnim()
end

function FlyingTextSkillItem:RemoveAnim()
    if self.anim then
        self.anim:Delete()
        self.anim = nil
    end
end

function FlyingTextSkillItem:CreateAnim()
    local anim1 = TweenCanvasGroupAlphaAnim.New(self.canvasGroup,255,0.1)
    local anim2 = TweenDelayAnim.New(0.5)

    local anim3 = TweenCanvasGroupAlphaAnim.New(self.canvasGroup,0,0.5)
    local anim4 = TweenMoveAnchorXAnim.New(self.transform,self.beginPos.x + 100,0.5)

    local anim5 = TweenParallelAnim.New({anim3,anim4})
    
    self.anim = TweenSequenceAnim.New({anim1,anim2,anim5})
    self.anim:SetComplete(self:ToFunc("PlayAnimComplete"))
end

function FlyingTextSkillItem:PlayAnimComplete()
    mod.BattleFacade:SendEvent(FlyingTextView.Event.FinishFlyingText,self)
end

function FlyingTextSkillItem:OnReset()
end

function FlyingTextSkillItem.Create(args)
    local item = PoolManager.Instance:Pop(PoolType.base_view,FlyingTextSkillItem.poolKey)
    if not item then
        item = FlyingTextSkillItem.New()
        local template = BattleDefine.uiObjs["template/fly_text/skill_name"]
        item:SetObject(GameObject.Instantiate(template))
    end

    item.skillName = args.skillName
    return item
end