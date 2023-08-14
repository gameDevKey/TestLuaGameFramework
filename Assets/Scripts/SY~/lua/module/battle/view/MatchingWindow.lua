MatchingWindow = BaseClass("MatchingWindow",BaseWindow)

MatchingWindow.Event = EventEnum.New(
	"MatchingSucceed"
)

function MatchingWindow:__Init()
    self:SetAsset("ui/prefab/battle/matching_window.prefab",AssetType.Prefab)
    self.waitTimer = nil
    self.time = 0
end

function MatchingWindow:__Delete()
    
end

function MatchingWindow:__CacheObject()
    self.waitTime = self:Find("main/time",Text)
    
    self.selfName = self:Find("main/self_node/info/name",Text)
    self.selfTrophy = self:Find("main/self_node/info/trophy",Text)

    self.targetSearch = self:Find("main/target_node/search").gameObject
    self.targetInfoNode = self:Find("main/target_node/info").gameObject
    self.targetName = self:Find("main/target_node/info/name",Text)
    self.targetTrophy = self:Find("main/target_node/info/trophy",Text)

    self.tipsText = self:Find("main/tips",Text)
end

function MatchingWindow:__BindListener()
    self:Find("main/cancel_btn",Button):SetClick(self:ToFunc("CancelClick"))
end

function MatchingWindow:__BindBeforeEvent()

end

function MatchingWindow:__Create()

end

function MatchingWindow:__BindEvent()
	self:BindEvent(MatchingWindow.Event.MatchingSucceed)
end

function MatchingWindow:__Show()
    --隐藏主菜单上下栏

    --显示信息
    self.waitTime.text = "00:00"
    self.waitTimer = TimerManager.Instance:AddTimer(0,1,self:ToFunc("WaitTiemr"))
    self.selfName.text = mod.RoleProxy.roleData.name
    self.selfTrophy.text = mod.RoleProxy.roleData.trophy

    self.targetSearch:SetActive(true)
    self.targetInfoNode:SetActive(false)

    local index = math.random(1,Config.PvpData.data_random_tips_length)
    self.tipsText.text = Config.PvpData.data_random_tips[index].tips
end

function MatchingWindow:__Hide()
    self:RemoveTimer()
    self:RemoveDelayTimer()
end

function MatchingWindow:WaitTiemr()
    self.time = self.time + 1
    self.waitTime.text = TimeUtils.GetMinSecTime(self.time)
end

function MatchingWindow:MatchingSucceed(data)
    --遍历得到对手
    local targetRoleData = nil
    for i,v in pairs(data.role_list) do
        if v.role_base.role_uid ~= mod.RoleProxy.roleData.role_uid then
            targetRoleData = v
            break
        end
    end

    self.targetSearch:SetActive(false)
    self.targetInfoNode:SetActive(true)
    self.targetName.text = targetRoleData.role_base.name
    self.targetTrophy.text = targetRoleData.role_base.trophy

    self:RemoveTimer()

    self.delayTimer = TimerManager.Instance:AddTimer(1,2,self:ToFunc("DelayTimer"))
end

function MatchingWindow:RemoveTimer()
    if self.waitTimer then
        TimerManager.Instance:RemoveTimer(self.waitTimer)
        self.waitTimer = nil
    end
end

function MatchingWindow:DelayTimer()
    self.delayTimer = nil
    ViewManager.Instance:OpenWindow(BattleLoadWindow)
    ViewManager.Instance:CloseWindow(MatchingWindow)
end

function MatchingWindow:RemoveDelayTimer()
    if self.delayTimer then
        TimerManager.Instance:RemoveTimer(self.delayTimer)
        self.delayTimer = nil
    end
end

function MatchingWindow:CancelClick()
    mod.BattleFacade:SendMsg(10416)
    ViewManager.Instance:CloseWindow(MatchingWindow)
end
