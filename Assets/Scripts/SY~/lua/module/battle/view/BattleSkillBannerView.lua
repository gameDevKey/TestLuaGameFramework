BattleSkillBannerView = BaseClass("BattleSkillBannerView",ExtendView)
BattleSkillBannerView.PoolKey = "BattleSkillBannerItem"

BattleSkillBannerView.Event = EventEnum.New(
    "ShowBanner"
)

function BattleSkillBannerView:__Init()
    self.timerKey = 0
    self.tbBanner = {}
    self.maxShowAmount = 3
    self.maxShowDuration = 1.5
    self.moveXDuration = 0.15
    self.moveYDuration = 0.3
    self.itemScale = 0.6
end

function BattleSkillBannerView:__Delete()
    for i = #self.tbBanner,1,-1 do
        self:OnBannerFinish(self.tbBanner[i])
    end
    self.tbBanner = {}
end

function BattleSkillBannerView:__CacheObject()
    self.parent = self:Find("main/banner_node")
    self.template = self:Find("template/skill_banner_item").gameObject
    self.rectTemplate = self:Find("template/skill_banner_item",RectTransform)
    self.itemWidth = self.rectTemplate.rect.width * self.itemScale
    self.itemHeight = self.rectTemplate.rect.height * self.itemScale
end

function BattleSkillBannerView:__BindEvent()
    self:BindEvent(BattleSkillBannerView.Event.ShowBanner)
end

function BattleSkillBannerView:__Hide()

end

function BattleSkillBannerView:GetTimerKey()
    self.timerKey = self.timerKey + 1
    return self.timerKey
end

function BattleSkillBannerView:ShowBanner(unitId,skillId)
    local obj = PoolManager.Instance:Pop(PoolType.object,BattleSkillBannerView.PoolKey)
    if not obj then
        obj = GameObject.Instantiate(self.template)
    end
    obj.transform:SetParent(self.parent)
    obj.transform:Reset()
    UnityUtils.SetLocalScale(obj.transform,self.itemScale,self.itemScale,self.itemScale)
    local rect = obj:GetComponent(RectTransform)
    local imgHead = obj.transform:Find("img_icon"):GetComponent(Image)
    local imgName = obj.transform:Find("img_name"):GetComponent(Image)
    self:SetSprite(imgHead, AssetPath.GetSkillBannerHeadIcon(unitId), true)
    self:SetSprite(imgName, AssetPath.GetSkillBannerNameIcon(skillId), true)
    local timerKey = self:GetTimerKey()
    local banner =  {
        obj = obj,
        rect = rect,
        imgHead = imgHead,
        imgName = imgName,
        unitId = unitId,
        skillId = skillId,
        timerKey = timerKey,
        toY = 0,
    }
    table.insert(self.tbBanner,banner)

    self:OnBannerEnter(banner)
    self:AfterBannerAdd()
end

function BattleSkillBannerView:OnBannerExitAnimFinish(banner)
    if banner.tween then
        banner.tween:Destroy()
        banner.tween = nil
    end
    PoolManager.Instance:Push(PoolType.object,BattleSkillBannerView.PoolKey,banner.obj)
end

function BattleSkillBannerView:OnBannerFinish(banner)
    if banner.tween then
        banner.tween:Destroy()
        banner.tween = nil
    end
    self:RemoveTimer(banner.timerKey)
    for i = #self.tbBanner, 1, -1 do
        if self.tbBanner[i] == banner then
            table.remove(self.tbBanner, i)
        end
    end
    banner.tween = MoveAnchorXAnim.New(banner.rect,-self.itemWidth,self.moveXDuration)
    banner.tween:SetComplete(self:ToFunc("OnBannerExitAnimFinish"),banner)
    banner.tween:Play()
    -- PoolManager.Instance:Push(PoolType.object,BattleSkillBannerView.PoolKey,banner.obj)

    self:print("Banner结束",banner)
end

function BattleSkillBannerView:OnReachLifeTime(banner)
    self:print("Banner持续时间结束",banner)
    self:OnBannerFinish(banner)
end

function BattleSkillBannerView:OnBannerEnter(banner)
    UnityUtils.SetAnchoredPosition(banner.rect, -self.itemWidth, 0)
    banner.tween = MoveAnchorXAnim.New(banner.rect,0,self.moveXDuration)
    banner.tween:Play()
    banner.toY = 0

    local lifeTimer = self:AddUniqueTimer(banner.timerKey,1,self.maxShowDuration,self:ToFunc("OnReachLifeTime"),false)
    lifeTimer:SetArgs(banner)

    self:print("新增Banner",banner)
end

function BattleSkillBannerView:AfterBannerAdd()
    local len = #self.tbBanner
    if len > self.maxShowAmount then
        self:print("超出Banner显示上限,移除个数",nil,(len-self.maxShowAmount))

        for i = len-self.maxShowAmount,1,-1 do
            self:OnBannerFinish(self.tbBanner[i])
        end
        len = #self.tbBanner
    end
    for i = 1, len-1 do
        local banner = self.tbBanner[i]
        if banner.tween then
            banner.tween:Destroy()
            banner.tween = nil
        end
        banner.toY = banner.toY + self.itemHeight
        banner.tween = MoveAnchorAnim.New(banner.rect,Vector2(0,banner.toY),self.moveYDuration)
        banner.tween:Play()

        self:print("其他Banner上移",banner,'高度:',banner.toY)
    end
end

BattleSkillBannerView.LOG = false
function BattleSkillBannerView:print(tips,banner,...)
    if not BattleSkillBannerView.LOG then
        return
    end
    local info = ""
    if banner then
        info = "key:" .. banner.unitId.."_"..banner.skillId.."_"..banner.timerKey .. ",total:".. #self.tbBanner
    end
    LogYqh("BattleSkillBannerView ",tips,info,...)
end