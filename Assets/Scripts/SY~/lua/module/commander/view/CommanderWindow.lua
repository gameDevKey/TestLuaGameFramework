CommanderWindow = BaseClass("CommanderWindow", BaseWindow)
CommanderWindow.__topInfo = true
CommanderWindow.__bottomTab = true
CommanderWindow.__adaptive = true

function CommanderWindow:__Init()
    self:SetAsset("ui/prefab/commander/commander_window.prefab", AssetType.Prefab)
    self:AddAsset("effect/9200000.prefab", AssetType.Prefab)
    self.curTab = nil
end

function CommanderWindow:__Delete()

end

function CommanderWindow:__ExtendView()
    self.pveView = self:ExtendView(CommanderPveView)
    self.pvpView = self:ExtendView(CommanderPvpView)
end

function CommanderWindow:__CacheObject()
    self.tabObjs = {}
    for i = 1, 2 do self:GetTabObj(i) end

    self.pveNode = self:Find("main/pve").gameObject
    self.pvpNode = self:Find("main/pvp").gameObject
end

function CommanderWindow:GetTabObj(index)
    local objs = {}
    local item = self:Find("main/tab_node/"..tostring(index)).gameObject
    objs.gameObject = item
    objs.normal = item.transform:Find("normal").gameObject
    objs.select = item.transform:Find("select").gameObject
    objs.btn = item.transform:Find("normal/btn").gameObject:GetComponent(Button)
    self.tabObjs[index] = objs
end

function CommanderWindow:__BindListener()
    for i,v in ipairs(self.tabObjs) do
        v.btn:SetClick(self:ToFunc("SwitchTab"),i)
    end
end

function CommanderWindow:__BindEvent()

end

function CommanderWindow:__Create()

end

function CommanderWindow:__Show()
    self:SwitchTab(1)

    local rewards = {}
    local rewardDict = {}

    for i,v in ipairs(mod.TreasureChestProxy.cacheAutoOpenRewards) do
        for _,info in ipairs(v) do
            local reward = nil
            if not rewardDict[info.key] then
                reward = {item_id = info.key,count = 0}
                table.insert(rewards,reward)
                rewardDict[info.key] = reward
            else
                reward = rewardDict[info.key]
            end
            reward.count = reward.count + info.val
        end
    end
    mod.TreasureChestProxy.cacheAutoOpenRewards = {}

    if #rewards > 0 then
        ViewManager.Instance:OpenWindow(AwardWindow,{itemList = rewards})
    end
end

function CommanderWindow:SwitchTab(index)
    if self.curTab and self.curTab == index then
        return
    end

    self.curTab = index

    self:RefreshTab(self.curTab)

    self.pveNode:SetActive(index == 1)
    self.pvpNode:SetActive(index == 2)

    if index == 1 then
        self.pveView:FirstPlayChestAnim()
    end
end 

function CommanderWindow:RefreshTab()
    for i,v in ipairs(self.tabObjs) do
        v.normal:SetActive(i ~= self.curTab)
        v.select:SetActive(i == self.curTab)
    end
end