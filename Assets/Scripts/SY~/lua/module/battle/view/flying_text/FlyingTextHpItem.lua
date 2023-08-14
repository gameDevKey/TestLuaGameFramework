FlyingTextHpItem = BaseClass("FlyingTextHpItem",BaseView)

FlyingTextHpItem.PoolKey = 
{
    heal_item = "heal_item",
    dmg_item = "dmg_item",
}

function FlyingTextHpItem:__Init(poolKey)
    self.poolKey = poolKey
    self.beginPos = nil
end

function FlyingTextHpItem:__Delete()
    self:RemoveAnim()
end

--用于获取组件,在第一次创建的时候调用，只会调用一次
function FlyingTextHpItem:__CacheObject()
    self.numText = self:Find(nil,Text)
end

function FlyingTextHpItem:__Show()
    self.numText.text = self.showText
    self.beginPos = self.rectTrans.anchoredPosition

    self:CreateAnim()
    self.textAnim:SetComplete(self:ToFunc("PlayAnimComplete"))
    self.textAnim:Play()
end

function FlyingTextHpItem:CreateAnim()
    -- UnityUtils.SetTextColor(self.numText,1,1,1,1)
    -- UnityUtils.SetLocalScale(self.rectTrans,1,1,1)

    if self.poolKey == FlyingTextHpItem.PoolKey.dmg_item and not self.isCrit then
        self.textAnim = FlyingTextUtils.GetDmgAnimTween(self.rectTrans,self.numText,self.beginPos)
    elseif self.poolKey == FlyingTextHpItem.PoolKey.dmg_item and self.isCrit then --无暴击物理伤害
        self.textAnim = FlyingTextUtils.GetCritAnimTween(self.rectTrans,self.numText,self.beginPos)
    elseif self.poolKey == FlyingTextHpItem.PoolKey.heal_item and not self.isCrit then
        self.textAnim = FlyingTextUtils.GetHealAnimTween(self.rectTrans,self.numText,self.beginPos)
    elseif self.poolKey == FlyingTextHpItem.PoolKey.heal_item and self.isCrit then
        self.textAnim = FlyingTextUtils.GetHealAnimTween(self.rectTrans,self.numText,self.beginPos)
    end
end

function FlyingTextHpItem:PlayAnimComplete()
    mod.BattleFacade:SendEvent(FlyingTextView.Event.FinishFlyingText,self)
end

function FlyingTextHpItem:__Hide()
    self:RemoveAnim()
end

function FlyingTextHpItem:RemoveAnim()
    if self.textAnim then
        self.textAnim:Delete()
        self.textAnim = nil
    end
end

function FlyingTextHpItem:OnReset()

end

function FlyingTextHpItem.Create(args,onComplete)
    local poolKey = nil
    local itemTemplate = nil
    local showText = nil
    local changeValue = args.value
    
    if changeValue > 0 and not args.isCrit then --加血
        poolKey = FlyingTextHpItem.PoolKey.heal_item
        itemTemplate = BattleDefine.uiObjs["template/fly_text/heal"]
        showText = changeValue
    elseif changeValue > 0 and args.isCrit then
        poolKey = FlyingTextHpItem.PoolKey.heal_item
        itemTemplate = BattleDefine.uiObjs["template/fly_text/heal"]
        showText = changeValue
    elseif changeValue < 0 and not args.isCrit then --伤害，非暴击
        poolKey = FlyingTextHpItem.PoolKey.dmg_item
        itemTemplate = BattleDefine.uiObjs["template/fly_text/dmg"]
        showText = math.abs(changeValue)
    elseif changeValue < 0 and args.isCrit then --伤害，暴击
        poolKey = FlyingTextHpItem.PoolKey.dmg_item
        itemTemplate = BattleDefine.uiObjs["template/fly_text/dmg"]
        showText = math.abs(changeValue)
    elseif changeValue == 0 then
        poolKey = FlyingTextHpItem.PoolKey.dmg_item
        itemTemplate = BattleDefine.uiObjs["template/fly_text/dmg"]
        showText = changeValue
    end

    local item = PoolManager.Instance:Pop(PoolType.base_view,poolKey)
    if not item then
        item = FlyingTextHpItem.New(poolKey)
        item:SetObject(GameObject.Instantiate(itemTemplate))
    end

    item.showText = showText
    item.isCrit = args.isCrit
    return item
end