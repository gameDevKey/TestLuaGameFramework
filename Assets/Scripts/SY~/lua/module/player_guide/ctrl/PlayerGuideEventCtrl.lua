PlayerGuideEventCtrl = BaseClass("PlayerGuideEventCtrl",Controller)

function PlayerGuideEventCtrl:__Init()
    self.uid = 0
    self.eventListeners = {}
    self.uidToEvent = {}
end

function PlayerGuideEventCtrl:__InitComplete()

end

function PlayerGuideEventCtrl:Trigger(eventType,...)
    --TODO:没有引导直接return
    local listeners = self.eventListeners[eventType]
    if listeners then
        self[eventType](self,listeners,...)
    end
end

function PlayerGuideEventCtrl:AddListener(event,callBack,args)
    if not event or not callBack then
        assert(false,string.format("添加引导事件回调异常,事件、回调函数为空[事件:%s][回调函数:%s]",tostring(event),tostring(callBack)))
        return 
    end

    if not self.eventListeners[event] then
        self.eventListeners[event] = List.New()
    end

    self.uid = self.uid + 1
    self.eventListeners[event]:Push({uid = self.uid,callBack = callBack,args = args},self.uid)
    self.uidToEvent[self.uid] = event
    return self.uid
end

function PlayerGuideEventCtrl:RemoveListener(uid)
    if not self.uidToEvent[uid] then
        assert(false,string.format("移除未知的引导事件[uid:%s]",tostring(uid)))
        return
    end
  
    local event = self.uidToEvent[uid]
    self.uidToEvent[uid] = nil
    self.eventListeners[event]:RemoveByIndex(uid)
end


--以下为具体事件派发
function PlayerGuideEventCtrl:EnterBattle(listeners,pvpId)
    local params = {}
    params.pvpId = pvpId

    for iter in listeners:Items() do
        local args = iter.value.args
        if args.pvpId == pvpId then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function PlayerGuideEventCtrl:RandomUnit(listeners)
    local params = {}
    params.pvpId = pvpId

    for iter in listeners:Items() do
        local args = iter.value.args
        iter.value.callBack(params,iter.value.uid)
    end
end

function PlayerGuideEventCtrl:BeginGroup(listeners,group)
    local params = {}
    params.group = group

    for iter in listeners:Items() do
        local args = iter.value.args
        if args.group == 0 or args.group == group then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function PlayerGuideEventCtrl:OnRoundBegin(listeners,round,roundTime)
    local params = {}
    params.round = round
    params.roundTime = roundTime

    for iter in listeners:Items() do
        local args = iter.value.args
        if args.round == round then
            if roundTime >= args.delay then
                iter.value.callBack(params,iter.value.uid)
            end
        end
    end
end

function PlayerGuideEventCtrl:CaptureBridge(listeners,roadIndex)
    local params = {}
    params.roadIndex = roadIndex

    for iter in listeners:Items() do
        iter.value.callBack(params,iter.value.uid)
    end
end

function PlayerGuideEventCtrl:RoleUpdateMoney(listeners,roleUid,money)
    local params = {}
    params.money = money

    for iter in listeners:Items() do
        local args = iter.value.args
        if (args.roleUid == 0 or args.roleUid == roleUid) and money >= args.toMoney then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end


function PlayerGuideEventCtrl:UnlockGrid(listeners,grid)
    local params = {}
    params.grid = grid

    for iter in listeners:Items() do
        local args = iter.value.args
        iter.value.callBack(params,iter.value.uid)
    end
end

function PlayerGuideEventCtrl:OpenUnitTips(listeners,unitId)
    local params = {}
    params.unitId = unitId

    for iter in listeners:Items() do
        local args = iter.value.args
        iter.value.callBack(params,iter.value.uid)
    end
end


function PlayerGuideEventCtrl:UseMagicCard(listeners)
    local params = {}

    for iter in listeners:Items() do
        local args = iter.value.args
        iter.value.callBack(params,iter.value.uid)
    end
end


function PlayerGuideEventCtrl:CommanderUpStar(listeners,roleUid,money)
    local params = {}
    for iter in listeners:Items() do
        local args = iter.value.args
        if args.roleUid == 0 or args.roleUid == roleUid then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function PlayerGuideEventCtrl:KillUnit(listeners,fromEntityUid,killEntityUid)
    local fromUnitId = RunWorld.EntitySystem:GetEntityUnitId(fromEntityUid)
    local killUnitId = RunWorld.EntitySystem:GetEntityUnitId(killEntityUid)
    if not fromUnitId or not killUnitId then
        return
    end

    local params = {}
    for iter in listeners:Items() do
        local args = iter.value.args
        if (args.fromUnitId == 0 or args.fromUnitId == fromUnitId) and args.killUnitId == killUnitId then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end


function PlayerGuideEventCtrl:RefreshPlaceUnit(listeners)
    local params = {}
    for iter in listeners:Items() do
        iter.value.callBack(params,iter.value.uid)
    end
end

function PlayerGuideEventCtrl:SwapUnitGrid(listeners,fromGrid,toGrid)
    local params = {}
    for iter in listeners:Items() do
        local args = iter.value.args
        if args.fromGrid == fromGrid and args.toGrid == toGrid then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function PlayerGuideEventCtrl:UseRageSkill(listeners)
    for iter in listeners:Items() do
        local args = iter.value.args
        iter.value.callBack(nil,iter.value.uid)
    end
end

function PlayerGuideEventCtrl:UsePveSkill(listeners)
    for iter in listeners:Items() do
        iter.value.callBack(nil,iter.value.uid)
    end
end

function PlayerGuideEventCtrl:TriggerGuide(listeners,guideId)
    for iter in listeners:Items() do
        local args = iter.value.args
        if args.guideIds[guideId] then
            iter.value.callBack(nil,iter.value.uid)
        end
    end
end

function PlayerGuideEventCtrl:UnitUpStar(listeners,roleUid,unitId,star)
    for iter in listeners:Items() do
        local args = iter.value.args
        if (args.roleUid == 0 or args.roleUid == roleUid) 
            and (args.unitId == 0 or args.unitId == unitId) and args.star == star then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function PlayerGuideEventCtrl:OnViewOpen(listeners,viewName)
    local params = {}
    params.name = viewName

    for iter in listeners:Items() do
        local args = iter.value.args
        if args.name == viewName then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function PlayerGuideEventCtrl:OnViewClose(listeners,viewName)
    local params = {}
    params.name = viewName

    for iter in listeners:Items() do
        local args = iter.value.args
        if args.name == viewName then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function PlayerGuideEventCtrl:OnCardConfig(listeners)
    for iter in listeners:Items() do
        iter.value.callBack(nil,iter.value.uid)
    end
end

function PlayerGuideEventCtrl:OnDivisionChange(listeners, beforeDivision, curDivision)
    for iter in listeners:Items() do
        local args = iter.value.args
        if args.division == curDivision then
            iter.value.callBack(nil,iter.value.uid)
        end
    end
end

function PlayerGuideEventCtrl:OnDivisionReach(listeners, division)
    for iter in listeners:Items() do
        local args = iter.value.args
        if args.division == division then
            iter.value.callBack(nil,iter.value.uid)
        end
    end
end

function PlayerGuideEventCtrl:OnDivisionRewardUncliamed(listeners)
    for iter in listeners:Items() do
        iter.value.callBack(nil,iter.value.uid)
    end
end

function PlayerGuideEventCtrl:OnPVPWin(listeners)
    for iter in listeners:Items() do
        iter.value.callBack(nil,iter.value.uid)
    end
end

function PlayerGuideEventCtrl:OnPVEWin(listeners)
    for iter in listeners:Items() do
        iter.value.callBack(nil,iter.value.uid)
    end
end

function PlayerGuideEventCtrl:OnPveGroupBegin(listeners, pveId, group)
    for iter in listeners:Items() do
        local args = iter.value.args
        if (args.pveId <= 0 or args.pveId == pveId) and (args.group <= 0 or args.group == group) then
            iter.value.callBack(nil,iter.value.uid)
        end
    end
end

function PlayerGuideEventCtrl:EnterTargetPVP(listeners, data)
    for iter in listeners:Items() do
        local args = iter.value.args
        if args.maxCount == data.maxCount then
            iter.value.callBack(nil,iter.value.uid)
        end
    end
end

function PlayerGuideEventCtrl:EnterTargetPVE(listeners, data)
    for iter in listeners:Items() do
        local args = iter.value.args
        if args.pveId == 0 or args.pveId == data.pveId then
            iter.value.callBack(nil,iter.value.uid)
        end
    end
end

function PlayerGuideEventCtrl:OnCommanderDie(listeners, isSelf)
    for iter in listeners:Items() do
        local args = iter.value.args
        if args.isSelf == isSelf then
            iter.value.callBack(nil,iter.value.uid)
        end
    end
end

function PlayerGuideEventCtrl:OnFuncUnlock(listeners, changeList)
    for iter in listeners:Items() do
        local args = iter.value.args
        if changeList[args.funcId] then
            iter.value.callBack(nil,iter.value.uid)
        end
    end
end

function PlayerGuideEventCtrl:OnFuncAlreadyUnlock(listeners, changeList)
    for iter in listeners:Items() do
        local args = iter.value.args
        if changeList[args.funcId] then
            iter.value.callBack(nil,iter.value.uid)
        end
    end
end