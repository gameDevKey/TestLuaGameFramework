BattleDragRelSkillView = BaseClass("BattleDragRelSkillView",ExtendView)

BattleDragRelSkillView.Event = EventEnum.New(
    "BeginDragSkill",
    "LimitRelRange"
)

function BattleDragRelSkillView:__Init()
    self.moveListenId = nil
    self.cancelListenId = nil
    self.entity = nil
    self.skillBaseConf = nil
    self.skillLevConf = nil
    -- self.entityId = nil
    -- self.skill = nil
    -- self.grid = nil
    -- self.selectGrid = nil
    -- self.relDir = nil
    self.atkEntitys = {}
    -- self.canRel = nil

    self.selectPos = FPVector3(0,0,0)
    -- self.selectDir = VInt3(0,0,0)


    self.selectRange = nil

    self.relArgs = nil

    self.canRel = nil

    self.refreshTimer = nil

    self.limitRelRange = nil
end

function BattleDragRelSkillView:__Create()

end

function BattleDragRelSkillView:__CacheObject()
    self.dragStateNode = self:Find("main/operate/drag_rel_node").gameObject
    self.dragStateCollider = self:Find("main/operate/drag_rel_node",BoxCollider2D)
    self.canRelNode =  self:Find("main/operate/drag_rel_node/can_rel").gameObject
    self.cancelRelNode =  self:Find("main/operate/drag_rel_node/cancel_rel").gameObject
end

function BattleDragRelSkillView:__BindListener()
    
end

function BattleDragRelSkillView:__BindEvent()
    self:BindEvent(BattleDragRelSkillView.Event.BeginDragSkill)
    self:BindEvent(BattleFacade.Event.CancelOperate)
    self:BindEvent(BattleDragRelSkillView.Event.LimitRelRange)
end

function BattleDragRelSkillView:__Hide()
    self:CancelState()
    self.limitRelRange = nil
end

function BattleDragRelSkillView:__Show()

end

function BattleDragRelSkillView:LimitRelRange(limitRelRange)
    self.limitRelRange = limitRelRange
end

function BattleDragRelSkillView:BeginDragSkill(entity,pointerId,relArgs)
    self.entity = entity
    if not self.entity then
        self.entity = nil
        self:RelComplete(false,nil,relArgs)
        return
    end

    self.relArgs = relArgs

    self.skillBaseConf = Config.SkillData.data_skill_base[self.relArgs.skillId]
    self.skillLevConf = Config.SkillData.data_skill_lev[self.relArgs.skillId .. "_" .. self.relArgs.skillLev]

    local touchPos = TouchManager.Instance:GetPos(pointerId)
    local flag,hitPos = BattleUtils.CheckTerrainHit(touchPos)
    if not flag then
        self.entity = nil
        self:RelComplete(false,nil,relArgs)
    end

    self.dragStateNode:SetActive(true)

    self.selectPos:Set(hitPos.x,0,hitPos.z)

    if self.skillLevConf.atk_range.lockX then
        self.selectPos.x = self.skillLevConf.atk_range.lockX
    end

    if self.skillLevConf.atk_range.lockZ then
        self.selectPos.z = self.skillLevConf.atk_range.lockZ
    end

    if self.skillLevConf.target_num >= 0 then
        if self.skillLevConf.atk_range.type > 0 then
            self.selectRange = RangeBase.Create(self.skillLevConf.atk_range.type)
            self.selectRange:SetParent(BattleDefine.nodeObjs["mixed"])
            self.selectRange:SetRange(self.skillLevConf.atk_range)
            self.selectRange:SetOffsetY(0.05)
            self.selectRange:CreateRange()
        end
    end

    self:RefreshSelectRange()

    self:DragSkill(nil,touchPos)
    self:RefreshSelectEntity()
    
    --self:UpdateRelState(touchPos)

    self.moveListenId = TouchManager.Instance:AddListen(TouchDefine.TouchEvent.move,self:ToFunc("DragSkill"),pointerId)
    self.cancelListenId = TouchManager.Instance:AddListen(TouchDefine.TouchEvent.cancel,self:ToFunc("CancelDragSkill"),pointerId)
    self.refreshTimer = TimerManager.Instance:AddTimer(0,0,self:ToFunc("RefreshTimer"))
end

function BattleDragRelSkillView:RelComplete(flag,targets,args)
    if self.relArgs.onComplete then
        self.relArgs.onComplete(flag,{posX = self.selectPos.x,posZ = self.selectPos.z},targets or {},args)
    end
end

function BattleDragRelSkillView:DragSkill(touchData,pos)
    local touchPos = pos or touchData.pos 
    local flag,hitPos = BattleUtils.CheckTerrainHit(touchPos)
    if not flag then
        return
    end

    local x,z = hitPos.x,hitPos.z
    if self.skillLevConf.atk_range.lockX then
        x = self.skillLevConf.atk_range.lockX * 0.001
    end

    if self.skillLevConf.atk_range.lockZ then
        z = self.skillLevConf.atk_range.lockZ * 0.001
    end

    FPMath.XYZToFPVector3(x,0,z,self.selectPos)
    

    local flag = true
    if self.skillLevConf.target_num >= 0 then
        local selfCamp = self.entity.CampComponent:GetCamp()

        local checkCamp = self.entity.CampComponent:GetCamp()
        if self.relArgs.relRangeType == SkillDefine.RelRangeType.enemy then
            if checkCamp == BattleDefine.Camp.attack then
                checkCamp = BattleDefine.Camp.defence
            elseif checkCamp == BattleDefine.Camp.defence then
                checkCamp = BattleDefine.Camp.attack
            end
        end

        local selectCamp = RunWorld.BattleTerrainSystem:PosToCampByZ(self.selectPos.z,checkCamp)

        if self.relArgs.relRangeType == SkillDefine.RelRangeType.self and selfCamp ~= selectCamp then
            flag = false
        elseif self.relArgs.relRangeType == SkillDefine.RelRangeType.enemy and selfCamp == selectCamp then
            flag = false
        end
    end

    self:UpdateRelState(touchPos,flag)
    self:RefreshSelectRange()
end

function BattleDragRelSkillView:UpdateRelState(pos,posFlag)
    local flag = posFlag
    if flag then
        local vec1 = BaseUtils.ScreenToWorldPoint(UIDefine.uiCamera,pos)
        flag = not self.dragStateCollider:OverlapPoint(Vector2(vec1.x,vec1.y))
    end

    if self.canRel ~= nil then
        if flag and self.canRel then
            return
        elseif not flag and not self.canRel then
            return
        end
    end

    self.canRel = flag
    self.canRelNode:SetActive(flag)
    self.cancelRelNode:SetActive(not flag)

    self:SetRangeColor(flag)
end

function BattleDragRelSkillView:CancelDragSkill(touchData)
    local isRel = false
    local targets = nil

    if self.canRel then
        if self.skillLevConf.target_num == -1 then
            isRel = true
        else
            local searchParams = RunWorld.BattleCastSkillSystem.skillSearchParams
            searchParams.entity = self.entity
            searchParams.range = self.skillLevConf.atk_range
            searchParams.transInfo = {}
            searchParams.transInfo.posX = self.selectPos.x
            searchParams.transInfo.posZ = self.selectPos.z
            searchParams.targetNum = self.skillLevConf.target_num
            searchParams.priorityType1 = BattleDefine.SearchPriority.min_to_self_dis

            local hitEntitys,_ = RunWorld.BattleCastSkillSystem:RenderSkillConfSearchEntity(self.skillBaseConf,self.skillLevConf,searchParams)
            targets = hitEntitys

            isRel = self.skillBaseConf.no_target_rel == 1 or #targets > 0
        end
    end

    if isRel and self.limitRelRange and self.limitRelRange.range.radius > 0 then
        isRel = FPCollision2D.PointInCircle(FPVector2(self.selectPos.x,self.selectPos.z)
            ,FPVector2(self.limitRelRange.posX,self.limitRelRange.posZ),self.limitRelRange.range.radius)
    end

    self:RelComplete(isRel,targets,self.relArgs)
    self:CancelState()
end

function BattleDragRelSkillView:RemoveSelectRange()
    if self.selectRange then
        self.selectRange:Delete()
        self.selectRange = nil
    end
end

function BattleDragRelSkillView:RemoveRefreshTimer()
    if self.refreshTimer then
        TimerManager.Instance:RemoveTimer(self.refreshTimer)
        self.refreshTimer = nil
    end
end

function BattleDragRelSkillView:CancelState()
    self:RemoveSelectRange()
    self:RemoveRefreshTimer()

    if self.moveListenId then
        TouchManager.Instance:RemoveListen(self.moveListenId)
        self.moveListenId = nil
    end

    if self.cancelListenId then
        TouchManager.Instance:RemoveListen(self.cancelListenId)
        self.cancelListenId = nil
    end

    for targetUid,_ in pairs(self.atkEntitys) do
        local targetEntity = RunWorld.EntitySystem:GetEntity(targetUid)
        if targetEntity then
            targetEntity.clientEntity.TposeComponent:AddColor(false,nil)
        end
    end
    self.atkEntitys = {}

    self.dragStateNode:SetActive(false)

    self.entity = nil
    self.relArgs = nil
    self.skillBaseConf = nil
    self.skillLevConf = nil
    
    self.canRel = nil
end

function BattleDragRelSkillView:RefreshSelectRange()
    if self.selectRange then 
        self.selectRange:SetTransform(self.selectPos.vec3,nil) 
    end
end

function BattleDragRelSkillView:RefreshTimer()
    self:RefreshSelectEntity()
end

function BattleDragRelSkillView:RefreshSelectEntity()
    if not self.skillLevConf.target_num == -1 then 
        return
    end

    local searchParams = RunWorld.BattleCastSkillSystem.skillSearchParams
    searchParams.entity = self.entity
    searchParams.range = self.skillLevConf.atk_range
    searchParams.transInfo = {}
    searchParams.transInfo.posX = self.selectPos.x
    searchParams.transInfo.posZ = self.selectPos.z
    searchParams.targetNum = self.skillLevConf.target_num
    searchParams.priorityType1 = BattleDefine.SearchPriority.min_to_self_dis

    local entitys,_ = RunWorld.BattleCastSkillSystem:RenderSkillConfSearchEntity(self.skillBaseConf,self.skillLevConf,searchParams)

    local atkEntitys = {}
    for i,targetUid in ipairs(entitys) do
        local targetEntity = RunWorld.EntitySystem:GetEntity(targetUid)
        if targetEntity then
            atkEntitys[targetUid] = true
            if not self.atkEntitys[targetUid] then
                targetEntity.clientEntity.TposeComponent:AddColor(true,"555555ff")
            end
        end
    end

    local lastTargetNum = 0
    for targetUid,_ in pairs( self.atkEntitys ) do
        lastTargetNum = lastTargetNum + 1
        local targetEntity = RunWorld.EntitySystem:GetEntity(targetUid)
        if targetEntity and not atkEntitys[targetUid] then
            targetEntity.clientEntity.TposeComponent:AddColor(false,nil)
        end
    end

    self.atkEntitys = atkEntitys
    
    if self.canRel and self.skillBaseConf.no_target_rel == 0 and #entitys <= 0 then
        self:SetRangeColor(false)
    elseif self.canRel and self.skillBaseConf.no_target_rel == 0 and lastTargetNum == 0 and #entitys > 0 then
        self:SetRangeColor(true)
    end
end

function BattleDragRelSkillView:SetRangeColor(flag)
    if not self.selectRange then
        return
    end

    if flag then
        self.selectRange:ResetColor()
    else
        self.selectRange:SetColor("ff5151ff",1.0)
    end
end

function BattleDragRelSkillView:CancelOperate()
    if self.entity then
        self:RelComplete(false,nil,self.relArgs)
    end
    self:CancelState()
end