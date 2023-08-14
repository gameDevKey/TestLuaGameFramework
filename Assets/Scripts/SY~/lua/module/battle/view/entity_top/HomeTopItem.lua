HomeTopItem = BaseClass("HomeTopItem",EntityTopBase)
HomeTopItem.poolKey = "home_top_item"
HomeTopItem.NO_REFRESH_POS = true

function HomeTopItem:__Init()

end

function HomeTopItem:__Delete()

end

function HomeTopItem:__CacheObject()
    self.hpValue = self:Find("hp",Image)
    self.hpNum = self:Find("hp_num",Text)
    self.expValue = self:Find("exp",Image)
    self.starNum = self:Find("star_num",Text)
    self.starImg = self:Find("star",Image)
end

function HomeTopItem:__Create()
end

function HomeTopItem:__Hide()

end

function HomeTopItem:InitTop(clientEntity)
    self:SetClientEntity(clientEntity)
    self.offsetY = clientEntity.entity.ObjectDataComponent.unitConf.top_offsety


    local camp = self.clientEntity.entity.CampComponent:GetCamp()

    if RunWorld.BattleMixedSystem:IsSelfCamp(camp) then
        self:SetSprite(self.hpValue,UITex("battle/77"))
        self.offsetY = self.offsetY - 170 + 12
    else
        self:SetSprite(self.hpValue,UITex("battle/78"))
        self.offsetY = self.offsetY + 30
    end
    self:ResetData()
    
    self:ActiveHp(true)
end

function HomeTopItem:ActiveHp(flag)
    if self.isShow == flag then
        return
    end

    self.isShow = flag
    self.gameObject:SetActive(flag)
    if self.isShow then
        self:RefreshPos()
        self:RefreshHp()
        -- self:RefreshExp()
        self:RefreshRage()
    end
end

function HomeTopItem:RefreshHp()
    if not self.isShow then
        return
    end

    local maxHp = self.clientEntity.entity.AttrComponent:GetValue(GDefine.Attr.max_hp)

    local hp = self.clientEntity.entity.AttrComponent:GetValue(BattleDefine.Attr.hp)
    if maxHp == 0 then maxHp = 0.00001 end

    local fillAmount = Mathf.Clamp(hp / maxHp,0,1)

    self.hpValue.fillAmount = fillAmount
    self.hpNum.text = hp
end

function HomeTopItem:RefreshRage(rage,maxRage)
    if not self.isShow then
        return
    end
    local fillAmount = 0
    if rage == nil then
        rage = 0
        maxRage = 1
    end
    fillAmount = Mathf.Clamp(rage / maxRage,0,1)

    self.expValue.fillAmount = fillAmount
end

function HomeTopItem:RefreshExp(star,exp,maxExp,isMax)
    if not self.isShow then
        return
    end
    local fillAmount = 0
    if star ==nil then
        star = 1
        exp = 0
        maxExp = 1
        isMax = false
    end
    fillAmount = Mathf.Clamp(exp / maxExp,0,1)
    if isMax then
        fillAmount = 1
        self:SetSprite(self.starImg,UITex("battle/battle_1021"))
    else
        self:SetSprite(self.starImg,UITex("battle/battle_1022"))
    end
    self.expValue.fillAmount = fillAmount
    self.starNum.text = star
    
end

function HomeTopItem:OnReset()
    self:ResetData()
end

function HomeTopItem.Create(clientEntity)
    local homeTopItem = PoolManager.Instance:Pop(PoolType.base_view,HomeTopItem.poolKey)
    if not homeTopItem then
        homeTopItem = HomeTopItem.New()
        local template = BattleDefine.uiObjs["template/entity_top/home"]
        homeTopItem:SetObject(GameObject.Instantiate(template)) 
    end
    homeTopItem:SetParent(BattleDefine.uiObjs["entity_top"])
    homeTopItem:Show()
    homeTopItem:InitTop(clientEntity)
    return homeTopItem
end