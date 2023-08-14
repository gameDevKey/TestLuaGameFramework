GuardTopItem = BaseClass("GuardTopItem",EntityTopBase)
GuardTopItem.poolKey = "guard_top_item"

function GuardTopItem:__Init()
    self.buffItems = {}

    self.isFlicker = false
    self.hpHitAnim = nil
    self.hpFlickerAnim = nil
end

function GuardTopItem:__Delete()

end

function GuardTopItem:__CacheObject()
    self.hpValue =  self:Find("hp_node/hp",Image)

    self.hpHit =  self:Find("hp_node/hp_hit",Image)
    self.hpHitNode = self:Find("hp_node/hp_hit").gameObject

    self.hpFlickerNode = self:Find("hp_node/hp_flicker").gameObject
    self.hpFlickerImg = self:Find("hp_node/hp_flicker",Image)

    self.lastNode = self:Find("last_node").gameObject
    self.lastAmount = self:Find("last_node/amount",Image)

    self.jobIcon = self:Find("job_node/icon",Image)

    self.hpHitNode:SetActive(false)
    self.hpFlickerNode:SetActive(false)
    self.lastNode:SetActive(false)

    self.buffParent = self:Find("buff_node")
end

function GuardTopItem:__Create()
    self:ActiveLast(false)
end

function GuardTopItem:__Hide()
    for k,v in pairs(self.buffItems) do
        self:RemoveSprite(v.icon)
        PoolManager.Instance:Push(PoolType.object,"buff_item",v.item)
    end
    self.buffItems = {}
end

function GuardTopItem:InitTop(entity)
	self.entity = entity
    self.offsetY = entity.config.topOffsety
    self.gameObject.name = entity.gameObject.name

    local config = self.entity.config
    self:SetSprite(self.jobIcon,GDefine.JobIcon[config.job],true)

    self:ResetData()

    self.hpValue.fillAmount = 1
    self.hpHit.fillAmount = 1
    
    self:ActiveHp(false)
end

function GuardTopItem:ActiveHp(flag)
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

function GuardTopItem:ActiveLast(flag)
    self.lastNode:SetActive(flag)
end

function GuardTopItem:SetLastAmount(amount)
    self.lastAmount.fillAmount = amount
end

function GuardTopItem:RefreshHp()
    if not self.isShow then
        return
    end

    local maxHp = self.entity:GetTotalAttr(BattleDefine.Attr.max_hp)

    local hp = self.entity:GetTotalAttr(BattleDefine.Attr.hp)
    if maxHp == 0 then maxHp = 0.00001 end

    local fillAmount = Mathf.Clamp(hp / maxHp,0,1)

    self.hpValue.fillAmount = fillAmount
    --self.hpFlickerImg.fillAmount = fillAmount

    --受击动效
    local speedTime = 0.5
    local time = math.abs(fillAmount - self.hpHit.fillAmount) * speedTime

    if self.hpHitAnim then
        self.hpHitAnim:Stop()
    else
        self.hpHitAnim = FillAmountAnim.New(self.hpHit,fillAmount,time)
        self.hpHitAnim:SetComplete(self:ToFunc("HitComplete"))
    end

    if fillAmount >= self.hpHit.fillAmount then
        self.hpHit.fillAmount = fillAmount
    else
        self.hpHitNode:SetActive(true)
        self.hpHitAnim:SetAttr("toValue",fillAmount)
        self.hpHitAnim:SetAttr("time",time)
        self.hpHitAnim:Play()
    end

    --血量过低时,血条闪动
    --50,0.3,0,{255,49,0}
    local checkPct = 50
    local checkValue = BattleUtils.CalPctValue(maxHp,checkPct)
    if not self.isFlicker and hp <= checkValue then
        self.isFlicker = true

        local flickerTime = 0.3
        local toAlpha = 0

        if self.hpFlickerAnim then
            self.hpFlickerAnim:Stop()
        else
            self.hpFlickerAnim = ToAlphaAnim.New(self.hpFlickerImg,toAlpha,flickerTime)
            self.hpFlickerAnim:SetLoop(-1, DG.Tweening.LoopType.Yoyo)
        end

        --local color = BattleData.data_const["101"].val[4]
        UnityUtils.SetColor(self.hpFlickerImg,1,0.192156,0,1)
        self.hpFlickerNode:SetActive(true)

        self.hpFlickerAnim:Play()
    elseif self.isFlicker and hp > checkValue then
        self.isFlicker = false
        self.hpFlickerNode:SetActive(false)

        if self.hpFlickerAnim then
            self.hpFlickerAnim:Stop()
        end
    end
end

function GuardTopItem:HitComplete()
    self.hpHitNode:SetActive(false)
end

function GuardTopItem:OnReset()
    self:ResetData()

    self.lastNode:SetActive(false)

    self.hpValue.fillAmount = 1
    self.hpHit.fillAmount = 1
    self.hpFlickerImg.fillAmount = 1

    self.isFlicker = false
    self.hpHitNode:SetActive(false)
    self.hpFlickerNode:SetActive(false)

    self:RemoveAnim()
end

function GuardTopItem:RemoveAnim()
    if self.hpHitAnim then
        self.hpHitAnim:Destroy()
        self.hpHitAnim = nil
    end

    if self.hpFlickerAnim then
        self.hpFlickerAnim:Destroy()
        self.hpFlickerAnim = nil
    end
end

function GuardTopItem:AddBuff(buffId,iconId)
    if self.buffItems[buffId] then 
        return 
    end

    local buffItem = PoolManager.Instance:Pop(PoolType.object,"buff_item") or GameObject.Instantiate(BattleDefine.buffItem)
    buffItem.transform:SetParent(self.buffParent,false)

    local icon = buffItem.transform:Find("icon").gameObject:GetComponent(Image)

    self:SetSprite(icon,UtilsPath.GetSingleIcon(AssetConfig.buffIcon,iconId),nil,true)

    self.buffItems[buffId] = { item = buffItem,icon = icon }
end

function GuardTopItem:CancelBuff(buffId)
	if not self.buffItems[buffId] then 
        return 
    end

    local info = self.buffItems[buffId]
    self:RemoveSprite(info.icon)

    self.buffItems[buffId] = nil

    PoolManager.Instance:Push(PoolType.object,"buff_item",info.item)
end

function GuardTopItem.Create(entity)
    local guardTopItem = PoolManager.Instance:Pop(PoolType.base_view,GuardTopItem.poolKey)
    if not guardTopItem then
        guardTopItem = GuardTopItem.New()
        local template = BattleDefine.uiObjs["template/entity_top/guard_item"]
        guardTopItem:SetObject(GameObject.Instantiate(template)) 
    end
    guardTopItem:SetParent(BattleDefine.uiObjs["entity_top_node"])
    guardTopItem:Show()
    guardTopItem:InitTop(entity)
    return guardTopItem
end