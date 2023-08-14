FlyingTextView = BaseClass("FlyingTextView",ExtendView)

FlyingTextView.Event = EventEnum.New(
    "ShowFlyingText",
    "FinishFlyingText",
    "ClearFlyingText",
    "ShowFlyingTextByPos"
)

function FlyingTextView:__Init()
    self:InitFlyingTextType()
    self.cacheCreates = {}
    self.flyingTexts = {}
    self.isExistCache = false
    self.showNum = 0
end

function FlyingTextView:__Delete()

end

function FlyingTextView:InitFlyingTextType()
    self.flyingTextType = {}
    self.flyingTextType[BattleDefine.FlyingText.hp] = FlyingTextHpItem
    self.flyingTextType[BattleDefine.FlyingText.skill] = FlyingTextSkillItem
    self.flyingTextType[BattleDefine.FlyingText.action] = FlyingTextActionItem
    self.flyingTextType[BattleDefine.FlyingText.hit_tips] = FlyingTextHitTipsItem
    self.flyingTextType[BattleDefine.FlyingText.attr] = FlyingTextAttrItem
    self.flyingTextType[BattleDefine.FlyingText.state] = FlyingTextStateItem
    self.flyingTextType[BattleDefine.FlyingText.energy] = FlyingTextEnergyItem
    self.flyingTextType[BattleDefine.FlyingText.skill_unlock] = FlyingTextSkillUnlockItem
    self.flyingTextType[BattleDefine.FlyingText.shield] = FlyingTextShieldItem
    self.flyingTextType[BattleDefine.FlyingText.skill_banner] = FlyingTextSkillBannerItem
end

function FlyingTextView:__CacheObject()
    BattleDefine.uiObjs["main/fly_text"] = self:Find("main/fly_text").gameObject
    BattleDefine.uiObjs["template/fly_text/dmg"] = self:Find("template/fly_text/dmg").gameObject
    BattleDefine.uiObjs["template/fly_text/heal"] = self:Find("template/fly_text/heal").gameObject
    BattleDefine.uiObjs["template/fly_text/action"] = self:Find("template/fly_text/action").gameObject
    BattleDefine.uiObjs["template/fly_text/hit_tips"] = self:Find("template/fly_text/hit_tips").gameObject
    BattleDefine.uiObjs["template/fly_text/skill_name"] = self:Find("template/fly_text/skill_name").gameObject
    BattleDefine.uiObjs["template/fly_text/attr"] = self:Find("template/fly_text/attr").gameObject
    BattleDefine.uiObjs["template/fly_text/state"] = self:Find("template/fly_text/state").gameObject
    BattleDefine.uiObjs["template/fly_text/energy"] = self:Find("template/fly_text/energy").gameObject
    BattleDefine.uiObjs["template/fly_text/skill_unlock"] = self:Find("template/fly_text/skill_unlock").gameObject
    BattleDefine.uiObjs["template/fly_text/shield"] = self:Find("template/fly_text/shield").gameObject
    BattleDefine.uiObjs["template/fly_text/skill_banner"] = self:Find("template/fly_text/skill_banner").gameObject
end

function FlyingTextView:__BindEvent()
    self:BindEvent(FlyingTextView.Event.ShowFlyingText)
    self:BindEvent(FlyingTextView.Event.FinishFlyingText)
    self:BindEvent(FlyingTextView.Event.ClearFlyingText)
    self:BindEvent(FlyingTextView.Event.ShowFlyingTextByPos)
end

function FlyingTextView:__Hide()
    self:ClearFlyingText()
    self.showNum = 0
end

function FlyingTextView:ShowFlyingText(textType,args)
	local flyingText = self.flyingTextType[textType]
    if not flyingText then return end

    local entity = mod.BattleProxy:GetEntity(args.uid)  --TODO 区分模式或改为 RunWorld.EntitySystem:GetEntity(uid)

    if not entity or not entity.clientEntity or not entity.clientEntity.UIComponent then
        return
    end

    local entityTop = entity.clientEntity.UIComponent.entityTop
    local pos = nil
    if args.isTopPos and entityTop then
        pos = entityTop:GetPos()
    elseif entityTop then
        pos = entityTop:GetFlyTextPos()
    end
    if not pos then
        return
    end

    table.insert(self.cacheCreates,{textType = textType,pos = pos, args = args,time = os.time()})
    self.isExistCache = true

    self:CacheCreate()
end

function FlyingTextView:ShowFlyingTextByPos(textType,args,pos)
    local flyingText = self.flyingTextType[textType]
    if not flyingText then return end

    if not pos then
        return
    end

    table.insert(self.cacheCreates,{textType = textType,pos = pos, args = args,time = os.time()})
    self.isExistCache = true

    self:CacheCreate()
end

function FlyingTextView:Update()
    self:CacheCreate()
end

function FlyingTextView:FinishFlyingText(item)
    if not self.flyingTexts[item] then
        return
    end
    self.flyingTexts[item] = nil
    PoolManager.Instance:Push(PoolType.base_view,item.poolKey,item)
    self.showNum = self.showNum - 1
end

function FlyingTextView:CacheCreate()
    if not self.isExistCache then
        return 
    end

    local textInfo = self.cacheCreates[1]
    table.remove(self.cacheCreates,1)
    if #self.cacheCreates <= 0 then 
        self.isExistCache = false
    end

    if self.showNum >= BattleDefine.maxFlytextNum or os.time() - textInfo.time > 2 then
        self.isExistCache = false
        self.cacheCreates = {}
        return
    end

    local pos = textInfo.pos

    local entity = mod.BattleProxy:GetEntity(textInfo.uid) --TODO 区分模式或改为 RunWorld.EntitySystem:GetEntity(uid)
    if entity then pos = entity:GetFlyTextPos() end

    local class = self.flyingTextType[textInfo.textType]
    local flyingTextItem = class.Create(textInfo.args)
    if not flyingTextItem then
        LogTable("异常的飘字信息",textInfo)
        return
    end

    local offsetX = textInfo.args.offsetX or 0
    local offsetY = textInfo.args.offsetY or 0
    flyingTextItem:SetParent(BattleDefine.uiObjs["main/fly_text"].transform,pos.x + offsetX,pos.y + offsetY)

    flyingTextItem:Show()

    self.flyingTexts[flyingTextItem] = true
    self.showNum = self.showNum + 1
end

function FlyingTextView:ClearFlyingText()
    for item,_ in pairs(self.flyingTexts) do
        PoolManager.Instance:Push(PoolType.base_view,item.poolKey,item)
    end
    self.cacheCreates = {}
    self.flyingTexts = {}
    self.isExistCache = false
end