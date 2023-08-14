HeroTopItem = BaseClass("HeroTopItem",EntityTopBase)
HeroTopItem.poolKey = "role_top_item"

HeroTopItem.BarType = {
    HP = 1,
    ADD_MAX_HP = 2,
    SHIELD = 3,
}

function HeroTopItem:__Init()
    self.buffItems = {}

    self.srcHpBgSize = nil
    self.srcHpValueSize = nil
    self.curHpValueSizeX = nil

    self.srcEnergyBgSize = nil
    self.srcEnergyValueSize = nil
    self.curEnergyValueSizeX = nil

    self.lastAddMaxHp = -1
    self.lastHp = -1
    self.lastShield = -1

    self.hitAnims = {}

    self.hideLockUid = 0
    self.hideLocks = {}
end

function HeroTopItem:__Delete()
    self:ClearAllAnim()
end

function HeroTopItem:__CacheObject()
    self.hpBgTrans = self:Find("hp",RectTransform)
    self.hpValueTrans = self:Find("hp/value",RectTransform)
    self.excHpValTrans = self:Find("hp/except_val",RectTransform)
    self.shieldValTrans = self:Find("hp/shield_val",RectTransform)

    self.energyNode = self:Find("energy").gameObject
    self.energyBgTrans = self:Find("energy",RectTransform)
    self.energyValueTrans = self:Find("energy/value",RectTransform)

    self.rectHit = self:Find("hp/hit",RectTransform)
    self.hpHitCanvasGroup = self:Find("hp/hit",CanvasGroup)

    self.hpValue =  self:Find("hp/value",Image)
    self.debugHpNode = self:Find("debug_hp").gameObject
    self.debugHp = self:Find("debug_hp",Text)
end

function HeroTopItem:__Create()
    self.srcHpBgSize = self:Find("hp").sizeDelta
    self.srcHpValueSize = self:Find("hp/value").sizeDelta

    self.srcEnergyBgSize = self:Find("energy").sizeDelta
    self.srcEnergyValueSize = self:Find("energy/value").sizeDelta

    self.srcBgSize = self.rectTrans.sizeDelta

    self.hpHitCanvasGroup.alpha = 0
end

function HeroTopItem:__Hide()
end

function HeroTopItem:InitTop(clientEntity)
    self:SetClientEntity(clientEntity)
    self.offsetY = clientEntity.entity.ObjectDataComponent.unitConf.top_offsety

    self.transform:SetLocalScale(1,1,1)

    local camp = self.clientEntity.entity.CampComponent:GetCamp()
    local hpTex = RunWorld.BattleMixedSystem:IsSelfCamp(camp) and UITex("battle/153") or UITex("battle/158")
    self:SetSprite(self.hpValue,hpTex)

    self:ResetData()

    local scale = self:GetUnitHpBarScale()

    self.curHpValueStartX = self.hpValueTrans.anchoredPosition.x
    self.curHpValueSizeX = self.srcHpValueSize.x * scale
    self.curEnergyValueSizeX = self.srcEnergyValueSize.x * scale

    UnityUtils.SetSizeDelata(self.hpBgTrans,self.srcHpBgSize.x * scale,self.srcHpBgSize.y)
    UnityUtils.SetSizeDelata(self.hpValueTrans,self.curHpValueSizeX,self.srcHpValueSize.y)

    UnityUtils.SetSizeDelata(self.energyBgTrans,self.srcEnergyBgSize.x * scale,self.srcEnergyBgSize.y)
    UnityUtils.SetSizeDelata(self.energyValueTrans,self.curEnergyValueSizeX,self.srcEnergyValueSize.y)

    self.debugHpNode:SetActive(DEBUG_HP == true)

    self:ActiveHp(true,false)
end

function HeroTopItem:GetUnitHpBarScale()
    return self.clientEntity.entity.ObjectDataComponent.unitConf.hp_scale
end

function HeroTopItem:GetHideLockUid()
    self.hideLockUid = self.hideLockUid + 1
    return self.hideLockUid
end

--是否处于强制隐藏锁的状态下
function HeroTopItem:IsForceHide()
    for uid, num in pairs(self.hideLocks) do
        if num > 0 then
            return true
        end
    end
    return false
end

--强制显示血条，不遵循显示规则，需要输入ForceHideHPByLock返回的锁Id，否则不能显示
function HeroTopItem:ForceShowHPByLock(uid)
    if not uid or not self.hideLocks[uid] or self.hideLocks[uid] <= 0 then
        return
    end
    self.hideLocks[uid] = self.hideLocks[uid] - 1
    self:ActiveHp(true,true)
end

--强制隐藏血条，不遵循显示规则，返回一个锁Id，用于ForceShowHPByLock解锁
function HeroTopItem:ForceHideHPByLock()
    local uid = self:GetHideLockUid()
    if not self.hideLocks[uid] then
        self.hideLocks[uid] = 0
    end
    self.hideLocks[uid] = self.hideLocks[uid] + 1
    self.gameObject:SetActive(false)
    return uid
end

--强制显隐血条，不遵循显示规则，优先级比强制锁低
function HeroTopItem:ForceActiveHP(flag)
    self:ActiveHp(flag,true)
end

---显隐血条
---@param flag boolean 显示还是隐藏
---@param forceChange boolean true代表不遵循显示规则, 否则: 当血量大于0且小于MaxHP时显示反之隐藏
function HeroTopItem:ActiveHp(flag,forceChange)
    if flag and self:IsForceHide() then
        -- LogYqh("HeroTopItem 锁级别强制隐藏",self.hideLocks)
        return
    end
    if self.isShow == flag then
        return
    end
    self.isShow = flag
    if forceChange then
        -- LogYqh("HeroTopItem 强制显隐",self.clientEntity.entity.uid,flag)
        self.gameObject:SetActive(flag)
    else
        self:CheckHpBarShow()
    end
    self:CheckEnergyBarShow()
    if self.isShow then
        self:RefreshPos()
        self:RefreshHpBar()
        self:RefreshEnergy()
    end
end

function HeroTopItem:SetDebug(flag)
    self.debugHpNode:SetActive(flag)
end

function HeroTopItem:RefreshHp()
    self:ForceActiveHP(true)
    self:RefreshHpBar()
end

function HeroTopItem:RefreshMaxHp()
    self:ForceActiveHP(true)
    self:RefreshHpBar()
end

function HeroTopItem:RefreshShield()
    self:ForceActiveHP(true)
    self:RefreshHpBar()
end

function HeroTopItem:RefreshEnergy()
    if not self.isShow then
        return
    end
    local maxEnergy = self.clientEntity.entity.AttrComponent:GetValue(GDefine.Attr.max_energy)
    local energy = self.clientEntity.entity.AttrComponent:GetValue(BattleDefine.Attr.energy)
    if maxEnergy == 0 then maxEnergy = 0.00001 end
    local fillAmount = Mathf.Clamp(energy / maxEnergy,0,1)

    UnityUtils.SetSizeDelata(self.energyValueTrans,self.curEnergyValueSizeX * fillAmount,self.srcEnergyValueSize.y)

    -- LogYqh("HeroTopItem 能量",self.clientEntity.entity.uid,energy,maxEnergy)
end

function HeroTopItem:CheckEnergyBarShow()
    local scale = self:GetUnitHpBarScale()
    local maxEnergy = self.clientEntity.entity.AttrComponent:GetValue(GDefine.Attr.max_energy)
    local showEnergy = maxEnergy > 0

    self.energyNode:SetActive(showEnergy)

    -- LogYqh("HeroTopItem 是否显示能量条",self.clientEntity.entity.uid,maxEnergy,showEnergy)

    if showEnergy then
        UnityUtils.SetSizeDelata(self.rectTrans,self.srcBgSize.x * scale, 14)
        UnityUtils.SetAnchoredPosition(self.hpBgTrans, 0, 3)
        UnityUtils.SetAnchoredPosition(self.energyBgTrans, 0, -3)
    else
        UnityUtils.SetSizeDelata(self.rectTrans,self.srcBgSize.x * scale, 8)
        UnityUtils.SetAnchoredPosition(self.hpBgTrans, 0, 0)
    end
end

function HeroTopItem:CheckHpBarShow()
    --满血不显示血条+能量条
    local hp = self.clientEntity.entity.AttrComponent:GetValue(BattleDefine.Attr.hp)
    local maxHp = self.clientEntity.entity.AttrComponent:GetValue(GDefine.Attr.max_hp)
    local showBar = hp < maxHp and hp > 0
    self.gameObject:SetActive(showBar)
    self.isShow = showBar

    -- LogYqh('HeroTopItem 是否显示血槽',self.clientEntity.entity.uid,hp,maxHp,showBar)
end

function HeroTopItem:RefreshHpBar()
    if not self.isShow then
        return
    end
    local maxHp = self.clientEntity.entity.AttrComponent:GetBaseValue(GDefine.Attr.max_hp)
    local addMaxHp = self.clientEntity.entity.AttrComponent:GetAddValue(GDefine.Attr.max_hp)
    local hp = self.clientEntity.entity.AttrComponent:GetValue(BattleDefine.Attr.hp)
    local shield = self.clientEntity.entity.AttrComponent:GetValue(BattleDefine.Attr.extra_hp)
    local totalFill = maxHp + addMaxHp + shield

    local hpWidth = self.curHpValueSizeX * (hp / totalFill)
    local maxHpWidth = self.curHpValueSizeX * (addMaxHp / totalFill)
    local shieldWidth = self.curHpValueSizeX * (shield / totalFill)

    UnityUtils.SetSizeDelata(self.rectHit, (hpWidth+maxHpWidth+shieldWidth), self.rectHit.sizeDelta.y)

    if self.lastHp ~= hp then
        UnityUtils.SetSizeDelata(self.excHpValTrans, maxHpWidth, self.srcHpValueSize.y)
        UnityUtils.SetSizeDelata(self.shieldValTrans, shieldWidth, self.srcHpValueSize.y)
        self:ShowHitAnim(HeroTopItem.BarType.HP,self.hpValueTrans,self.lastHp,hp,totalFill,hpWidth)
    end

    if self.lastAddMaxHp ~= addMaxHp then
        UnityUtils.SetSizeDelata(self.hpValueTrans, hpWidth, self.srcHpValueSize.y)
        UnityUtils.SetSizeDelata(self.shieldValTrans, shieldWidth, self.srcHpValueSize.y)
        self:ShowHitAnim(HeroTopItem.BarType.ADD_MAX_HP,self.excHpValTrans,self.lastAddMaxHp,addMaxHp,totalFill,maxHpWidth)
    end

    if self.lastShield ~= shield then
        UnityUtils.SetSizeDelata(self.hpValueTrans, hpWidth, self.srcHpValueSize.y)
        UnityUtils.SetSizeDelata(self.excHpValTrans, maxHpWidth, self.srcHpValueSize.y)
        self:ShowHitAnim(HeroTopItem.BarType.SHIELD,self.shieldValTrans,self.lastShield,shield,totalFill,shieldWidth)
    end

    --排序：当前血量>额外血量>血槽空缺
    local hpStart = self.curHpValueStartX
    local maxHpStart = hpStart + hpWidth
    local shieldStart = maxHpStart + maxHpWidth
    UnityUtils.SetAnchoredPosition(self.hpValueTrans,hpStart,0)
    UnityUtils.SetAnchoredPosition(self.excHpValTrans,maxHpStart,0)
    UnityUtils.SetAnchoredPosition(self.shieldValTrans,shieldStart,0)

    self:ShowDebugHP()

    self.lastHp = hp
    self.lastAddMaxHp = addMaxHp
    self.lastShield = shield
end

function HeroTopItem:ShowHitAnim(barType,trans,lastVal,curVal,totalVal,targetW)
    local delta = curVal - lastVal
    if delta > 0 then
        self.hpHitCanvasGroup.alpha = 0
        UnityUtils.SetSizeDelata(trans, targetW, self.srcHpValueSize.y)
    elseif delta < 0 then
        self.hpHitCanvasGroup.alpha = 1
        -- local time = math.abs(delta) / totalVal * 10
        local time = 0.18
        for _, anim in ipairs(self.hitAnims) do
            anim:Stop()
        end
        self.hitAnims[barType] = ParallelAnim.New({
            ToSizeDeltaAnim.New(trans, Vector2(targetW, self.srcHpValueSize.y), time),
            ToCanvasGroupAlphaAnim.New(self.hpHitCanvasGroup,0,time),
        })
        self.hitAnims[barType]:Play()
    end
end

function HeroTopItem:ShowDebugHP()
    if DEBUG_HP then
        local maxHp = self.clientEntity.entity.AttrComponent:GetBaseValue(GDefine.Attr.max_hp)
        local addMaxHp = self.clientEntity.entity.AttrComponent:GetAddValue(GDefine.Attr.max_hp)
        local hp = self.clientEntity.entity.AttrComponent:GetValue(BattleDefine.Attr.hp)
        local shield = self.clientEntity.entity.AttrComponent:GetValue(BattleDefine.Attr.extra_hp)
        local energy = self.clientEntity.entity.AttrComponent:GetValue(BattleDefine.Attr.energy)
        local maxEnergy = self.clientEntity.entity.AttrComponent:GetValue(GDefine.Attr.max_energy)
        local showStr = "血:" .. hp
        if maxHp ~= 0 then
            showStr = showStr .. "/" .. maxHp
        end
        if addMaxHp ~= 0 then
            showStr = showStr .. '\t增:' .. addMaxHp
        end
        if shield ~= 0 then
            showStr = showStr .. '\t盾:' .. shield
        end
        if maxEnergy > 0 then
            showStr = showStr .. '\t能:' .. energy .. '/' .. maxEnergy
        end
        self.debugHp.text = showStr
    end
end

function HeroTopItem:OnReset()
    self:ResetData()
    self.hpValue.fillAmount = 1
    self:ClearAllAnim()
end

function HeroTopItem:ClearAllAnim()
    for _, anim in ipairs(self.hitAnims) do
        anim:Destroy()
    end
    self.hitAnims = {}
end

-- function HeroTopItem:AddBuff(buffId,iconId)
--     if self.buffItems[buffId] then 
--         return 
--     end

--     local buffItem = PoolManager.Instance:Pop(PoolType.object,"buff_item") or GameObject.Instantiate(BattleDefine.buffItem)
--     buffItem.transform:SetParent(self.buffParent,false)

--     local icon = buffItem.transform:Find("icon").gameObject:GetComponent(Image)

--     self:SetSprite(icon,UtilsPath.GetSingleIcon(AssetConfig.buffIcon,iconId),nil,true)

--     self.buffItems[buffId] = { item = buffItem,icon = icon }
-- end

-- function HeroTopItem:CancelBuff(buffId)
-- 	if not self.buffItems[buffId] then 
--         return 
--     end

--     local info = self.buffItems[buffId]
--     self:RemoveSprite(info.icon)

--     self.buffItems[buffId] = nil

--     PoolManager.Instance:Push(PoolType.object,"buff_item",info.item)
-- end

function HeroTopItem.Create(clientEntity)
    local heroTopItem = PoolManager.Instance:Pop(PoolType.base_view,HeroTopItem.poolKey)
    if not heroTopItem then
        heroTopItem = HeroTopItem.New()
        local template = BattleDefine.uiObjs["template/entity_top/hero"]
        heroTopItem:SetObject(GameObject.Instantiate(template)) 
    end
    heroTopItem:SetParent(BattleDefine.uiObjs["entity_top"])
    heroTopItem:Show()
    heroTopItem:InitTop(clientEntity)
    return heroTopItem
end