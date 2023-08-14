BattleStarUpView = BaseClass("BattleStarUpView",ExtendView)

BattleStarUpView.Event = EventEnum.New(
    "UnitStarUpdate"
)

function BattleStarUpView:__Init()
    -- self.unitUnlockStar = Config.ConstData.data_const_info["unit_unlock_skill_star"].val
    self.skillIcons = {}   -- gameObjec

    self.starUpBubbles = {}
end

function BattleStarUpView:__Delete()
    self:RemoveSkillIcons()
    self:RemoveStarUpBubbles()
end

function BattleStarUpView:__CacheObject()
    self.canvasGroup = self:Find("main/star_up",CanvasGroup)
    self.skillIconParent = self:Find("main/star_up")
    self.skillIcon = self:Find("main/star_up/skill_icon").gameObject
    self.starUpBubbleTemp = self:Find("template/star_up_bubble_temp")
    self.starUpBubbleCon = self:Find("main/star_up/bubble_con")
end

function BattleStarUpView:__BindEvent()
    -- self:BindEvent(BattleFacade.Event.FirstRunBattle)
    self:BindEvent(BattleStarUpView.Event.UnitStarUpdate)
end

function BattleStarUpView:__Hide()
    self:RemoveSkillIcons()
    self:RemoveStarUpBubbles()
end

function BattleStarUpView:UnitStarUpdate(roleUid,unitId,grid,star,srcStar)
    local selfRoleUid = RunWorld.BattleDataSystem.roleUid

    local unitBaseData = RunWorld.BattleDataSystem:GetBaseUnitData(roleUid,unitId)
    local srcUnitData = srcStar > 0 and RunWorld.BattleMixedSystem:CalcUpStarData(unitBaseData,srcStar,grid)
    local curUnitData = RunWorld.BattleDataSystem:GetUnitData(roleUid,unitId)
    -- LogTable("unitBaseData",unitBaseData)
    -- LogTable("srcUnitData",srcUnitData)
    -- LogTable("curUnitData",curUnitData)  --TODO 用作属性计算

    local starConf = RunWorld.BattleConfSystem:UnitData_data_unit_star_info(unitId,star)

    if roleUid == selfRoleUid then
        self:SelfUnitStarUpdate(roleUid,unitId,grid,star,srcStar,starConf)
    else
        self:EnemyUnitStarUpdate(roleUid,unitId,grid,star,srcStar,starConf)
    end
end

function BattleStarUpView:SelfUnitStarUpdate(roleUid,unitId,grid,star,srcStar,starConf)
    self:PlayStarUpdateOperateEffect(grid,star,srcStar,starConf)

    local effectId = nil
    if star - srcStar > 0 then
        self:ShowStarBubble(grid,starConf)
        effectId = starConf.scene_star_up_effect == 0 and 5001011 or starConf.scene_star_up_effect
    elseif star - srcStar < 0 then
        effectId = nil  --TODO 缺少降星场景特效id
    end
    self:PlayStarUpdateSceneEffect(roleUid,unitId,effectId)
    self:ShowUnlockSkillIcon(roleUid,unitId,starConf)
    self:ShowFullStarEffect(roleUid,unitId,star,srcStar)
end

function BattleStarUpView:EnemyUnitStarUpdate(roleUid,unitId,grid,star,srcStar,starConf)
    local effectId = nil
    if star - srcStar > 0 then
        effectId = starConf.scene_star_up_effect == 0 and 5001011 or starConf.scene_star_up_effect
    elseif star - srcStar < 0 then
        effectId = nil  --TODO 缺少降星场景特效id
    end
    self:PlayStarUpdateSceneEffect(roleUid,unitId,effectId)
    self:ShowFullStarEffect(roleUid,unitId,star,srcStar)
end

function BattleStarUpView:PlayUpEffect(effectId,pos)
    RunWorld.BattleAssetsSystem:PlaySceneEffect(effectId,pos.x*1000,pos.y*1000,pos.z*1000)
end

function BattleStarUpView:PlayAttrFlyingText(srcUnitData,curUnitData,pos)
    local addAttrList = self:GetAddAttrVal(srcUnitData.attr_list,curUnitData.attr_list)
    for i, v in ipairs(addAttrList) do
        local args = {}
        args.showLevel = i
        args.showText = "+"..tostring(v.addVal)
        args.attrId = v.attrId
        RunWorld.ClientIFacdeSystem:Call("SendEvent","FlyingTextView","ShowFlyingTextByPos",BattleDefine.FlyingText.attr,args,pos)
    end
end

function BattleStarUpView:GetAddAttrVal(srcAttrList,curAttrList)
    local addAttrList = {}
    for i, v in ipairs(curAttrList) do
        local curAttrId = v.attr_id
        local curAttrVal = v.attr_val

        local srcAttrId = srcAttrList[i].attr_id
        local srcAttrVal = srcAttrList[i].attr_val

        if curAttrId ~= srcAttrId then
            for ii, vv in ipairs(srcAttrList) do
                if vv.attr_id == curAttrId then
                    srcAttrVal = vv.attr_val
                end
            end
        end
        local addVal = curAttrVal - srcAttrVal
        if addVal > 0 then
            table.insert(addAttrList,{attrId = curAttrId, addVal = addVal})
        end
    end
    return addAttrList
end

function BattleStarUpView:PlayStarUpdateSceneEffect(roleUid,unitId,effectId)
    if not effectId or effectId == 0 then
        return
    end
    local existEntitys = RunWorld.EntitySystem:GetRoleEntitys(roleUid,unitId)
    for _, entityUid in ipairs(existEntitys) do
        RunWorld.BattleAssetsSystem:PlayUnitEffect(entityUid,effectId)
    end
end

function BattleStarUpView:ShowUnlockSkillIcon(roleUid,unitId,starConf)
    local skillConf = Config.SkillData.data_skill_base[starConf.unlock_skill]
    if not skillConf then
        return
    end

    local existEntitys = RunWorld.EntitySystem:GetRoleEntitys(roleUid,unitId)
    for _, entityUid in ipairs(existEntitys) do
        RunWorld.ClientIFacdeSystem:Call("SendEvent","FlyingTextView","ShowFlyingText",BattleDefine.FlyingText.skill_unlock,
            {uid = entityUid,skillName = skillConf.name,skillIcon = skillConf.icon,entityUid = entityUid})
    end
end

function BattleStarUpView:UnitUnlockSkill(unitId,pos)
    local item = {}
    local skillIcon = GameObject.Instantiate(self.skillIcon)
    skillIcon.transform:SetParent(self.skillIconParent)
    skillIcon.transform:Reset()
    item.gameObject = skillIcon
    item.image = skillIcon:GetComponent(Image)

    item.canvasGroup = skillIcon:GetComponent(CanvasGroup)

    local inAnim = ToCanvasGroupAlphaAnim.New(item.canvasGroup,1,0.1)
    local delayAnim = DelayAnim.New(0.5)
    local outAnim = ToCanvasGroupAlphaAnim.New(item.canvasGroup,0,0.4)
    item.skillIconAnim = SequenceAnim.New({inAnim,delayAnim,outAnim})

    UnityUtils.SetLocalPosition(item.gameObject.transform,pos.x,pos.y-2,pos.z)
    item.canvasGroup = 0
    item.gameObject:SetActive(true)
    local toShowSkillId = RunWorld.BattleConfSystem:UnitData_data_unit_info(unitId).show_skill_icon[1]
    self:SetSprite(item.image,AssetPath.GetSkillIcon(toShowSkillId))

    item.skillIconAnim:Play()
    table.insert(self.skillIcons,item)
end

function BattleStarUpView:RemoveSkillIcons()
    for k, v in pairs(self.skillIcons) do
        GameObject.Destroy(v.gameObject)
        v.skillIconAnim:Delete()
    end
    self.skillIcons = {}
end

function BattleStarUpView:RemoveStarUpBubbles()
    for k, v in pairs(self.starUpBubbles) do
        GameObject.Destroy(v.gameObjec)
        v.anim:Delete()
    end
end

-- UI特效挂在对应grid并播放
function BattleStarUpView:PlayStarUpdateOperateEffect(grid,star,srcStar,starConf)
    local delta = star - srcStar
    if delta > 0 then
        if starConf and starConf.star > 1 then
            -- local effectId = starConf.ui_star_up_effect
            local effectId = 10020
            local duration = 1000
            mod.BattleFacade:SendEvent(BattleHeroGridView.Event.ShowEffectOnGrid, grid, effectId, duration)
        end
    elseif delta < 0 then
        if starConf then
            -- local effectId = starConf.ui_star_up_effect
            local effectId = 10020
            local duration = 1000
            mod.BattleFacade:SendEvent(BattleHeroGridView.Event.ShowEffectOnGrid, grid, effectId, duration)
        end
    end
end

function BattleStarUpView:ShowStarBubble(grid,starConf)
    local text = starConf.star_up_say
    if StringUtils.IsEmpty(text) then
        return
    end
    local bubble = {}
    bubble.gameObject = GameObject.Instantiate(self.starUpBubbleTemp)
    bubble.transform = bubble.gameObject.transform
    bubble.transform:SetParent(self.starUpBubbleCon)
    bubble.transform:Reset()
    local x = math.fmod(grid-1,5) * 122 - 244
    local y = math.floor((grid-1)/5) * (-136) + 136 -- 计算方式与HeroGridView的格子摆放位置一致
    y = y + 90
    UnityUtils.SetAnchoredPosition(bubble.transform, x, y)

    bubble.text = bubble.transform:Find("main/text").gameObject:GetComponent(Text)
    bubble.canvasGroup = bubble.gameObject:GetComponent(CanvasGroup)

    UnityUtils.SetLocalScale(bubble.transform,0,0,1)
    local inAnim = ScaleAnim.New(bubble.transform,Vector3(0.8,0.8,1),0.6)
    inAnim:SetEase(DG.Tweening.Ease.OutBack)
    local delayAnim = DelayAnim.New(0.5)
    local outAnim = ToCanvasGroupAlphaAnim.New(bubble.canvasGroup,0,0.2)
    bubble.anim = SequenceAnim.New({inAnim,delayAnim,outAnim})
    bubble.anim = inAnim
    table.insert(self.starUpBubbles,bubble)

    bubble.text.text = text
    bubble.anim:Play()
end

function BattleStarUpView:ShowFullStarEffect(roleUid,unitId,star,srcStar)
    if star > srcStar and star == RunWorld.BattleDataSystem.pvpConf.star_up_count_limit then
        local existEntitys = RunWorld.EntitySystem:GetRoleEntitys(roleUid,unitId)
        for _, entityUid in ipairs(existEntitys) do
            local entity = RunWorld.EntitySystem:GetEntity(entityUid)
            if entity then
                entity.clientEntity.ShaderEffectComponent:ActiveEffect(BattleDefine.ShaderEffect.flash,true,1)
            end
        end
    end
end