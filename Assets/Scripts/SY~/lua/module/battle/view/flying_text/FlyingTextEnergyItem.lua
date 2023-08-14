FlyingTextEnergyItem = BaseClass("FlyingTextEnergyItem",BaseView)

FlyingTextEnergyItem.PoolKey =
{
    hit_energy_item = "hit_energy_item",
    add_energy_item = "add_energy_item"
}

function FlyingTextEnergyItem:__Init(poolKey)
    self.poolKey = poolKey
    self.beginPos = nil
end

function FlyingTextEnergyItem:__Delete()
    self:RemoveAnim()
end

--用于获取组件,在第一次创建的时候调用，只会调用一次
function FlyingTextEnergyItem:__CacheObject()
    self.numText = self:Find(nil,Text)
end

function FlyingTextEnergyItem:__Show()
    self.numText.text = self.showText
    self.beginPos = self.rectTrans.anchoredPosition

    self:CreateAnim()
    self.textAnim:SetComplete(self:ToFunc("PlayAnimComplete"))
    self.textAnim:Play()
end

function FlyingTextEnergyItem:CreateAnim()
    if self.poolKey == FlyingTextEnergyItem.PoolKey.hit_energy_item then
        self.textAnim = FlyingTextUtils.GetHealAnimTween(self.rectTrans,self.numText,self.beginPos)
    elseif self.poolKey == FlyingTextEnergyItem.PoolKey.add_energy_item then
        self.textAnim = FlyingTextUtils.GetHealAnimTween(self.rectTrans,self.numText,self.beginPos)
    end
end

function FlyingTextEnergyItem:PlayAnimComplete()
    mod.BattleFacade:SendEvent(FlyingTextView.Event.FinishFlyingText,self)
end

function FlyingTextEnergyItem:__Hide()
    self:RemoveAnim()
end

function FlyingTextEnergyItem:RemoveAnim()
    if self.textAnim then
        self.textAnim:Delete()
        self.textAnim = nil
    end
end

function FlyingTextEnergyItem:OnReset()

end

function FlyingTextEnergyItem.Create(args,onComplete)
    local poolKey = nil
    local itemTemplate = nil
    local showText = nil
    local changeValue = args.value
    
    if changeValue < 0 then --扣除能量
        poolKey = FlyingTextEnergyItem.PoolKey.hit_energy_item
        itemTemplate = BattleDefine.uiObjs["template/fly_text/energy"]
        showText = math.abs(changeValue)
    elseif changeValue > 0 then --增加能量
        poolKey = FlyingTextEnergyItem.PoolKey.add_energy_item
        itemTemplate = BattleDefine.uiObjs["template/fly_text/energy"]
        showText = changeValue
    end

    local item = PoolManager.Instance:Pop(PoolType.base_view,poolKey)
    if not item then
        item = FlyingTextEnergyItem.New(poolKey)
        item:SetObject(GameObject.Instantiate(itemTemplate))
    end

    item.showText = showText
    return item
end