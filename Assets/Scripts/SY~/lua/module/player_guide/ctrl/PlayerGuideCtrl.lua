PlayerGuideCtrl = BaseClass("PlayerGuideCtrl",Controller)

function PlayerGuideCtrl:__Init()
end

function PlayerGuideCtrl:__Delete()

end

function PlayerGuideCtrl:__InitComplete()
    EventManager.Instance:AddEvent(EventDefine.delay_preload_complete,self:ToFunc("DelayPreloadComplete"))
    EventManager.Instance:AddEvent(EventDefine.init_data_complete,self:ToFunc("InitDataComplete"))
end

function PlayerGuideCtrl:DelayPreloadComplete()
    local playerGuideAsset = PreloadManager.Instance:GetAsset(AssetPath.playerGuide)
    mod.PlayerGuideProxy.playerGuideView = PlayerGuideView.New()
    mod.PlayerGuideProxy.playerGuideView:SetObject(GameObject.Instantiate(playerGuideAsset))
    mod.PlayerGuideProxy.playerGuideView:SetParent(UIDefine.canvasRoot)
    mod.PlayerGuideProxy.playerGuideView:Show()
end

function PlayerGuideCtrl:InitDataComplete()
    self.firstGuideGroupId = self:GetFirstGuideGroupId()
    LogGuide("初始化数据完成 首个引导组是",self.firstGuideGroupId)
    self:CheckFirstEnter()
end

function PlayerGuideCtrl:GetFirstGuideGroupId()
    local min
    for id, _ in pairs(Config.PlayerGuideData.data_guide_group_info or {}) do
        if not min or min > id then
            min = id
        end
    end
    return min
end

function PlayerGuideCtrl:CheckFirstEnter()
    if PlayerGuideDefine.BanGuide then
        LogGuide("引导已关闭")
        return
    end

    LogGuide("已完成引导",mod.PlayerGuideProxy.guideDatas.guide_list)
    local startGuideGroups = {}

    local lastGuideGroups = {}
    for _,guideGroup in ipairs(mod.PlayerGuideProxy.guideDatas.guide_list) do
        lastGuideGroups[guideGroup] = true
    end

    for _,guideGroup in ipairs(mod.PlayerGuideProxy.guideDatas.guide_list) do
        local groupConf = self:GetGuideGroupInfoConf(guideGroup)
        for _,guideId in ipairs(groupConf) do
            local guideConf = self:GetGuideInfoConf(guideId)
            for _,nextGuideId in ipairs(guideConf.next_id) do
                local nextGuideConf = self:GetGuideInfoConf(nextGuideId)
                if not lastGuideGroups[nextGuideConf.group] then
                    lastGuideGroups[nextGuideConf.group] = true
                    table.insert(startGuideGroups,nextGuideConf.group)
                end
            end
        end
    end

    if #startGuideGroups <= 0 and #mod.PlayerGuideProxy.guideDatas.guide_list <= 0 then
        table.insert(startGuideGroups,self.firstGuideGroupId)
    end

    LogGuide("启动引导组",startGuideGroups)

    for _,guideGroup in ipairs(startGuideGroups) do
        local groupConf = self:GetGuideGroupInfoConf(guideGroup)
        self:BeginGuide(groupConf[1])
    end
end

function PlayerGuideCtrl:GetGuideInfoConf(guideId)
    local info = Config.PlayerGuideData.data_guide_info[guideId]
    if not info then
        error(string.format("访问了一个不存在的引导ID [%s]",tostring(guideId)))
    end
    return info
end

function PlayerGuideCtrl:GetGuideGroupInfoConf(groupId)
    local info = Config.PlayerGuideData.data_guide_group_info[groupId]
    if not info then
        error(string.format("访问了一个不存在的引导组ID [%s]",tostring(groupId)))
    end
    return info
end

function PlayerGuideCtrl:BeginGuide(guideId)
    LogGuide("引导开始",guideId)
    local guideAction = GuideAction.New()
    mod.PlayerGuideProxy:AddGuideAction(guideAction)

    guideAction:Init(guideId)
    guideAction:Start()
end

function PlayerGuideCtrl:NextGuide(guideId)
    local guideAction = mod.PlayerGuideProxy:GetGuideAction(guideId)
    if not guideAction then
        LogErrorAny("数据异常，无法完成引导",guideId)
        return
    end

    local conf = guideAction.conf

    mod.PlayerGuideProxy:RemoveGuideAction(guideId)
    guideAction:Delete()

    LogGuide("引导完成",guideId)
    if conf.save_id ~= 0 then
        LogGuide("保存引导",conf.save_id)
        mod.PlayerGuideFacade:SendMsg(10701,conf.save_id)
    end

    for _,nexeGuideId in ipairs(conf.next_id) do
        self:BeginGuide(nexeGuideId)
    end
end

function PlayerGuideCtrl:DebugGuideGroup(group)
    local flag = mod.PlayerGuideProxy:HasRunGuideGroup(group)
    if not flag then
        local groupConf = self:GetGuideGroupInfoConf(group)
        self:BeginGuide(groupConf[1])
    end
end

function PlayerGuideCtrl:CreateGuideTimeline()

end

function PlayerGuideCtrl:LockScreen()
    local uid = mod.PlayerGuideProxy:GetLockScreenUid()
    mod.PlayerGuideProxy:SetLockScreen(true,uid)
    return uid
end

function PlayerGuideCtrl:CancelLockScreen(uid)
    if not uid or uid == 0 then
        assert(false,string.format("新手引导取消锁屏异常，无效的锁屏uid[%s]",tostring(uid)))
    end
    mod.PlayerGuideProxy:SetLockScreen(false,uid)
end


function PlayerGuideCtrl:ListenPointer(pointerDownCb,pointerUpCb,pointerClickCb,args)
    local uid = mod.PlayerGuideProxy:GetListenPointerUid()
    mod.PlayerGuideProxy:SetListenPointer(true,uid,pointerDownCb,pointerUpCb,pointerClickCb,args)

    local num = mod.PlayerGuideProxy:GetListenPointerNum()
    if num == 1 then
        mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.ActiveListenPointer,true)
    end

    return uid
end

function PlayerGuideCtrl:CancelListenPointer(uid)
    if not uid or uid == 0 then
        assert(false,string.format("新手引导取消监听手指异常，无效的监听uid[%s]",tostring(uid)))
    end

    if not mod.PlayerGuideProxy:HasListenPointer(uid) then
        assert(false,string.format("新手引导取消手指监听异常，不存在的监听uid[%s]",tostring(uid)))
    end

    mod.PlayerGuideProxy:SetListenPointer(false,uid)

    local num = mod.PlayerGuideProxy:GetListenPointerNum()
    if num == 0 then
        mod.PlayerGuideFacade:SendEvent(PlayerGuideView.Event.ActiveListenPointer,false)
    end
end