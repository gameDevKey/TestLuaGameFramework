PlayerGuideProxy = BaseClass("PlayerGuideProxy",Proxy)

function PlayerGuideProxy:__Init()
    self.playerGuideView = nil
    self.guideDatas = nil
    self.guideActions = {}

    self.guideData = {}
    self.guideCfgData = {}

    self.lockScreenUid = 0
    self.lockScreens = {}

    self.maskInfo = {}
    self.maskIndex = 0

    self.listenPointerUid = 0
    self.listenPointers = List.New()
end

function PlayerGuideProxy:__Delete()
    if self.playerGuideView then
        self.playerGuideView:Destroy()
        self.playerGuideView = nil
    end
end

function PlayerGuideProxy:__InitProxy()
    --self:BindMsg(1110)
    self:BindMsg(10700)
    self:BindMsg(10701)
end

function PlayerGuideProxy:__InitComplete()
    -- self.guideCfgData=Config.GuideData.data_guide_info
    -- LogTable("引导数据",self.guideCfgData)
end

function PlayerGuideProxy:Recv_10700(data)
    LogTable("接收10700",data)
    self.guideDatas = data
end

function PlayerGuideProxy:Send_10701(guideId)
    local data = {}
    data.guide_id = guideId
    LogTable("发送10701",data)
    return data
end

function PlayerGuideProxy:Recv_10701(data)
    LogTable("接收10701",data)
    table.insert(self.guideDatas.guide_list,data.guide_id)
end

function PlayerGuideProxy:HasGuideGroup(group)
    for _,guideGroup in ipairs(self.guideDatas.guide_list) do
        if guideGroup == group then
            return true
        end
    end
    return false
end

function PlayerGuideProxy:HasRunGuideGroup(group)
    for i,v in ipairs(self.guideActions) do
        if v.conf.group == group then
            return true
        end
    end
    return false
end

function PlayerGuideProxy:AddGuideAction(guideAction)
    table.insert(self.guideActions,guideAction)
end

function PlayerGuideProxy:GetGuideAction(guideId)
    for i,v in ipairs(self.guideActions) do
        if v.guideId == guideId then
            return v
        end
    end
end

function PlayerGuideProxy:RemoveGuideAction(guideId)
    local index = nil
    for i,v in ipairs(self.guideActions) do
        if v.guideId == guideId then
            index = i
            break
        end
    end
    if index then
        table.remove(self.guideActions,index)
    end
end

function PlayerGuideProxy:SetLockScreen(flag,uid)
    if flag then
        local info = {uid = uid, traceback = debug.traceback()}
        self.lockScreens[uid] = info
    else
        self.lockScreens[uid] = nil
    end

    local isLock = TableUtils.IsEmpty(self.lockScreens) == false
    mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.LockScreen,isLock)
end

function PlayerGuideProxy:GetLockScreenUid()
    self.lockScreenUid = self.lockScreenUid + 1
    return self.lockScreenUid
end

function PlayerGuideProxy:SetListenPointer(flag,uid,pointerDownCb,pointerUpCb,pointerClickCb,args)
    if flag then
        local callBacks = { pointerDownCb = pointerDownCb,pointerUpCb = pointerUpCb,pointerClickCb = pointerClickCb,args = args}
        self.listenPointers:Push(callBacks,uid)
    else
        self.listenPointers:RemoveByIndex(uid)
    end
end

function PlayerGuideProxy:HasListenPointer(uid)
    return self.listenPointers:ExistIndex(uid)
end

function PlayerGuideProxy:GetListenPointerUid()
    self.listenPointerUid = self.listenPointerUid + 1
    return self.listenPointerUid
end

function PlayerGuideProxy:GetListenPointerNum()
    return self.listenPointers.length
end

function PlayerGuideProxy:GetMaskIndex()
    self.maskIndex = self.maskIndex + 1
    return self.maskIndex
end

function PlayerGuideProxy:SetMaskActive(active,maskId)
    if active then
        self.maskInfo[maskId] = true
    else
        self.maskInfo[maskId] = nil
    end
    local realActive = TableUtils.IsEmpty(self.maskInfo) == false
    mod.BattlePreInitCtrl:SetMaskCameraActive(realActive)
    mod.BattlePreInitCtrl:SetMaskPanelActive(realActive)
    mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.ShowMask,realActive)
end