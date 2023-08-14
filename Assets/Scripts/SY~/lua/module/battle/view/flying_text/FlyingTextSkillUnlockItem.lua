FlyingTextSkillUnlockItem = BaseClass("FlyingTextSkillUnlockItem",BaseView)
FlyingTextSkillUnlockItem.poolKey = "flying_text_skill_unlock_item"

function FlyingTextSkillUnlockItem:__Init()
    self.anim = nil
end

function FlyingTextSkillUnlockItem:__Delete()
    self:RemoveAnim()
end

function FlyingTextSkillUnlockItem:__CacheObject()
    self.txtName = self:Find("main/txt_name",Text)
    self.imgIcon = self:Find("main/img_icon",Image)
    self.rectMain = self:Find("main",RectTransform)
    self.canvasGroup = self:Find(nil,CanvasGroup)
end

function FlyingTextSkillUnlockItem:__Show()
    self.txtName.text = self.skillName
    self:SetSprite(self.imgIcon, self.skillIcon, false)
    self.canvasGroup.alpha = 0

    self:CreateAnim()
    self.anim:SetComplete(self:ToFunc("PlayAnimComplete"))
    self.anim:Play()

    self:StartFollowEntity()
end

function FlyingTextSkillUnlockItem:__Hide()
    self:RemoveAnim()
end

function FlyingTextSkillUnlockItem:RemoveAnim()
    if self.anim then
        self.anim:Delete()
        self.anim = nil
    end
end

function FlyingTextSkillUnlockItem:CreateAnim()
    local perSec = 1/60

    local anim0 = TweenSequenceAnim.New({
        TweenMoveAnchorYAnim.New(self.rectMain,-20,0),
        TweenMoveAnchorYAnim.New(self.rectMain,2.3985,perSec*4),
        TweenMoveAnchorYAnim.New(self.rectMain,10,perSec*3),
        TweenMoveAnchorYAnim.New(self.rectMain,3.1483,perSec*7),
        TweenDelayAnim.New(perSec*18),
        TweenMoveAnchorYAnim.New(self.rectMain,20,perSec*8),
    })

    local anim1 = TweenSequenceAnim.New({
        TweenCanvasGroupAlphaAnim.New(self.canvasGroup,0,0),
        TweenCanvasGroupAlphaAnim.New(self.canvasGroup,255,perSec*4),
        TweenDelayAnim.New(perSec*32),
        TweenCanvasGroupAlphaAnim.New(self.canvasGroup,0,perSec*8)
    })

    self.anim = TweenParallelAnim.New({anim0,anim1})
end

function FlyingTextSkillUnlockItem:PlayAnimComplete()
    self:StopFollowEntity()
    mod.BattleFacade:SendEvent(FlyingTextView.Event.FinishFlyingText,self)
end

function FlyingTextSkillUnlockItem:GetTimerKey()
    return self.skillName .. "_" .. self.skillIcon
end

function FlyingTextSkillUnlockItem:StartFollowEntity()
    if self.uid then
        local timerKey = self:GetTimerKey()
        self:AddUniqueTimer(timerKey,0,0,self:ToFunc("OnFollowEntity"),false)
    end
end

function FlyingTextSkillUnlockItem:StopFollowEntity()
    local timerKey = self:GetTimerKey()
    self:RemoveTimer(timerKey)
end

function FlyingTextSkillUnlockItem:OnFollowEntity()
    FlyingTextUtils.FollowEntity(self.uid,self.rectTrans)
end

function FlyingTextSkillUnlockItem:OnReset()
end

function FlyingTextSkillUnlockItem.Create(args)
    local item = PoolManager.Instance:Pop(PoolType.base_view,FlyingTextSkillUnlockItem.poolKey)
    if not item then
        item = FlyingTextSkillUnlockItem.New()
        local template = BattleDefine.uiObjs["template/fly_text/skill_unlock"]
        item:SetObject(GameObject.Instantiate(template))
    end

    item.skillName = args.skillName
    item.skillIcon = AssetPath.GetSkillIcon(args.skillIcon)
    item.uid = args.uid
    return item
end