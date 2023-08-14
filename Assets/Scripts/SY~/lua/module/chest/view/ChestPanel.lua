ChestPanel = BaseClass("ChestPanel",BaseView)

ChestPanel.Event = EventEnum.New(
    "RefreshChestPanel",
    "ChestOpened"
)

function ChestPanel:__Init()
    self:SetViewType(UIDefine.ViewType.panel)
    self:SetAsset("ui/prefab/chest/chest_panel.prefab",AssetType.Prefab)

    self.chests = {}
    self.timers = {
        [1] = nil,
        [2] = nil,
        [3] = nil,
        [4] = nil,
    }

    self.maxChestCount = mod.ChestProxy.maxChestCount

    self.detailsPanel = nil
    self.chestOpenPanel = nil
end

function ChestPanel:__CacheObject()
    self.chestParent = self:Find("")
    self.chestItem = self:Find("chest_item").gameObject
end

function ChestPanel:__BindListener()

end

function ChestPanel:__BindEvent()
    self:BindEvent(ChestPanel.Event.RefreshChestPanel)
    self:BindEvent(ChestPanel.Event.ChestOpened)
end

function ChestPanel:__Create()
    self:InitChests()
end

function ChestPanel:__Show()
    self:RefreshChestPanel(mod.ChestProxy.chestDataList)
end

function ChestPanel:InitChests()
    for i=1, self.maxChestCount do
        local chest = GameObject.Instantiate(self.chestItem)
        chest.transform.position = Vector3(73, 187, 0)
        chest.transform:SetParent(self:Find("chest/chest"..i).gameObject.transform)
        chest.gameObject:SetActive(true)
        chest.transform:Reset()

        local item = {}
        item.chest = chest
        item.bg = chest.transform:Find("bg"):GetComponent(Image)
        item.btn = chest.transform:Find("bg"):GetComponent(Button)
        item.icon = chest.transform:Find("chest_icon"):GetComponent(Image)
        item.unlockTips = chest.transform:Find("unlock_tips").gameObject
        item.countdown = chest.transform:Find("countdown").gameObject
        item.countdownText = chest.transform:Find("countdown/text"):GetComponent(Text)
        item.openIcon = chest.transform:Find("open_icon").gameObject:GetComponent(Image)
        table.insert(self.chests,item)
    end
    self.chestItem:SetActive(false)
end

function ChestPanel:RefreshChestPanel(data)
    for i=1, self.maxChestCount do
        local v = data[i]
        self:SetChestData(i,v)
    end
end

function ChestPanel:SetChestData(index, data)
    if next(data) == nil then
        local chest = self.chests[index]
        chest.btn:SetClick( self:ToFunc("ShowChestDetails"),nil,nil,nil)
        chest.icon.gameObject:SetActive(false)
        chest.unlockTips:SetActive(false)
        chest.countdown:SetActive(false)
        chest.countdownText.text = ""
        chest.openIcon.gameObject:SetActive(false)
        return
    end

    local chest = self.chests[data.grid_id]
    local cfg = mod.ChestProxy:GetChestCfgById(data.chest_id)
    local remoteTime = nil
    local state = -1
    if data.lock_state == GDefine.ChestStateType.notUnlocked  then
        if mod.ChestProxy:CanUnlockNewChest() then
            state = GDefine.ChestStateType.notUnlocked
        else
            state = GDefine.ChestStateType.otherUnlocking
        end
    elseif data.lock_state == GDefine.ChestStateType.unlocked then
        remoteTime = Network.Instance:GetRemoteTimeByMS()
        if remoteTime < data.open_time then
            state = GDefine.ChestStateType.unlocking
        else
            state = GDefine.ChestStateType.countdownFinished
        end
    end
    self:SetSprite(chest.icon,AssetPath.GetChestIcon(data.chest_id,false),false)
    self:SetSprite(chest.openIcon,AssetPath.GetChestIcon(data.chest_id,true),false)
    chest.icon.gameObject:SetActive(true)
    chest.btn:SetClick( self:ToFunc("ShowChestDetails"),state,data,cfg)
    -- UnityUtils.SetAnchoredPosition(chest.icon.transform,1,-21.5)
    if state == GDefine.ChestStateType.notUnlocked or state == GDefine.ChestStateType.otherUnlocking then
        chest.unlockTips:SetActive(true)
        chest.countdown:SetActive(false)
        chest.countdownText.text = ""
        chest.openIcon.gameObject:SetActive(false)
    elseif state == GDefine.ChestStateType.unlocking then
        self:AddCountdownTimer(data.grid_id,data.open_time)
        chest.unlockTips:SetActive(false)
        chest.countdown:SetActive(true)
        chest.openIcon.gameObject:SetActive(false)
    elseif state == GDefine.ChestStateType.countdownFinished then
        UnityUtils.SetAnchoredPosition(chest.icon.transform,1,-1.5)
        chest.unlockTips:SetActive(false)
        chest.countdown:SetActive(false)
        chest.countdownText.text = ""
        chest.openIcon.gameObject:SetActive(true)
    end
end

function ChestPanel:ShowChestDetails(state,data,cfg)
    if not cfg then
        SystemMessage.Show(TI18N("1V1胜利获得宝箱"))
        return
    end
    if state == GDefine.ChestStateType.countdownFinished then
        mod.ChestFacade:SendMsg(10503,data.grid_id)
        return
    end

    if self.detailsPanel == nil then
        self.detailsPanel = ChestDetailsPanel.New()
        self.detailsPanel:SetParent(UIDefine.canvasRoot)
    end
    self.detailsPanel:SetData(state,data,cfg)
    self.detailsPanel:Show()
end

function ChestPanel:AddCountdownTimer(index,openTime)
    local timer = self.timers[index]
    if not timer then
        local remoteTime = math.floor(Network.Instance:GetRemoteTimeByMS())
        local lessTime = openTime - remoteTime
        self:Countdowning(index,lessTime)
        self.timers[index] = TimerManager.Instance:AddTimer(0,1, function()
            lessTime = lessTime - 1
            self:Countdowning(index,lessTime)
        end)
    else
        return
    end
end

function ChestPanel:Countdowning(index,lessTime)
    local chest = self.chests[index]
    local countdownChange = mod.ChestProxy.countdownChange
    local timeStr = TimeUtils.GetTimeFormat(lessTime)
    chest.countdownText.text = timeStr
    -- chest.consumeNum = math.ceil(lessTime/countdownChange[1]) * countdownChange[2]
    -- chest.consumeText.text = tostring(chest.consumeNum)
    -- UnityUtils.SetSizeDelata(chest.consumeText.transform,chest.consumeText.preferredWidth,chest.consumeText.preferredHeight)
    -- local width = chest.consumeText.transform.sizeDelta.x - chest.consumeText.transform.anchoredPosition.x
    -- local height = chest.consume.sizeDelta.y
    -- UnityUtils.SetSizeDelata(chest.consume,width,height)
    if lessTime <= 0 then
        local data = mod.ChestProxy.chestDataList
        mod.ChestFacade:SendEvent(ChestPanel.Event.RefreshChestPanel,data)
        self:RemoveTimer(index)
    end
end

function ChestPanel:ChestOpened(data)
    if self.chestOpenPanel == nil then
        self.chestOpenPanel = ChestOpenPanel.New()
        self.chestOpenPanel:SetParent(UIDefine.canvasRoot)
    end
    self.chestOpenPanel:SetData(data)
    self.chestOpenPanel:Show()
end

function ChestPanel:RemoveTimer(index)
    if not index then
        for k, v in pairs(self.timers) do
            TimerManager.Instance:RemoveTimer(v)
        end
        self.timers = {
            [1] = nil,
            [2] = nil,
            [3] = nil,
            [4] = nil,
        }
    else
        TimerManager.Instance:RemoveTimer(self.timers[index])
        self.timers[index] = nil
    end
end