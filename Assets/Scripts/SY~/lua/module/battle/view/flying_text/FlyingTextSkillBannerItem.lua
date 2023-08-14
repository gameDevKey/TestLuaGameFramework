FlyingTextSkillBannerItem = BaseClass("FlyingTextSkillBannerItem",BaseView)
FlyingTextSkillBannerItem.poolKey = "flying_text_skill_banner_item"

function FlyingTextSkillBannerItem:__Init()
    self.anim = nil
end

function FlyingTextSkillBannerItem:__Delete()
    self:RemoveAnim()
end

function FlyingTextSkillBannerItem:__CacheObject()
    self.imgIcon = self:Find("main/img_icon",Image)
    self.imgName = self:Find("main/img_name",Image)
    self.rectImgName = self:Find("main/img_name",RectTransform)
    self.rectMain = self:Find("main",RectTransform)
    self.canvasGroupMain = self:Find("main",CanvasGroup)
    self.img2 = self:Find("main/image_2",Image)
    self.img6 = self:Find("main/image_6",Image)
    self.rectImg6 = self:Find("main/image_6",RectTransform)
    self.rectPivot = self:Find("main/pivot",RectTransform)
    self.img4 = self:Find("main/pivot/image_4",Image)
    self.parentCanvas = BattleDefine.uiObjs["main/fly_text"]:GetComponent(Canvas)
end

function FlyingTextSkillBannerItem:SetData(data)
    self.data = data
end

function FlyingTextSkillBannerItem:__Show()
    self:SetSprite(self.imgIcon, AssetPath.GetSkillBannerHeadIcon(self.data.unitId), false)
    self:SetSprite(self.imgName, AssetPath.GetSkillBannerNameIcon(self.data.skillId), false)
    self.beginPos = self.rectMain.anchoredPosition
    self:CreateAnim()
    self.anim:SetComplete(self:ToFunc("PlayAnimComplete"))
    self.anim:Play()

    self:StartFollowEntity()
    self:LoadUIEffects()
end

function FlyingTextSkillBannerItem:__Hide()
    self:RemoveAnim()
end

function FlyingTextSkillBannerItem:LoadUIEffects()
    self:RemoveAllEffect()

    self:LoadUIEffect({
        confId = 9400016,
        parent = self.rectMain,
        order = self.parentCanvas.sortingOrder + 1,
        delayTime = 0,
        lastTime = 2000,
        pos = Vector3(0,-33,0)
    },true)

    self:LoadUIEffect({
        confId = 9400017,
        parent = self.rectMain,
        order = self.parentCanvas.sortingOrder - 1,
        delayTime = 116.66,
        lastTime = 2000,
        pos = Vector3(0,-40,0)
    },true)
end

function FlyingTextSkillBannerItem:RemoveAnim()
    if self.anim then
        self.anim:Delete()
        self.anim = nil
    end
end

function FlyingTextSkillBannerItem:CreateAnim()
    self.anim = FlyingTextUtils.GetSkillBannerAnimTween(self.rectMain,self.canvasGroupMain,self.img2,self.rectImg6,
        self.img6,self.imgName,self.rectImgName,self.rectPivot,self.img4)
end

function FlyingTextSkillBannerItem:PlayAnimComplete()
    self:RemoveAllEffect()
    self:StopFollowEntity()
    mod.BattleFacade:SendEvent(FlyingTextView.Event.FinishFlyingText,self)
end

function FlyingTextSkillBannerItem:GetTimerKey()
    return self.data.unitId .. '_' .. self.data.skillId
end

function FlyingTextSkillBannerItem:StartFollowEntity()
    if self.uid then
        local timerKey = self:GetTimerKey()
        self:AddUniqueTimer(timerKey,0,0,self:ToFunc("OnFollowEntity"),false)
    end
end

function FlyingTextSkillBannerItem:StopFollowEntity()
    local timerKey = self:GetTimerKey()
    self:RemoveTimer(timerKey)
end

function FlyingTextSkillBannerItem:OnFollowEntity()
    FlyingTextUtils.FollowEntity(self.uid,self.rectTrans)
end

function FlyingTextSkillBannerItem:OnReset()
end

function FlyingTextSkillBannerItem.Create(args)
    local item = PoolManager.Instance:Pop(PoolType.base_view,FlyingTextSkillBannerItem.poolKey)
    if not item then
        item = FlyingTextSkillBannerItem.New()
        local template = BattleDefine.uiObjs["template/fly_text/skill_banner"]
        item:SetObject(GameObject.Instantiate(template))
    end

    item:SetData(args)
    return item
end