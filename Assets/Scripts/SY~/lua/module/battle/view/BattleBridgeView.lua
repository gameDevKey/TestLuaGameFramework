BattleBridgeView = BaseClass("BattleBridgeView",ExtendView)

BattleBridgeView.Event = EventEnum.New(
    "CacheBridgeState",
    "RefreshBridgeState",
    "BridgeAddCommanderExp",
    "BridgeAddCommanderSp",
    "FinishShowRewardItem"
)

function BattleBridgeView:__Init()
    self.rewardPos = {
        [1] = {x = -303, y = 133},  --根据阵营 桥1或桥2的x乘-1
        [2] = {x = 303, y = 133}
    }
    self.rewardTypeToImg = {
        [1] = "battle_1040",
        [2] = "battle_1024"
    }
    self.rewardItems = {}

    self.enable = false
end

function BattleBridgeView:__CacheObject()
    self.rewardItemParent = self:Find("main/fly_text")
    BattleDefine.uiObjs["template/fly_text/bridge_reward"] = self:Find("template/fly_text/bridge_reward").gameObject

end

function BattleBridgeView:__BindEvent()
    if not self.enable then
        return
    end
    self:BindEvent(BattleBridgeView.Event.CacheBridgeState)
    self:BindEvent(BattleBridgeView.Event.RefreshBridgeState)
    self:BindEvent(BattleBridgeView.Event.BridgeAddCommanderExp)
    self:BindEvent(BattleBridgeView.Event.BridgeAddCommanderSp)
    self:BindEvent(BattleBridgeView.Event.FinishShowRewardItem)
end

function BattleBridgeView:__Hide()
    if not self.enable then
        return
    end
    self:ClearRewardItem()
    self:RefreshBridgeState(1,BattleDefine.BridgeState.none)
    self:RefreshBridgeState(2,BattleDefine.BridgeState.none)
end

function BattleBridgeView:CacheBridgeState()
    self.bridgeState = {}
    self.bridgeState[1] = {}
    self.bridgeState[1].obj = BattleDefine.nodeObjs["mixed"]:Find("bridge/1").gameObject
    local mat = self.bridgeState[1].obj:GetComponent(MeshRenderer).material
    self.bridgeState[1].mat = mat
    self.bridgeState[2] = {}
    self.bridgeState[2].obj = BattleDefine.nodeObjs["mixed"]:Find("bridge/2").gameObject
    mat = self.bridgeState[2].obj:GetComponent(MeshRenderer).material
    self.bridgeState[2].mat = mat
end

function BattleBridgeView:RefreshBridgeState(index,state)
    -- LogError(">>>>>>>RefreshBridgeState",index,state)
    local selfCamp = RunWorld.BattleDataSystem.enterExtraData.selfCamp
    if state == BattleDefine.BridgeState.none then
        self.bridgeState[index].obj:SetActive(false)
    else
        if not self.bridgeState[index].obj.activeSelf then
            self.bridgeState[index].obj:SetActive(true)
        end
        if state == BattleDefine.BridgeState.capturing then
            self.bridgeState[index].mat:SetTextureOffset("_MainTex",Vector2(0,0))
        elseif state == selfCamp then
            self.bridgeState[index].mat:SetTextureOffset("_MainTex",Vector2(0,0.333))
        else
            self.bridgeState[index].mat:SetTextureOffset("_MainTex",Vector2(0,0.666))
        end
    end
end

function BattleBridgeView:BridgeAddCommanderExp(index,roleUid,num)
    self:ShowRewardItem(index,roleUid,num,1)
end

function BattleBridgeView:BridgeAddCommanderSp(index,roleUid,num)
    self:ShowRewardItem(index,roleUid,num,2)
end

-- rewardType 奖励类型 1：经验Exp 2：货币SP
function BattleBridgeView:ShowRewardItem(index,roleUid,num,rewardType)
    local args = {}
    args.imgPath = self.rewardTypeToImg[rewardType]
    local numText = "+"..tostring(num)
    if roleUid == RunWorld.BattleDataSystem.roleUid then
        numText = UIUtils.GetColorText(numText,"#5EBBF1")
    else
        numText = UIUtils.GetColorText(numText,"#F45959")
    end
    args.num = numText
    local rewardItem = BridgeRewardItem.Create(args)

    local selfCamp = RunWorld.BattleDataSystem.enterExtraData.selfCamp
    local dir = RunWorld.BattleMixedSystem:GetCampIndex(selfCamp)
    local pos = {}
    pos.x = self.rewardPos[index].x *dir
    pos.y = self.rewardPos[index].y

    rewardItem:SetParent(self.rewardItemParent,pos.x,pos.y)

    rewardItem:Show()

    self.rewardItems[rewardItem] = true
end

function BattleBridgeView:FinishShowRewardItem(item)
    if not self.rewardItems[item] then
        return
    end
    PoolManager.Instance:Push(PoolType.base_view,item.poolKey,item)
    self.rewardItems[item] = nil
end

function BattleBridgeView:ClearRewardItem()
    for item, v in pairs(self.rewardItems) do
        PoolManager.Instance:Push(PoolType.base_view,item.poolKey,item)
    end
    self.rewardItems = {}
end