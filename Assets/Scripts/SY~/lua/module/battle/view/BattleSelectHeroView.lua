BattleSelectHeroView = BaseClass("BattleSelectHeroView",ExtendView)

BattleSelectHeroView.Event = EventEnum.New(
    "RefreshSelectHero",
    "ActiveSelectHero",
    "GetRandomUnitObj",
    "EnableTips",
    "EnableSelect",
    "ActiveUnitDetails"
)

function BattleSelectHeroView:__Init()
    self.OnSelectHeroDown = self:ToFunc("SelectHeroDown")
    self.canSelect = true

    self.qualityToImg = {
        qualityToIconBg = {
            [GDefine.Quality.green]  = UITex("battle/63"),
            [GDefine.Quality.bule]   = UITex("battle/64"),
            [GDefine.Quality.purple] = UITex("battle/65"),
            [GDefine.Quality.orange] = UITex("battle/66"),
        },
        qualityToFrame = {
            [GDefine.Quality.green]  = UITex("battle/67"),
            [GDefine.Quality.bule]   = UITex("battle/68"),
            [GDefine.Quality.purple] = UITex("battle/69"),
            [GDefine.Quality.orange] = UITex("battle/70"),
        },
        qualityToUnitNumBg = {
            [GDefine.Quality.green]  = UITex("battle/83"),
            [GDefine.Quality.bule]   = UITex("battle/84"),
            [GDefine.Quality.purple] = UITex("battle/85"),
            [GDefine.Quality.orange] = UITex("battle/86"),
        }
    }

    self.beginPos = nil

    self.waitSelectHeros = nil 

    self.enableTips = true
    self.enableSelect = true

    self.selectUnitTipsTimer = nil
    self.activeSelectUnitTips = false
end

function BattleSelectHeroView:__Delete()
end

function BattleSelectHeroView:__CacheObject()
    self.selectHeroObjects = {}
    for i=1,3 do self:GetSelectHeroObjects(i) end

    self.selectHeroNode = self:Find("main/operate/select_hero_node").gameObject

    self.selectUnitTips = self:Find("main/tips/select_hero_tips").gameObject

    self.selectHeroCanvasGroup = self:Find("main/operate/select_hero_node",CanvasGroup)
end

function BattleSelectHeroView:GetSelectHeroObjects(index)
    local object = {}
    local item = self:Find("main/operate/select_hero_node/"..tostring(index)).gameObject
    object.gameObject = item
    object.transform = item.transform

    object.pointerHandler = item:GetComponent(PointerHandler) or item:AddComponent(PointerHandler)
    object.pointerHandler:SetOwner(self,"OnSelectHeroDown","","")
    object.pointerHandler.isPointerDown = true

    object.collider2d = item:GetComponent(BoxCollider2D)
    object.pointerHandler.args = {unitId = 0,collider = object.collider2d}

    object.heroIconBg = item:GetComponent(Image)
    object.heroIcon = item.transform:Find("icon").gameObject:GetComponent(Image)
    object.heroFrame = item.transform:Find("frame").gameObject:GetComponent(Image)
    object.jobType = item.transform:Find("job_type").gameObject:GetComponent(Image)
    object.feature = item.transform:Find("feature").gameObject:GetComponent(Text)
    object.unitNumBg = item.transform:Find("unit_num").gameObject:GetComponent(Image)
    object.unitNum = item.transform:Find("unit_num/text").gameObject:GetComponent(Text)
    object.walkType = item.transform:Find("walk_type").gameObject:GetComponent(Image)
    object.targetNumType = item.transform:Find("target_num_type").gameObject:GetComponent(Image)
    table.insert(self.selectHeroObjects,object)
end

function BattleSelectHeroView:__BindEvent()
    self:BindEvent(BattleFacade.Event.InitComplete)
    self:BindEvent(BattleSelectHeroView.Event.RefreshSelectHero)
    self:BindEvent(BattleSelectHeroView.Event.ActiveSelectHero)
    self:BindEvent(BattleFacade.Event.CancelOperate)
    self:BindEvent(BattleSelectHeroView.Event.GetRandomUnitObj)
    self:BindEvent(BattleSelectHeroView.Event.EnableTips)
    self:BindEvent(BattleSelectHeroView.Event.EnableSelect)
    self:BindEvent(BattleSelectHeroView.Event.ActiveUnitDetails)
end

function BattleSelectHeroView:__Create()
    --self:AddAnimEffectListener("select_unit",self:ToFunc("AESelectUnitEffect"))
end

function BattleSelectHeroView:__Show()

end

function BattleSelectHeroView:AESelectUnitEffect(animName,effectInfo)
    local setting = {}
    setting.assetId = effectInfo.effectId
    setting.parent = self:Find(effectInfo.nodePath) or self.transform
    setting.delayTime = effectInfo.beginTime
    setting.lastTime = effectInfo.lastTime
    setting.onComplete = self:ToFunc("AESelectUnitEffectComplete")
    setting.order = 10
    
    local effect = UIEffect.New()
    effect:Init(setting)
    effect:Play()

    self:AddEffect(effect)
end

function BattleSelectHeroView:AESelectUnitEffectComplete(uid)
    --self:DeleteEffectByUid(uid)
end

function BattleSelectHeroView:InitComplete()
    do
        return
    end
    local targetTrans = BattleDefine.nodeObjs["mixed"]:Find("operate/next_group_info")
    local worldPos = targetTrans.position
    local targetPos = BaseUtils.WorldToUIPoint(BattleDefine.nodeObjs["main_camera"],worldPos)
    local srcPos = self.selectHeroNode.transform.anchoredPosition

    self.selectHeroNode.transform:SetAnchoredPosition(srcPos.x,targetPos.y + 20)

    local srcPos = self.selectUnitTips.transform.anchoredPosition
    self.selectUnitTips.transform:SetAnchoredPosition(srcPos.x,targetPos.y + 5)

    --TODO 无须场景化定位  next_group_info Object更改
end

function BattleSelectHeroView:__Hide()
    self:ActiveSelectHero(false)
    self:HideEffects()
    if self.battleUnitDetailsPanel then
        self.battleUnitDetailsPanel:Destroy()
    end
    self.battleUnitDetailsPanel = nil
    if self.battleHeroDetailsPanel then
        self.battleHeroDetailsPanel:Destroy()
    end
    self.battleHeroDetailsPanel = nil
    self.enableTips = true
    self.enableSelect = true

    self:RemoveSelectUnitTipsTimer()
    self:ActiveSelectUnitTips(false)
end


function BattleSelectHeroView:ActiveSelectHero(flag)
    self.selectHeroNode:SetActive(flag)
    if not flag then
        self.waitSelectHeros = nil
        self:HideEffects()
    end
end

function BattleSelectHeroView:HideEffects()
    for i,v in ipairs(self.selectHeroObjects) do
        if v.existHeroEffect and v.existHeroEffect:IsActive() then
            v.existHeroEffect:Stop()
        end
        if v.coreUnitEffect and v.coreUnitEffect:IsActive() then
            v.coreUnitEffect:Stop()
        end
    end
end

function BattleSelectHeroView:RefreshSelectHero(heros)
    -- mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.random_unit)

    self:ActiveSelectHero(true)
    self:PlayAnim("select_unit")
    self.selectHeroCanvasGroup.alpha = 1.0

    self.waitSelectHeros = heros

    local roleUid = RunWorld.BattleDataSystem.roleUid
    for i,v in ipairs(heros) do
        local object = self.selectHeroObjects[i]
        local conf = Config.UnitData.data_unit_info[v]
        local starConf = Config.UnitData.data_unit_star_info[tostring(v) .. "_1"]
        local headFile = AssetPath.GetUnitIconBattleSelect(conf.head)

        local quality = conf.quality
        self:SetSprite(object.heroIconBg,self.qualityToImg.qualityToIconBg[quality])
        self:SetSprite(object.heroIcon,headFile,true)
        self:SetSprite(object.heroFrame,self.qualityToImg.qualityToFrame[quality])
        self:SetSprite(object.unitNumBg,self.qualityToImg.qualityToUnitNumBg[quality])
        self:SetSprite(object.targetNumType,BattleDefine.TargetNumTypeIcon[starConf.target_num_type][conf.job])

        if conf.walk_type and conf.walk_type > 0 then
            object.unitNum.text = conf.unit_num
            local icon = conf.walk_type == 1 and UITex("battle/81") or UITex("battle/82")
            self:SetSprite(object.walkType,icon,true)
            object.walkType.gameObject:SetActive(true)
            object.unitNumBg.gameObject:SetActive(true)
            object.targetNumType.gameObject:SetActive(true)
        else
            object.unitNum.text = ""
            object.walkType.gameObject:SetActive(false)
            object.unitNumBg.gameObject:SetActive(false)
            object.targetNumType.gameObject:SetActive(false)
        end

        self:SetSprite(object.jobType,AssetPath.JobToIcon[conf.job])

        local feature = conf.feature
        if StringUtils.IsEmpty(feature) then
            feature = conf.name --TODO 魔法卡使用“魔法卡类型”字段
        end
        object.feature.text = feature

        object.pointerHandler.args.unitId = v

        local flag = RunWorld.BattleDataSystem:HasUnit(roleUid,v)
        self:ActiveExistHeroEffect(i,flag)

    end
    self:CheckSelectHeroTips()
end

function BattleSelectHeroView:GetRandomUnitObj(unitId,outArgs)
    if not self.waitSelectHeros then
        return
    end

    for i,v in ipairs(self.waitSelectHeros) do
        if v == unitId then
            local object = self.selectHeroObjects[i]
            outArgs.targetObj = object.gameObject
            return
        end
    end
end

function BattleSelectHeroView:ActiveExistHeroEffect(index,flag)
    local object = self.selectHeroObjects[index]
    if not flag and not object.existHeroEffect then
        return
    elseif flag and object.existHeroEffect and object.existHeroEffect:IsActive() then
        return
    end

    if flag and not object.existHeroEffect then
        local setting = {}
        setting.confId = 10001
        setting.parent = object.transform
        setting.order = 20

		local effect = UIEffect.New()
        effect:Init(setting)
        object.existHeroEffect = effect
    end

    if flag then
        object.existHeroEffect:Play()
    else
        object.existHeroEffect:Stop()
    end
end

function BattleSelectHeroView:ActiveCoreUnitEffect(index,flag)
    -- 屏蔽特效
    -- local object = self.selectHeroObjects[index]
    -- if not flag and not object.coreUnitEffect then
    --     return
    -- elseif flag and object.coreUnitEffect and object.coreUnitEffect:IsActive() then
    --     return
    -- end

    -- if flag and not object.coreUnitEffect then
    --     local setting = {}
    --     setting.confId = 5001010
    --     setting.parent = object.raceType.transform
    --     setting.order = 10

	-- 	local effect = UIEffect.New()
    --     effect:Init(setting)
    --     object.coreUnitEffect = effect
    -- end

    -- if flag then
    --     object.coreUnitEffect:Play()
    -- else
    --     object.coreUnitEffect:Stop()
    -- end
end

function BattleSelectHeroView:EnableTips(flag)
    self.enableTips = flag
end

function BattleSelectHeroView:EnableSelect(flag)
    self.enableSelect = flag
end

function BattleSelectHeroView:SelectHeroDown(pointerData,args)
    if pointerData.pointerId < -1 or self.pointerId then
        return
    end

    self.pointerId = pointerData.pointerId

    self.beginPos =  pointerData.position

    self.canSelect = true
    local unitId = args.unitId

    local roleUid = RunWorld.BattleDataSystem.roleUid

    local heroGridInfo = RunWorld.BattleDataSystem:GetBaseUnitData(roleUid,unitId)
    if heroGridInfo == nil then
        assert(false,string.format("尝试获取没有上阵的单位数据[roleUid:%s][unitId:%s]",roleUid,unitId))
    end
    heroGridInfo.star = RunWorld.BattleDataSystem:GetHeroStarByUnitId(roleUid,unitId)

    if self.enableTips then
        self.timer = TimerManager.Instance:AddTimer(1,1, function()
            mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.open_unit_tips,unitId)
            self.pointerId = nil
            self:RemoveSlotListen()
            self:ActiveUnitDetails(true,heroGridInfo)
            self.canSelect = false
        end)
    end

    self.slotMoveListenId = TouchManager.Instance:AddListen(TouchDefine.TouchEvent.move,self:ToFunc("SelectHeroDrag"),self.pointerId
        ,{roleUid = roleUid,unitId = unitId,pointerId = self.pointerId})
    
    self.slotCancelListenId = TouchManager.Instance:AddListen(TouchDefine.TouchEvent.cancel,self:ToFunc("SelectHeroCancel"),self.pointerId,args)
end

function BattleSelectHeroView:SelectHeroDrag(touchData,args)
    self:RemoveTimer()

    local conf = Config.UnitData.data_unit_info[args.unitId]
    --conf.type = BattleDefine.UnitType.magic_card
    if conf.type == BattleDefine.UnitType.magic_card then
        local dis = MathUtils.GetDistance2D(self.beginPos.x,self.beginPos.y,touchData.pos.x,touchData.pos.y)
        self.selectHeroCanvasGroup.alpha = 1 - (dis / 50)
        if dis >= 50 then
            self.selectHeroNode:SetActive(false)
            self:RemoveSlotListen()

            local entity = RunWorld.EntitySystem:GetMagicCardEntity(args.roleUid,args.unitId)
            local skillId = entity.ObjectDataComponent.objectData.skill_list[1].skill_id
            local skillLev = entity.ObjectDataComponent.objectData.skill_list[1].skill_level

            local relArgs = {}
            relArgs.roleUid = args.roleUid
            relArgs.unitId = args.unitId
            relArgs.skillId = skillId
            relArgs.skillLev = skillLev
            relArgs.relRangeType = conf.rel_range_type
            relArgs.onComplete = self:ToFunc("DragRelComplete")

            local entity = RunWorld.EntitySystem:GetMagicCardEntity(args.roleUid,relArgs.unitId)
            mod.BattleFacade:SendEvent(BattleDragRelSkillView.Event.BeginDragSkill,entity,args.pointerId,relArgs)
        end
    end
end

function BattleSelectHeroView:SelectHeroCancel(touchData,args)
    self.pointerId = nil
    self:RemoveSlotListen()
    self:RemoveTimer()

    if not self.enableSelect then
        return
    end

    local conf = Config.UnitData.data_unit_info[args.unitId]

    local vec1 = BaseUtils.ScreenToWorldPoint(UIDefine.uiCamera,touchData.pos)
    local vec2 = Vector2(vec1.x,vec1.y)
    local flag = args.collider:OverlapPoint(vec2)

    if  self.canSelect and flag and conf.type ~= BattleDefine.UnitType.magic_card then
        self:SelectHero(args.unitId)
    end
end

function BattleSelectHeroView:CancelOperate()
    self.pointerId = nil
    self:RemoveSlotListen()
    self:RemoveTimer()
end

function BattleSelectHeroView:DragRelComplete(flag,transInfo,targets,relArgs)
    self.pointerId = nil
    if flag then
        --发送协议了
        RunWorld.BattleInputSystem:AddUseMagicCard(RunWorld.BattleDataSystem.roleUid,relArgs.unitId,relArgs.skillId,relArgs.skillLev,transInfo,targets)
        mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.use_magic_card)
    else
        self.selectHeroNode:SetActive(true)
        self.selectHeroCanvasGroup.alpha = 1.0
    end
    --Log("释放魔法卡",tostring(flag),transInfo.posX,transInfo.posZ,relArgs.unitId,relArgs.skillId,relArgs.skillLev)
end

function BattleSelectHeroView:SelectHero(unitId)
    local roleUid = RunWorld.BattleDataSystem.roleUid

    local isUse = false
    local conf = Config.UnitData.data_unit_info[unitId]
    if conf.type == BattleDefine.UnitType.magic_card then
        isUse = true
    end

    local flag = RunWorld.BattleDataSystem:HasUnit(roleUid,unitId)

	local heroNum = RunWorld.BattleDataSystem:GetHeroNum(roleUid)
    if not isUse and not flag and heroNum >= RunWorld.BattleDataSystem.pvpConf.max_embattle_count then
        SystemMessage.Show(TI18N("已达最大上阵数量,请出售英雄后再次尝试"))
        return
    end
    
	local unlockNum = RunWorld.BattleDataSystem:GetUnlockGridNum(roleUid)
	if not isUse and not flag and heroNum >= unlockNum then
		SystemMessage.Show(TI18N("格子已满，请扩展格子"))
		return
    end

    local maxStar = RunWorld.BattleDataSystem.pvpConf.star_up_count_limit
    if not isUse and flag and RunWorld.BattleDataSystem:GetHeroStarByUnitId(roleUid,unitId) + 1 > maxStar then
        SystemMessage.Show(TI18N("已达最大星级"))
		return
    end

    RunWorld.BattleInputSystem:AddSelectUnit(unitId)
    self.selectHeroNode:SetActive(false)

    self:CheckSelectHeroTips()

    -- local flag,opIndex = RunWorld.BattleInputSystem:AddOp(BattleDefine.Operation.select_hero)
	-- if flag then
	-- 	mod.BattleFacade:SendMsg(10406,opIndex,unitId)
	-- else
	-- 	SystemMessage.Show(TI18N("操作过于频繁"))
	-- end
end

function BattleSelectHeroView:ActiveUnitDetails(flag,data)
    if not flag and not self.battleHeroDetailsPanel then
        return
    end

    -- if not self.battleUnitDetailsPanel then
    --     self.battleUnitDetailsPanel = BattleUnitDetailsPanel.New()
    --     self.battleUnitDetailsPanel:SetParent(UIDefine.canvasRoot)
    -- end
    if self.battleHeroDetailsPanel == nil then
        self.battleHeroDetailsPanel = BattleHeroDetailsPanel.New()
        self.battleHeroDetailsPanel:SetParent(UIDefine.canvasRoot)
    end
    if flag then
        -- self.battleUnitDetailsPanel:SetData(data)
        -- self.battleUnitDetailsPanel:Show()
        self.battleHeroDetailsPanel:SetData(data)
        self.battleHeroDetailsPanel:Show()
    else
        -- self.battleUnitDetailsPanel:Hide()
        self.battleHeroDetailsPanel:Hide()
    end
end

function BattleSelectHeroView:RemoveSlotListen()
    if self.slotMoveListenId then
        TouchManager.Instance:RemoveListen(self.slotMoveListenId)
        self.slotMoveListenId = nil
    end
    if self.slotCancelListenId then
        TouchManager.Instance:RemoveListen(self.slotCancelListenId)
        self.slotCancelListenId = nil
    end
end

function BattleSelectHeroView:RemoveTimer()
    if self.timer then
        TimerManager.Instance:RemoveTimer(self.timer)
        self.timer = nil
        return
    end
end


function BattleSelectHeroView:CheckSelectHeroTips()
    if not BattleDefine.openSelectTips then
        return
    end
    
    local roleUid = RunWorld.BattleDataSystem.roleUid

    local existOp = RunWorld.BattleInputSystem:ExistOp(BattleDefine.Operation.select_hero)

    local existWaitSelectUnits = RunWorld.BattleDataSystem:ExistWaitSelectUnits(roleUid)

    local flag = false
    if not existOp and existWaitSelectUnits then
        flag = true
    end

    if flag then
        if not self.activeSelectUnitTips and not self.selectUnitTipsTimer then
            self.selectUnitTipsTimer = TimerManager.Instance:AddTimer(1,5,self:ToFunc("SelectUnitTipsTimerCb"))
        end
    else
        if self.activeSelectUnitTips or self.selectUnitTipsTimer then
            self:RemoveSelectUnitTipsTimer()
            self:ActiveSelectUnitTips(false)
        end
    end
end

function BattleSelectHeroView:SelectUnitTipsTimerCb()
    self.selectUnitTipsTimer = nil
    self:ActiveSelectUnitTips(true)
end

function BattleSelectHeroView:ActiveSelectUnitTips(flag)
    if self.activeSelectUnitTips ~= flag then
        self.activeSelectUnitTips = flag
        self.selectUnitTips:SetActive(flag)
    end
end

function BattleSelectHeroView:RemoveSelectUnitTipsTimer()
    if self.selectUnitTipsTimer then
        TimerManager.Instance:RemoveTimer(self.selectUnitTipsTimer)
        self.selectUnitTipsTimer = nil
    end
end
