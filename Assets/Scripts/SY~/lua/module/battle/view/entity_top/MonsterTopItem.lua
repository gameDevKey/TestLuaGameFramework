MonsterTopItem = BaseClass("MonsterTopItem",EntityTopBase)
MonsterTopItem.poolKey = "monster_top_item"

function MonsterTopItem:__Init()
    self.hpHitAnim = nil
end

function MonsterTopItem:__Delete()
end

function MonsterTopItem:__CacheObject()
    self.hpNode = self:Find("hp_node").gameObject
    self.hpValue =  self:Find("hp_node/hp",Image)
    self.hitImg =  self:Find("hp_node/hit",Image)
end

function MonsterTopItem:__Create()
    self.hpValue.fillAmount = 1
    self.hitImg.fillAmount = 1
end

function MonsterTopItem:__Hide()
end

function MonsterTopItem:InitTop(entity)
    self.entity = entity
    self.offsetY = entity.config.topOffsety
    self.gameObject.name = entity.gameObject.name

    self:ResetData()

    self.hpValue.fillAmount = 1
    self.hitImg.fillAmount = 1

    self:ActiveHp(false)

    local scale = 1
    if self.entity.config.type == BattleDefine.UnitCategoryType.monster then
        scale = 0.8
    elseif self.entity.config.type == BattleDefine.UnitCategoryType.elite then
        scale = 1
    elseif self.entity.config.type == BattleDefine.UnitCategoryType.boss then
        scale = 1.2
    end

    UnityUtils.SetSizeDelata(self.hpNode.transform,61 * scale,9 * scale)
end

function MonsterTopItem:ActiveHp(flag)
    if self.isShow == flag then
        return
    end

    self.isShow = flag
    self.gameObject:SetActive(flag)
    if self.isShow then
        self:RefreshPos()
        self:RefreshHp()
    end
end

function MonsterTopItem:RefreshHp()
    if not self.isShow then
        return
    end

    local maxHp = self.entity:GetTotalAttr(BattleDefine.Attr.max_hp)
    
    local hp = self.entity:GetTotalAttr(BattleDefine.Attr.hp)
    if maxHp == 0 then maxHp = 0.00001 end

    local fillAmount = Mathf.Clamp(hp / maxHp,0,1)

    self.hpValue.fillAmount = fillAmount

    local speedTime = Config.Get("battle","const","key",2).value
    local time = math.abs(fillAmount - self.hitImg.fillAmount) * speedTime

    if self.hpHitAnim then
        self.hpHitAnim:Clean()
    else
        self.hpHitAnim = FillAmountAnim.New(self.hitImg,fillAmount,time)
    end

    if fillAmount >= self.hitImg.fillAmount then
        self.hitImg.fillAmount = fillAmount
    else
        self.hpHitAnim:SetAttr("toValue",fillAmount)
        self.hpHitAnim:SetAttr("time",time)
        self.hpHitAnim:Play()
    end
end

function MonsterTopItem:OnReset()
    
end

function MonsterTopItem.Create(entity)
    local entityTop = PoolManager.Instance:Pop(PoolType.base_view,MonsterTopItem.poolKey)
    if not entityTop then
        entityTop = MonsterTopItem.New()
        local template = BattleDefine.uiObjs["template/entity_top/monster_item"]
        entityTop:SetObject(GameObject.Instantiate(template)) 
    end
    entityTop:SetParent(BattleDefine.uiObjs["entity_top_node"])
    entityTop:Show()
    entityTop:InitTop(entity)
    return entityTop
end