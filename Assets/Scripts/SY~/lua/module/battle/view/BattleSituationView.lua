BattleSituationView = BaseClass("BattleSituationView",ExtendView)

BattleSituationView.Event = EventEnum.New(
    "BeginBattleGroup",
    "HalfBattleGroup"
)

function BattleSituationView:__Init()
    self.baseRoadNumCond = {
        enemyEntity = {  -- 敌方单位>=3
            selfRangeNum = 3,
            selfRangeNumOp = ">=",
            -- enemyRangeNum = 0,
            -- enemyRangeNumOp = ">=",
        },
        selfEntity = {  -- 己方单位<2
            selfRangeNum = 2,
            selfRangeNumOp = "<",
            -- enemyRangeNum = 0,
            -- enemyRangeNumOp = ">=",
    },
    }
    self.situationNode = {
        -- 上阵群攻
        embattleAOEUnit = {
            priority = 1,
            cond = {
                roadNum = 1,
                enemyEntity = {}, -- 无职业、特性要求
                selfEntity = {}   -- 无职业、特性要求
            },
            text = TI18N("<color=#E82B2B>%s路</color>受到威胁，建议上阵<color=#E82B2B>范围伤害型</color>英雄迎敌")
        },
        -- 上阵空中单位
        embattleFlyUnit = {
            priority = 2,
            cond = {
                roadNum = 1,
                enemyEntity = {  -- 敌方单位 没有射手
                    -- haveJob = GDefine.JobIndex.sheshou,
                    haveNotJob = GDefine.JobIndex.sheshou,
                    -- haveWalkType = GDefine.WalkType.floor,
                    -- haveNotWalkType = GDefine.WalkType.floor,
                },
                selfEntity = {  -- 己方单位 有空中单位
                    -- haveJob = GDefine.JobIndex.sheshou,
                    -- haveNotJob = GDefine.JobIndex.sheshou,
                    haveWalkType = GDefine.WalkType.fly,
                    -- haveNotWalkType = GDefine.WalkType.floor,
                },
                -- canRelRageSkill = false
            },
            text = TI18N("<color=#E82B2B>%s路</color>受到威胁，建议上阵<color=#E82B2B>空中单位</color>迎敌"),
        },
        -- 上阵射手
        embattleSheShouUnit = {
            priority = 3,
            cond = {
                roadNum = 1,
                enemyEntity = {  -- 敌方单位 有空中单位
                    haveWalkType = GDefine.WalkType.fly,
                },
                selfEntity = {  -- 己方单位 有射手单位
                    haveJob = GDefine.JobIndex.sheshou,
                }
            },
            text = TI18N("<color=#E82B2B>%s路</color>受到敌方<color=#E82B2B>空中单位</color>威胁，建议上阵<color=#E82B2B>射手</color>迎敌")
        },
        -- 两路受威胁
        twoRoadBeThreatened = {
            priority = 4,
            cond = {
                roadNum = 2,
                enemyEntity = {}, -- 无职业、特性要求
                selfEntity = {}   -- 无职业、特性要求
            },
            text = TI18N("<color=#E82B2B>%s路</color>与<color=#E82B2B>%s路</color>同时受到威胁，注意敌方阵容调整搭配进行抵御")
        },
        -- 三路受威胁-可释放怒气技能
        RelRageSkill = {
            priority = 5,
            cond = {
                roadNum = 3,
                enemyEntity = {}, -- 无职业、特性要求
                selfEntity = {},   -- 无职业、特性要求
                canRelRageSkill = true
            },
            text = TI18N("敌军全面压境，拖拽左下方释放<color=#E82B2B>怒气技能</color>配合抵御")
        },
        -- 三路受威胁-不可释放怒气技能
        CanNotRelRageSkill = {
            priority = 5,
            cond = {
                roadNum = 3,
                enemyEntity = {}, -- 无职业、特性要求
                selfEntity = {},   -- 无职业、特性要求
                canRelRageSkill = false
            },
            text = TI18N("敌军全面压境，注意敌方阵容调整搭配进行抵御")
        }
    }

    self.timer = nil
    self.half = false -- 回合过半
    self.showOnce = false -- 只触发一次
end

function BattleSituationView:__Delete()
    self:RemoveTimer()
    self:RemoveAnim()
end

function BattleSituationView:__CacheObject()
    self.situationTips = self:Find("main/situation_tips/main")
    self.situationCanvasGroup = self:Find("main/situation_tips",CanvasGroup)
    self.situationTipsBg = self:Find("main/situation_tips/main/bg")
    self.situationText = self:Find("main/situation_tips/main/bg/text",Text)
end

function BattleSituationView:__BindEvent()
    self:BindEvent(BattleFacade.Event.FirstRunBattle)
    self:BindEvent(BattleSituationView.Event.BeginBattleGroup)
    self:BindEvent(BattleSituationView.Event.HalfBattleGroup)
end

function BattleSituationView:__Hide()
    self.half = false
    self.showOnce = false
    self:HideSituationTips()
    self:RemoveTimer()
    self:RemoveAnim()
end

function BattleSituationView:FirstRunBattle()
    if not self.timer then
        self.timer = TimerManager.Instance:AddTimer(0,1,self:ToFunc("CheckCond"))
    end

    -- 获取统帅世界坐标转屏幕坐标
    local camp = RunWorld.BattleDataSystem.enterExtraData.selfCamp
    self.commanderEntity = RunWorld.EntitySystem:GetCommanderByCamp(camp)
    local worldPos = self.commanderEntity.clientEntity.ClientTransformComponent:GetPos()
    local screenPos = BaseUtils.WorldToUIPoint(BattleDefine.nodeObjs["main_camera"],Vector3(worldPos.x,worldPos.y,worldPos.z))
    self.situationTips.transform:SetAnchoredPosition(screenPos.x - 190, screenPos.y + 40)

    if not self.anim then
        local anim1 = DelayAnim.New(2)
        local anim2 = ToAlphaAnim.New(self.situationCanvasGroup,0,1)
        self.anim = SequenceAnim.New({anim1,anim2})
    end
end

function BattleSituationView:BeginBattleGroup()
    self.half = false
    self.showOnce = false
end

function BattleSituationView:HalfBattleGroup()
    self.half = true
end

function BattleSituationView:CheckCond()
    if not self.half or self.showOnce then
        return
    end
    self:GetBattleSituation()
    local roadNumInfo = self:CheckRoadNum()
    if roadNumInfo.count == 0 then
        return
    end

    local priority = 0
    local situationText = ""
    for k, v in pairs(self.situationNode) do
        if v.cond.roadNum == roadNumInfo.count then
            local entityFlag = self:CheckEntityCond(roadNumInfo,v.cond.enemyEntity,v.cond.selfEntity)
            local rageSkillFlag = true
            if v.cond.canRelRageSkill then
                rageSkillFlag = v.cond.canRelRageSkill == self:CheckRageSkill()
            end
            if entityFlag and rageSkillFlag then
                if priority < v.priority then
                    priority = v.priority
                    situationText = v.text
                    local str = {"","",""}
                    local j = 1
                    for ii, vv in ipairs(roadNumInfo) do
                        if vv then
                            local strIndex = {
                                [1] = TI18N("左"),
                                [2] = TI18N("中"),
                                [3] = TI18N("右"),
                            }
                            str[j] = strIndex[ii]
                            j = j + 1
                        end
                    end
                    situationText = string.format(situationText,str[1],str[2],str[3])
                end
            end
        end
    end
    if priority > 0 and not StringUtils.IsEmpty(situationText) then
        self:ShowSituationTips(priority,situationText)
    end
end

function BattleSituationView:GetBattleSituation()
    local situation = {
        [1] = { --roadIndex 1
            enemyInfo = {
                selfRangeNum = 0,
                enemyRangeNum = 0,
                job = {},
                walkType = {},
            },
            selfInfo = {
                selfRangeNum = 0,
                enemyRangeNum = 0,
                job = {},
                walkType = {},
            }
        },
        [2] = { --roadIndex 2
            enemyInfo = {
                selfRangeNum = 0,
                enemyRangeNum = 0,
                job = {},
                walkType = {},
            },
            selfInfo = {
                selfRangeNum = 0,
                enemyRangeNum = 0,
                job = {},
                walkType = {},
            }
        },
        [3] = { --roadIndex 3
            enemyInfo = {
                selfRangeNum = 0,
                enemyRangeNum = 0,
                job = {},
                walkType = {},
            },
            selfInfo = {
                selfRangeNum = 0,
                enemyRangeNum = 0,
                job = {},
                walkType = {},
            }
        },
    }
    local selfCamp = RunWorld.BattleDataSystem.enterExtraData.selfCamp
    local enemyEntitys = RunWorld.EntitySystem:GetAllEntityByCamp(selfCamp == BattleDefine.Camp.attack and BattleDefine.Camp.defence or BattleDefine.Camp.attack)
    local selfEntitys =  RunWorld.EntitySystem:GetAllEntityByCamp(selfCamp)
    for i, v in ipairs(enemyEntitys) do
        local entity = RunWorld.EntitySystem:GetEntity(v)
        if entity.TagComponent.mainTag == BattleDefine.EntityTag.hero then
            local pos = entity.TransformComponent:GetPos()
            local flag,roadX = RunWorld.BattleTerrainSystem:InRoadX(pos.x)
            local areaCamp = RunWorld.BattleTerrainSystem:GetAreaCamp(nil,pos.z)
            if areaCamp and flag then
                local job = entity.ObjectDataComponent:GetJob()
                local walkType = entity.ObjectDataComponent:GetWalkType()
                situation[roadX].enemyInfo.job[job] = true
                situation[roadX].enemyInfo.walkType[walkType] = true
                if areaCamp == selfCamp then
                    situation[roadX].enemyInfo.selfRangeNum = situation[roadX].enemyInfo.selfRangeNum + 1
                else
                    situation[roadX].enemyInfo.enemyRangeNum = situation[roadX].enemyInfo.enemyRangeNum + 1
                end
            end
        end
    end
    for i, v in ipairs(selfEntitys) do
        local entity = RunWorld.EntitySystem:GetEntity(v)
        if entity.TagComponent.mainTag == BattleDefine.EntityTag.hero then
            local pos = entity.TransformComponent:GetPos()
            local flag,roadX = RunWorld.BattleTerrainSystem:InRoadX(pos.x)
            local areaCamp = RunWorld.BattleTerrainSystem:GetAreaCamp(nil,pos.z)
            if areaCamp and flag then
                local job = entity.ObjectDataComponent:GetJob()
                local walkType = entity.ObjectDataComponent:GetWalkType()
                situation[roadX].selfInfo.job[job] = true
                situation[roadX].selfInfo.walkType[walkType] = true
                if areaCamp == selfCamp then
                    situation[roadX].selfInfo.selfRangeNum = situation[roadX].selfInfo.selfRangeNum + 1
                else
                    situation[roadX].selfInfo.enemyRangeNum = situation[roadX].selfInfo.enemyRangeNum + 1
                end
            end
        end
    end
    self.situation = situation
end

function BattleSituationView:CheckRoadNum()
    -- 根据self.situation 与 self.baseRoadNumCond 比对，返回分别记录各路是否满足条件的列表
    local roadNumInfo = {}
    local count = 0
    for i, v in ipairs(self.situation) do
        local flag1 = self:CompareField(v.enemyInfo,self.baseRoadNumCond.enemyEntity,"selfRangeNum","selfRangeNumOp")
        local flag2 = self:CompareField(v.enemyInfo,self.baseRoadNumCond.enemyEntity,"enemyRangeNum","enemyRangeNumOp")
        local flag3 = self:CompareField(v.selfInfo,self.baseRoadNumCond.selfEntity,"selfRangeNum","selfRangeNumOp")
        local flag4 = self:CompareField(v.selfInfo,self.baseRoadNumCond.selfEntity,"enemyRangeNum","enemyRangeNumOp")
        if flag1 and flag2 and flag3 and flag4 then
            roadNumInfo[i] = true
            count = count + 1
        else
            roadNumInfo[i] = false
        end
    end
    roadNumInfo.count = count
    return roadNumInfo
end

function BattleSituationView:CompareField(cur,cond,field,opField)
    local op = cond[opField]
    if cur[field] and not cond[field] then
        return true
    end
    if not cur[field] and cond[field] then
        return false
    end

    if op == '<' and cur[field] >= cond[field] then
        return false
    elseif op == '<=' and cur[field] > cond[field] then
        return false
    elseif op == '=' and cur[field] ~= cond[field] then
        return false
    elseif op == '>' and cur[field] <= cond[field] then
        return false
    elseif op == '>=' and cur[field] < cond[field] then
        return false
    end

    return true
end

function BattleSituationView:CheckEntityCond(roadNumInfo,enemyCond,selfCond)
    -- 检测单位特殊条件
    local flag = true
    for i, v in ipairs(roadNumInfo) do
        if v then
            local flag1 = self:CompareJobAndWalkType(self.situation[i].enemyInfo,enemyCond)
            local flag2 = self:CompareJobAndWalkType(self.situation[i].selfInfo,selfCond)
            local flag3 = self:CompareJobAndWalkTypeInBag(selfCond)
            if not flag1 or not (flag2 or flag3) then
                flag = false
            end
        end
    end
    return flag
end

function BattleSituationView:CompareJobAndWalkType(cur,cond)
    -- 检测战场中单位职业与行走方式
    if cond.haveJob and not cur.job[cond.haveJob] then
        return false
    end
    if cond.haveNotJob and cur.job[cond.haveNotJob] then
        return false
    end
    if cond.haveWalkType and not cur.walkType[cond.haveWalkType] then
        return false
    end
    if cond.haveNotWalkType and cur.walkType[cond.haveNotWalkType] then
        return false
    end

    return true
end

function BattleSituationView:CompareJobAndWalkTypeInBag(cond)
    -- 检测玩家卡组中单位的职业与行走方式
    local roleUid = RunWorld.BattleDataSystem.roleUid
    local unitList = nil
    for k, v in pairs(mod.BattleProxy.readyEnterData.role_list) do
        if v.role_base.role_uid == roleUid then
            unitList = v.unit_list
        end
    end
    local job = {}
    local walkType = {}

    for i, v in ipairs(unitList) do
        local unitConf = RunWorld.BattleConfSystem:UnitData_data_unit_info(v.unit_id)
        if not job[unitConf.job] then
            job[unitConf.job] = true
        end
        if not walkType[unitConf.walk_type] then
            walkType[unitConf.walk_type] = true
        end
    end

    if cond.haveJob and not job[cond.haveJob] then
        return false
    end
    if cond.haveNotJob and job[cond.haveNotJob] then
        return false
    end
    if cond.haveWalkType and not walkType[cond.haveWalkType] then
        return false
    end
    if cond.haveNotWalkType and walkType[cond.haveNotWalkType] then
        return false
    end
    return false
end

function BattleSituationView:CheckRageSkill()
    local roleUid = RunWorld.BattleDataSystem.roleUid
    local skillInfo = RunWorld.BattleCommanderSystem:GetCommanderInfo(roleUid).dragSkills[1] -- 暂时只有1为怒气技能
    local skill = self.commanderEntity.SkillComponent:GetSkill(skillInfo.skillId)
    if not skill:IsCd() then
        return false
    end

    if skill:MaxRelNum() then
        return false
    end

    local curRage = RunWorld.BattleCommanderSystem:GetCurRage(roleUid)
    if curRage < skillInfo.consume then
        return false
    end
    return true
end

function BattleSituationView:ShowSituationTips(priority,situationText)
    self.showOnce = true
    self.situationTips.gameObject:SetActive(true)
    self.situationCanvasGroup.alpha = 1
    self.situationText.text = situationText
    local width = self.situationText.transform.sizeDelta.x
    local height = self.situationText.preferredHeight
    UnityUtils.SetSizeDelata(self.situationText.transform,width,height)
    width = self.situationTipsBg.transform.sizeDelta.x
    height = - self.situationText.transform.anchoredPosition.y + height + 30
    UnityUtils.SetSizeDelata(self.situationTipsBg.transform,width,height)

    self.anim:Play()
end

function BattleSituationView:HideSituationTips()
    self.situationTips.gameObject:SetActive(false)
end

function BattleSituationView:RemoveTimer()
    if self.timer then
        TimerManager.Instance:RemoveTimer(self.timer)
        self.timer = nil
    end
end

function BattleSituationView:RemoveAnim()
    if self.anim then
        self.anim:Destroy()
        self.anim = nil
    end
end