BattleCommanderDragSkillView = BaseClass("BattleCommanderDragSkillView",ExtendView)

BattleCommanderDragSkillView.Event = EventEnum.New(
    "RefreshView",
    "GetRageSkillObj"
)

function BattleCommanderDragSkillView:__Init()
    self.canShowDetails = false
    self.beginPos = nil

    self.dragSkillObjects = {}
    self.skillInfos = {}

    self.dragSkillTips = nil
end

function BattleCommanderDragSkillView:__Delete()
    if self.dragSkillTips then
        self.dragSkillTips:Destroy()
    end
end

function BattleCommanderDragSkillView:__Hide()
    for i = 1, 3 do
        local skillObj = self.dragSkillObjects[i]
        if skillObj.cdAnim then
            skillObj.cdAnim:Destroy()
            skillObj.cdAnim = nil
        end
    end
    self.skillInfos = {}

    if self.enoughRage then
        self.enoughRage:Delete()
        self.enoughRage = nil
    end

    if self.dragSkillTips then
        self.dragSkillTips:Destroy()
    end
end

function BattleCommanderDragSkillView:__CacheObject()
    if next(self.dragSkillObjects) == nil then
        for i=1,3 do self:GetDragSkillObjects(i) end
    end
    self:SetDragSkillObjects()

    self.tipsParent = self:Find("main/tips")
end

function BattleCommanderDragSkillView:__BindEvent()
    self:BindEvent(BattleCommanderDragSkillView.Event.RefreshView)
    self:BindEvent(BattleCommanderDragSkillView.Event.GetRageSkillObj)
    self:BindEvent(BattleFacade.Event.CancelOperate)
end

function BattleCommanderDragSkillView:GetDragSkillObjects(index)
    local object = {}
    local item = self:Find("main/operate/drag_skill_con/drag_skill_"..tostring(index)).gameObject
    object.gameObject = item
    object.transform = item.transform

    object.eventTrigger = item.gameObject:AddComponent(EventSystems.EventTrigger)

    -- normal
    object.normalNode = item.transform:Find("normal").gameObject
    object.icon = item.transform:Find("normal/icon").gameObject:GetComponent(Image)
    -- object.relNum = item.transform:Find("normal/rel_num").gameObject:GetComponent(TextMesh)  -- 左上角剩余次数 无限制不显示
    object.consume = item.transform:Find("normal/consume").gameObject:GetComponent(Text) -- 消耗
    object.consumeMask = item.transform:Find("normal/consume_mask").gameObject:GetComponent(Image) -- 消耗遮罩
    -- object.name = item.transform:Find("normal/skill_name").gameObject:GetComponent(TextMesh) -- 技能名
    -- lock
    object.lockNode = item.transform:Find("lock").gameObject
    -- cd
    object.cdNode = item.transform:Find("cd").gameObject
    object.cdMask = item.transform:Find("cd/mask").gameObject:GetComponent(Image)
    object.cdText = item.transform:Find("cd/text").gameObject:GetComponent(Text)
    object.cdClockPivot = item.transform:Find("cd/clock/pivot")  -- 秒针 用于旋转动画

    table.insert(self.dragSkillObjects,object)
end

function BattleCommanderDragSkillView:SetDragSkillObjects()
    local roleUid = RunWorld.BattleDataSystem.roleUid
    self.skillInfos = RunWorld.BattleCommanderSystem:GetCommanderInfo(roleUid).dragSkills
    for i, v in ipairs(self.skillInfos) do
        local object = self.dragSkillObjects[i]

        if v.lock then
            object.normalNode:SetActive(false)
            object.lockNode:SetActive(true)
        else
            object.eventTrigger:SetEvent(EventSystems.EventTriggerType.PointerDown,self:ToFunc("DragSkillDown"),{index = i,roleUid = roleUid})
            object.normalNode:SetActive(true)
            object.lockNode:SetActive(false)
            local icon = RunWorld.BattleConfSystem:SkillData_data_skill_base(v.skillId).icon
            local path = AssetPath.GetBattleCommanderSkillIcon(icon)  -- 设置技能图标
            self:SetSprite(object.icon,path)

            -- if v.maxRelNum > 0 then
            --     object.relNum.text = tostring(v.maxRelNum)
            -- else
            --     object.relNum.text = ""
            -- end
            object.consumeMask.fillAmount = 1
            object.consume.text = UIUtils.GetColorText("0/","#323C54")..tostring(v.consume)
            -- object.name.text = tostring(v.name)
        end
    end
end

function BattleCommanderDragSkillView:GetRageSkillObj(skillId,outArgs)
    for i, v in ipairs(self.skillInfos) do
        if v.skillId == skillId then
            outArgs.targetObj = self.dragSkillObjects[i].gameObject
            outArgs.consumeObj = self.dragSkillObjects[i].consume.gameObject
            break
        end
    end
end

function BattleCommanderDragSkillView:DragSkillDown(pointerData,args)
    if pointerData.pointerId < -1 or self.pointerId then
        return
    end

    -- local relArgs = {}
    -- relArgs.index = args.index
    -- relArgs.skillId = self.skillInfos[args.index].skillId
    -- if not self:DragSkillCanRel(relArgs) then
    --     return
    -- end

    self.pointerId = pointerData.pointerId
    self.beginPos =  pointerData.position

    self.canShowDetails = true

    local roleUid = args.roleUid
    self.moveListenId = TouchManager.Instance:AddListen(TouchDefine.TouchEvent.move,self:ToFunc("DragSkillDrag"),self.pointerId
        ,{pointerId = self.pointerId,roleUid = roleUid,index = args.index})

    self.cancelListenId = TouchManager.Instance:AddListen(TouchDefine.TouchEvent.cancel,self:ToFunc("DragSkillCancel"),self.pointerId,args)
end

function BattleCommanderDragSkillView:DragSkillDrag(touchData,args)
    local dis = MathUtils.GetDistance2D(self.beginPos.x,self.beginPos.y,touchData.pos.x,touchData.pos.y)
    if dis >= 50 then
        self.canShowDetails = false
        self:RemoveDragSkillListen()

        local entity = RunWorld.EntitySystem:GetRoleCommander(args.roleUid)
        local relArgs = {}
        relArgs.index = args.index
        relArgs.unitId = entity.entityId
        relArgs.skillId = self.skillInfos[args.index].skillId
        relArgs.skillLev = self.skillInfos[args.index].skillLev
        relArgs.relRangeType = self.skillInfos[args.index].relRangeType
        relArgs.onComplete = self:ToFunc("DragRelComplete")

        mod.BattleFacade:SendEvent(BattleDragRelSkillView.Event.BeginDragSkill,entity,args.pointerId,relArgs)
        mod.BattleFacade:SendEvent(BattleMixedEffectView.Event.PlayRelRangeEffect,relArgs.relRangeType,true,false) -- 第二个bool为是否全场不可释放
    end
end


function BattleCommanderDragSkillView:DragSkillCancel(touchData,args)
    self.pointerId = nil
    self:RemoveDragSkillListen()

    local conf = nil

    if self.canShowDetails then
        self:ShowDragSkillTips(args.index)
    end
end

function BattleCommanderDragSkillView:DragRelComplete(flag,transInfo,targets,relArgs)
    self.pointerId = nil
    mod.BattleFacade:SendEvent(BattleMixedEffectView.Event.PlayRelRangeEffect,nil,false)
    if flag then
        -- local skillObj = self.dragSkillObjects[relArgs.index]
        if not self:DragSkillCanRel(relArgs) then
            return
        end

        --发送协议了
        RunWorld.BattleInputSystem:AddUseMagicCard(RunWorld.BattleDataSystem.roleUid,relArgs.unitId,relArgs.skillId,relArgs.skillLev,transInfo,targets)
        mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.use_rage_skill)
    end
    --Log("释放魔法卡",tostring(flag),transInfo.posX,transInfo.posZ,relArgs.unitId,relArgs.skillId,relArgs.skillLev)
end

function BattleCommanderDragSkillView:RefreshView()
    self.curRage = RunWorld.BattleCommanderSystem:GetCurRage(RunWorld.BattleDataSystem.roleUid)
    for i ,skillInfo in ipairs(self.skillInfos) do
        local skillObj = self.dragSkillObjects[i]
        if skillInfo.maxRelNum > 0 then
            local restRelNum = skillInfo.maxRelNum - skillInfo.relNum
            local color = restRelNum > 0 and "#FFFFFF" or "#F45959"
            skillObj.relNum.text = UIUtils.GetColorText(tostring(restRelNum),color)
        end

        local color = nil
        if self.curRage >= skillInfo.consume then
            self:EnoughRageEffectActive(i,true)
            color = "#E29C45"
        else
            self:EnoughRageEffectActive(i,false)
            color = "#323C54"
        end

        local progress = 0
        if skillInfo.consume > 0 then
            progress =  1 - self.curRage/skillInfo.consume
        end
        skillObj.consumeMask.fillAmount = progress
        skillObj.consume.text = UIUtils.GetColorText(tostring(self.curRage.."/"),color)..tostring(skillInfo.consume)

        local entity = RunWorld.EntitySystem:GetRoleCommander(RunWorld.BattleDataSystem.roleUid)
        local skill = entity.SkillComponent:GetSkill(skillInfo.skillId)
        if not skill:IsCd() then
            if not skillObj.cdAnim then
                skillObj.cdNode.gameObject:SetActive(true)
                local cd = math.floor(skill.cdTime/1000)
                skillObj.cdText.text = tostring(cd)
                skillObj.cdAnim = ToIntValueAnim.New(cd,0,cd,function (val)
                    skillObj.cdText.text = val
                end)
                skillObj.cdAnim:SetComplete(function ()
                    skillObj.cdNode.gameObject:SetActive(false)
                    skillObj.cdAnim:Destroy()
                    skillObj.cdAnim = nil
                end)
                skillObj.cdAnim:Play()
            end
        end
    end
end

function BattleCommanderDragSkillView:EnoughRageEffectActive(index,flag)
    if DEBUG_ACTIVE_EFFECT == false then
        return
    end

    local object = self.dragSkillObjects[index]
    if not self.enoughRage then
        local pos = object.gameObject.transform.position
        local effect = RunWorld.BattleAssetsSystem:PlaySceneEffect(100014,pos.x * 1000, pos.y * 1000, pos.z * 1000,EffectDefine.EffectType.action)
        self.enoughRage = effect
        self.enoughRage:Stop()
    end
    if flag then
        self.enoughRage:Play()
    else
        self.enoughRage:Stop()
    end
end

function BattleCommanderDragSkillView:RemoveDragSkillListen()
    if self.moveListenId then
        TouchManager.Instance:RemoveListen(self.moveListenId)
        self.moveListenId = nil
    end
    if self.cancelListenId then
        TouchManager.Instance:RemoveListen(self.cancelListenId)
        self.cancelListenId = nil
    end
end

function BattleCommanderDragSkillView:CancelOperate()
    self.pointerId = nil
    self:RemoveDragSkillListen()
    self.canShowDetails = true
end

function BattleCommanderDragSkillView:DragSkillCanRel(relArgs)
    local entity = RunWorld.EntitySystem:GetRoleCommander(RunWorld.BattleDataSystem.roleUid)
    local skill = entity.SkillComponent:GetSkill(relArgs.skillId)
    local skillInfo = self.skillInfos[relArgs.index]
    if not skill:IsCd() then
        SystemMessage.Show(TI18N("冷却中"))
        self:CancelOperate()
        return false
    end

    if skill:MaxRelNum() then
        SystemMessage.Show(TI18N("无剩余释放次数"))
        self:CancelOperate()
        return false
    end

    if self.curRage < skillInfo.consume then
        SystemMessage.Show(TI18N("怒气不足，怒气随时间增长或统帅受击时增长"))
        self:CancelOperate()
        return false
    end

    return true
end

function BattleCommanderDragSkillView:ShowDragSkillTips(index)
    if not self.dragSkillTips then
        self.dragSkillTips = BattleDragSkillTips.New()
        self.dragSkillTips:SetParent(self.tipsParent)
    end
    local data = {}
    data.skillId = self.skillInfos[index].skillId
    data.skillLev = self.skillInfos[index].skillLev
    self.dragSkillTips:SetData(data)
    self.dragSkillTips:Show()
end