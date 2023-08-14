MixedEventTrigger = BaseClass("MixedEventTrigger",SECBEventTrigger)

function MixedEventTrigger:__Init()

end

function MixedEventTrigger:__Delete()
    
end

function MixedEventTrigger:OnRegister()
    self:AddHandler(BattleEvent.begin_battle,self:ToFunc("BeginBattleEvent"))
    self:AddHandler(BattleEvent.enter_round,self:ToFunc("EnterRound"))
    self:AddHandler(BattleEvent.be_home_hit,self:ToFunc("BeHomeHit"))
    self:AddHandler(BattleEvent.unit_ready_die,self:ToFunc("UnitReadyDie"))
    self:AddHandler(BattleEvent.unit_die,self:ToFunc("UnitDie"))
    self:AddHandler(BattleEvent.unit_moved,self:ToFunc("UnitMoved"))
    self:AddHandler(BattleEvent.begin_logic_running,self:ToFunc("BeginLogicRunning"))
    self:AddHandler(BattleEvent.pve_select_item,self:ToFunc("PveSelectItem"))
    self:AddHandler(BattleEvent.pve_select_item_begin,self:ToFunc("PveSelectItemBegin"))
    self:AddHandler(BattleEvent.key_data_count_change,self:ToFunc("KeyDataCountChange"))
    self:AddHandler(BattleEvent.unit_scale_change,self:ToFunc("UnitScaleChange"))
    self:AddHandler(BattleEvent.check_miss_hit,self:ToFunc("CheckMissHit"))
end

function MixedEventTrigger:BeginBattleEvent(listeners)
    for iter in listeners:Items() do
        iter.value.callBack(iter.value.uid)
    end
end

function MixedEventTrigger:EnterRound(listeners,round)
    local params = {}
    params.round = round

    for iter in listeners:Items() do
        iter.value.callBack(params,iter.value.uid)
    end
end

function MixedEventTrigger:BeHomeHit(listeners,homeUid,camp,val)
    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"homeUid",homeUid) 
            and self:CheckNum(args,false,"camp",camp) then
            iter.value.callBack(homeUid,val)
        end
    end
end

function MixedEventTrigger:UnitReadyDie(listeners,fromEntityUid,targetEntityUid,hitFlag)
    local dieEntity = self.world.EntitySystem:GetEntity(targetEntityUid)
    if not dieEntity.ObjectDataComponent then
        return
    end

    local params = {}
    params.fromEntityUid = fromEntityUid
    params.targetEntityUids = {targetEntityUid}

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"unitId",dieEntity.ObjectDataComponent.unitConf.id) 
            and self:CheckNum(args,false,"entityUid",dieEntity.uid)
            and self:CheckHasDict(args.hitFlags,true,hitFlag,true) then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function MixedEventTrigger:UnitDie(listeners,fromEntityUid,targetEntityUid)
    local dieEntity = self.world.EntitySystem:GetEntity(targetEntityUid)
    if not dieEntity.ObjectDataComponent then
        return
    end

    local params = {}
    params.fromEntityUid = fromEntityUid
    params.targetEntityUids = {targetEntityUid}
    params.dieEntityUid = targetEntityUid

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"unitId",dieEntity.ObjectDataComponent.unitConf.id) 
            and self:CheckNum(args,false,"dieEntityUid",targetEntityUid)
            and self:CheckEntity(args,fromEntityUid,targetEntityUid) then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function MixedEventTrigger:UnitMoved(listeners,movedEntityUid)
    local movedEntity = self.world.EntitySystem:GetEntity(movedEntityUid)
    if not movedEntity.ObjectDataComponent then
        return
    end
    for iter in listeners:Items() do
        iter.value.callBack(movedEntityUid)
    end
end

function MixedEventTrigger:BeginLogicRunning(listeners)
    for iter in listeners:Items() do
        iter.value.callBack(iter.value.uid)
    end
end

function MixedEventTrigger:PveSelectItem(listeners)
    for iter in listeners:Items() do
        iter.value.callBack(iter.value.uid)
    end
end

function MixedEventTrigger:PveSelectItemBegin(listeners)
    for iter in listeners:Items() do
        iter.value.callBack(iter.value.uid)
    end
end

function MixedEventTrigger:KeyDataCountChange(listeners,countKey,count)
    local params = {}
    params.countKey = countKey
    params.count = count

    for iter in listeners:Items() do
        local args = iter.value.args
        if  self:CheckStr(args,true,"countKey",countKey) then
            iter.value.callBack(params,iter.value.uid)
        end
    end
end

function MixedEventTrigger:UnitScaleChange(listeners,entityUid)
    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"entityUid",entityUid) then
            iter.value.callBack(entityUid)
        end
    end
end

function MixedEventTrigger:CheckMissHit(listeners,fromEntityUid,targetEntityUid,hitResultId)
    local params = {}
    params.hitResultId = hitResultId

    for iter in listeners:Items() do
        local args = iter.value.args
        if self:CheckNum(args,false,"entityUid",targetEntityUid) then
            local flag = iter.value.callBack(params,iter.value.uid)
            if flag then
                return true
            end
        end
    end
    return false
end