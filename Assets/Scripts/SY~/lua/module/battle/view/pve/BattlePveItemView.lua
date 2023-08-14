BattlePveItemView = BaseClass("BattlePveItemView",ExtendView)

BattlePveItemView.Event = EventEnum.New(
    "RefreshItem",
    "RefreshItemCd",
    "GetSkillBtn"
)

function BattlePveItemView:__Init()
    self.itemObjects = {}
    self.itemInfos = {}

    self.beginPos = nil
    self.OnDragItemDown = self:ToFunc("DragItemDown")
end

function BattlePveItemView:__Delete()
end

function BattlePveItemView:__Hide()
end

function BattlePveItemView:__CacheObject()
    for i = 1, 4 do self:GetItemObject(i) end
    self.canvas = self:Find("main/operate_con/item_con",Canvas)
end

function BattlePveItemView:__Create()
    self.canvas.sortingOrder = self:GetOrder() + GDefine.EffectOrderAdd
end

function BattlePveItemView:GetItemObject(index)
    local object = {}
    local item = self:Find("main/operate_con/item_con/item_"..tostring(index)).gameObject
    object.gameObject = item
    object.transform = item.transform

    object.main = item.transform:Find("main").gameObject
    object.empty = item.transform:Find("empty").gameObject

    object.pointerHandler = object.main:GetComponent(PointerHandler)
    object.pointerHandler:SetOwner(self,"OnDragItemDown","","")
    object.pointerHandler.isPointerDown = true
    object.pointerHandler.args = {index = index, isManual = false}

    object.icon = item.transform:Find("main/icon").gameObject:GetComponent(Image)
    object.typeAct = item.transform:Find("main/type/act").gameObject
    object.typeAct.transform:Find("text").gameObject:GetComponent(Text).text = TI18N("主")
    object.typePasv = item.transform:Find("main/type/pasv").gameObject
    object.typePasv.transform:Find("text").gameObject:GetComponent(Text).text = TI18N("被")
    object.itemName = item.transform:Find("main/name").gameObject:GetComponent(Text)
    object.cdMask = item.transform:Find("main/cd_mask").gameObject:GetComponent(Image)
    object.cdText = item.transform:Find("main/cd_mask/cd_text").gameObject:GetComponent(Text)

    table.insert(self.itemObjects,object)
end

function BattlePveItemView:__BindEvent()
    self:BindEvent(BattlePveItemView.Event.RefreshItem)
    self:BindEvent(BattlePveItemView.Event.RefreshItemCd)
    self:BindEvent(BattlePveItemView.Event.GetSkillBtn)
    self:BindEvent(BattleFacade.Event.CancelOperate)
end

function BattlePveItemView:RefreshItem(index,itemInfo)
    local obj = self.itemObjects[index]
    obj.main:SetActive(true)
    obj.empty:SetActive(false)
    self:SetSprite(obj.icon,AssetPath.GetPveItemLongIcon(itemInfo.itemConf.icon))
    if itemInfo.manualInfo then
        obj.typeAct:SetActive(true)
        obj.typePasv:SetActive(false)
        obj.pointerHandler.args.isManual = true
    else
        obj.typeAct:SetActive(false)
        obj.typePasv:SetActive(true)
        obj.pointerHandler.args.isManual = false
    end
    obj.itemName.text = itemInfo.itemConf.name

    self.itemInfos[index] = itemInfo

    self:LoadUIEffect({
        confId = 10042,
        parent = obj.transform,
        order = self.canvas.sortingOrder + 1,
    },true)
end

function BattlePveItemView:RefreshItemCd(index,itemInfo)
    local obj = self.itemObjects[index]

    if not itemInfo.manualInfo then
        return
    end

    if itemInfo.manualInfo.cdTime > 0 then
        obj.cdMask.gameObject:SetActive(true)
        obj.cdMask.fillAmount = itemInfo.manualInfo.cdTime / itemInfo.manualInfo.cd
        obj.cdText.text = math.floor((itemInfo.manualInfo.cdTime / 1000))
    else
        obj.cdMask.gameObject:SetActive(false)
        obj.cdText.text = 0
    end
end

function BattlePveItemView:DragItemDown(pointerData,args)
    if not args.isManual then
        return
    end

    if self.itemInfos[args.index].manualInfo.cdTime > 0  then
        SystemMessage.Show(TI18N("技能效果冷却中"))
        return
    end

    if pointerData.pointerId < -1 or self.pointerId then
        return
    end

    self.pointerId = pointerData.pointerId
    self.beginPos =  pointerData.position

    local index = args.index
    local eventId = self.itemInfos[index].manualInfo.eventId

    self.moveListenId = TouchManager.Instance:AddListen(TouchDefine.TouchEvent.move,self:ToFunc("ItemDrag"),self.pointerId
        ,{index = index, eventId = eventId, pointerId = self.pointerId})

    self.cancelListenId = TouchManager.Instance:AddListen(TouchDefine.TouchEvent.cancel,self:ToFunc("ItemCancel"),self.pointerId,args)
end

function BattlePveItemView:ItemDrag(touchData,args)
    local info = self.itemInfos[args.index]
    local dis = MathUtils.GetDistance2D(self.beginPos.x,self.beginPos.y,touchData.pos.x,touchData.pos.y)
    if dis >= 50 then
        self:RemoveDragItemListen()
        local roleUid = RunWorld.BattleDataSystem.roleUid
        local entity = RunWorld.EntitySystem:GetRoleCommander(roleUid)
        local skillId = info.manualInfo.skillId
        local skillConf = RunWorld.BattleConfSystem:SkillData_data_skill_base(skillId)

        local relArgs = {}
        relArgs.index = args.index
        relArgs.unitId = entity.entityId
        relArgs.eventId = args.eventId
        relArgs.skillId = skillId
        relArgs.skillLev = info.manualInfo.skillLev
        relArgs.relRangeType = skillConf.rel_range_type
        relArgs.onComplete = self:ToFunc("DragItemComplete")

        mod.BattleFacade:SendEvent(BattleDragRelSkillView.Event.BeginDragSkill,entity,args.pointerId,relArgs)
        mod.BattleFacade:SendEvent(BattleMixedEffectView.Event.PlayRelRangeEffect,relArgs.relRangeType,true,false) -- 第二个bool为是否全场不可释放
    end
end

function BattlePveItemView:ItemCancel(touchData,args)
    self.pointerId = nil
    self:RemoveDragItemListen()
end

function BattlePveItemView:DragItemComplete(flag,transInfo,targets,relArgs)
    self.pointerId = nil
    mod.BattleFacade:SendEvent(BattleMixedEffectView.Event.PlayRelRangeEffect,nil,false)
    if flag then
        RunWorld.BattleInputSystem:AddUseManualItem(RunWorld.BattleDataSystem.roleUid,relArgs.unitId,relArgs.eventId,relArgs.skillId,relArgs.skillLev,transInfo,targets)
        mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.use_pve_skill)
    end
end

function BattlePveItemView:RemoveDragItemListen()
    if self.moveListenId then
        TouchManager.Instance:RemoveListen(self.moveListenId)
        self.moveListenId = nil
    end
    if self.cancelListenId then
        TouchManager.Instance:RemoveListen(self.cancelListenId)
        self.cancelListenId = nil
    end
end

function BattlePveItemView:CancelOperate()
    self.pointerId = nil
    self:RemoveDragItemListen()
end

function BattlePveItemView:GetSkillBtn(args, callback)
    local index = args.index
    local skillId = tonumber(args.skillId) or -1
    if index and index > 0 then
        local info = self.itemInfos[index]
        if info then
            local _skillId = info.manualInfo and info.manualInfo.skillId
            if not _skillId or skillId == _skillId then
                local rect = self.itemObjects[index].pointerHandler:GetComponent(RectTransform)
                callback(rect,rect)
            end
        end
    elseif skillId > 0 then
        for _index, info in pairs(self.itemInfos) do
            if info.manualInfo and info.manualInfo.skillId == skillId then
                local rect = self.itemObjects[_index].pointerHandler:GetComponent(RectTransform)
                callback(rect,rect)
                return
            end
        end
    else
        local rect = self.itemObjects[1].pointerHandler:GetComponent(RectTransform)
        callback(rect,rect)
    end
end