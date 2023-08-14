BattleHeroDetailsPanel = BaseClass("BattleHeroDetailsPanel", BaseView)

function BattleHeroDetailsPanel:__Init()
    self:SetAsset("ui/prefab/battle_details/battle_hero_details_panel.prefab", AssetType.Prefab)

    self.attrOrder = {
        [1] = "生命",
        [2] = "攻击",
        [3] = "射程",
        [4] = "攻速",
    }
    self.getAttrInfo = {
        ["生命"] = {fn="GetMaxHp"},
        ["攻击"] = {fn="GetAtk"},
        ["射程"] = {fn="GetAtkRadius"},
        ["攻速"] = {fn="GetAtkSpeed"},
    }

    self.attrs = {}
    self.skills = {}
    self.descRichText = nil

    self.destroyOnClose = false
end

function BattleHeroDetailsPanel:__Delete()
    if self.richTextTipsPanel then
        self.richTextTipsPanel:Destroy()
    end
    self:RemoveRichText()
end

function BattleHeroDetailsPanel:__CacheObject()
    self.bg = self:Find("main/bg",Image)
    self.bg2 = self:Find("main/bg_2",Image)
    self.bg3 = self:Find("main/bg_3",Image)
    self.skillDescBg = self:Find("main/skill_desc_bg",Image)
    self.stand = self:Find("main/stand",Image)
    self.heroName = self:Find("main/name",Text)
    self.level = self:Find("main/lev",Text)
    self.feature = self:Find("main/feature",Text)

    for i = 1, 4 do
        local attr = {}
        attr.transform = self:Find("main/attr_con/attr_"..i)
        attr.gameObject = attr.transform.gameObject
        attr.num = self:Find("main/attr_con/attr_"..i.."/num",Text)
        table.insert(self.attrs,attr)
    end

    for i = 1, 4 do
        local skillItem = {}
        skillItem.transform = self:Find("main/skill_con/skill_"..i)
        skillItem.gameObject = skillItem.transform.gameObject
        skillItem.index = i
        skillItem.isOn = false
        skillItem.btn = skillItem.transform:Find("icon").gameObject:GetComponent(Button)
        skillItem.icon = skillItem.transform:Find("icon").gameObject:GetComponent(Image)
        skillItem.lockNode = skillItem.transform:Find("locked").gameObject
        skillItem.condNum = skillItem.transform:Find("locked/cond_num").gameObject:GetComponent(Text)
        self.skills[i] = skillItem
    end

    self.skillCon = self:Find("main/skill_con")
    self.skillSelected = self:Find("main/skill_con/selected")
    self.richTextParent = self:Find("main/skill_desc_bg/desc")
    self.horn = self:Find("main/skill_desc_bg/horn")
    Canvas.ForceUpdateCanvases()
end

function BattleHeroDetailsPanel:__Create()
    self.name = self.transform.name
    self:SetOrder()

    if not self.richTextTipsPanel then
        self.richTextTipsPanel = RichTextTipsPanel.New()
        self.richTextTipsPanel:SetParent(self:Find("main"))
    end
    self.richTextTipsPanel:Show()
end


function BattleHeroDetailsPanel:__BindListener()
    self:Find("panel_bg", Button):SetClick( self:ToFunc("OnCloseClick") )
end

function BattleHeroDetailsPanel:__BindEvent()
end

function BattleHeroDetailsPanel:__Hide()
end

function BattleHeroDetailsPanel:__Show()
    self:SetBg()       -- 根据品质设置4张背景
    self:SetBaseInfo() -- 设置名称、立绘、等级、特性
    self:SetAttrs()    -- 设置生命、攻击、攻速
    self:SetSkills()   -- 设置技能
    self:SwitchSkillDesc(1)
end

function BattleHeroDetailsPanel:SetDestroyOnClose(flag)
    self.destroyOnClose = flag
end

function BattleHeroDetailsPanel:SetData(battleData)
    self.unitCfg = Config.UnitData.data_unit_info[battleData.unit_id]
    self.battleData = battleData
    local key = battleData.unit_id.."_"..self.battleData.level
    self.levCfg = Config.UnitData.data_unit_lev_info[key]
    self.commanderStar = self.battleData.star and self.battleData.star or 1

    local key2 = battleData.unit_id.."_"..self.commanderStar
    self.starCfg = Config.UnitData.data_unit_star_info[key2]
end

function BattleHeroDetailsPanel:SetMainData(unit_id,level,star)
    self:SetData({unit_id=unit_id,level=level,star=star})
end

function BattleHeroDetailsPanel:SetBg()
    local quality = self.unitCfg.quality
    local bgPaths = AssetPath.QualityToBattleDetailsBgs(quality)
    for k, v in pairs(bgPaths) do
        self:SetSprite(self[k],v,true)
    end
end

function BattleHeroDetailsPanel:SetBaseInfo()
    self:SetSprite(self.stand,AssetPath.GetUnitStandBattleDetails(self.unitCfg.head) ,true)

    self.heroName.text = TI18N(self.unitCfg.name)
    self.level.text = "Lv."..self.battleData.level
    self.feature.text = TI18N(self.unitCfg.feature)
end

function BattleHeroDetailsPanel:RemoveRichText()
    if self.descRichText then
        self.descRichText:Delete()
        self.descRichText = nil
    end
end

function BattleHeroDetailsPanel:CreateRichText(content)
    local richTextInfo = RichTextInfo.New()
    richTextInfo.content = TI18N(content)
    richTextInfo.lineSpacing = 1
    richTextInfo.viewWidth = 420
    richTextInfo.elementTemplate =
    {
        [RichTextDefine.Element.none_text] ={original = self:Find("rich_text_templete/normal_text")
            ,textComponent = self:Find("rich_text_templete/normal_text/text",Text)},
        [RichTextDefine.Element.rich_text] ={original = self:Find("rich_text_templete/normal_text")
            ,textComponent = self:Find("rich_text_templete/normal_text/text",Text)},
        [RichTextDefine.Element.click_text] ={ original = self:Find("rich_text_templete/click_text")
            ,textComponent = self:Find("rich_text_templete/click_text/text",Text)},
    }

    richTextInfo.parent = self.richTextParent
    richTextInfo.onClick = self:ToFunc("ShowRichTextTips")

    self:RemoveRichText()
    self.descRichText = RichText.Create(richTextInfo)
end

function BattleHeroDetailsPanel:ShowRichTextTips(logicElementType,args,richTextTrans)
    self.richTextTipsPanel:ShowRichTextTips(logicElementType,args,richTextTrans)
end

function BattleHeroDetailsPanel:HideRichTextTips()
    self.richTextTipsPanel:HideRichTextTips()
end

function BattleHeroDetailsPanel:SetAttrs()
    for i=1, #self.attrs do
        local title = TI18N(self.attrOrder[i])
        local getAttrInfo = self.getAttrInfo[title]
        local value = self[getAttrInfo.fn](self)
        if value ~= nil then
            -- 非数值属性 或 数值属性且大于0
            if tonumber(value)== nil or tonumber(value)~= nil and tonumber(value) > 0 then
                self.attrs[i].num.text = value
            end
        end
        self.attrs[i].gameObject:SetActive(value ~= nil)
    end
end

function BattleHeroDetailsPanel:SetSkills()
    local showSkillList = self.levCfg.show_skill_list
    for i,v in ipairs(showSkillList) do
        local skillId = v[1]
        local skillLev = v[2]
        local unlockStar = v[3]
        local skillBaseConf = Config.SkillData.data_skill_base[skillId]

        local skill = self.skills[i]
        skill.baseConf = skillBaseConf
        self:SetSprite(skill.icon,AssetPath.GetSkillIcon(skillBaseConf.icon))
        UIUtils.Grey(skill.icon, unlockStar ~= 0 and self.commanderStar < unlockStar)
        skill.lockNode:SetActive(unlockStar ~= 0 and self.commanderStar < unlockStar)
        skill.condNum.text = unlockStar
        skill.btn:SetClick(self:ToFunc("SwitchSkillDesc"),i)
        skill.isOn = false
    end
    for i = #showSkillList + 1, 4 do
        self.skills[i].gameObject:SetActive(false)
    end
end

function BattleHeroDetailsPanel:SwitchSkillDesc(index)
    if not self.skills[index] or self.skills[index].isOn then
        return
    end
    for i, v in ipairs(self.skills) do
        if v.index == index then
            v.isOn = true
            self.skillSelected:SetParent(v.transform)
            self.horn:SetParent(v.transform)
            UnityUtils.SetAnchoredPosition(self.skillSelected,0,self.skillSelected.anchoredPosition.y)
            UnityUtils.SetAnchoredPosition(self.horn,0,self.horn.anchoredPosition.y)

            local baseDescId = tonumber(v.baseConf.skill_desc)
            -- local levDescList = self:FormatLevDesc(v.baseConf.skill_lev_desc)

            self:RemoveRichText()
            local baseDescContent = TI18N(Config.UnitData.data_unit_up_desc[baseDescId].desc)
            self:CreateRichText(baseDescContent)

        else
            v.isOn = false
        end
    end
end

function BattleHeroDetailsPanel:OnCloseClick()
    if self.destroyOnClose then
        self:Destroy()
        return
    end
    for k, v in pairs(self.attrs) do
        v.gameObject:SetActive(false)
    end
    self:Hide()
end

function BattleHeroDetailsPanel:GetMaxHp()
    local maxHp = 0
    local addNum = 0
    maxHp,addNum = self:GetAttrValByAttrId(GDefine.Attr.max_hp)
    return maxHp,addNum
end

function BattleHeroDetailsPanel:GetAtk()
    local atk = 0
    local addNum = 0
    atk,addNum = self:GetAttrValByAttrId(GDefine.Attr.atk)
    return atk,addNum
end

function BattleHeroDetailsPanel:GetAtkRadius()
    local atkRadius = 0
    local addNum = 0
    atkRadius = self.unitCfg.atk_radius_show
    return atkRadius,addNum
end

function BattleHeroDetailsPanel:GetAtkSpeed()
    local val,addNum = self:GetAttrValByAttrId(GDefine.Attr.atk_speed)
    local atkSpeed = self.unitCfg.atk_time / val
    local atkSpeedAddNum = addNum~=0 and self.unitCfg.atk_time / addNum or 0
    return atkSpeed,atkSpeedAddNum
end

function BattleHeroDetailsPanel:GetAttrValByAttrId(id)
    local attrList = nil
    local attrRatiosList = nil
    local nextLevAttrList = nil
    local curVal = 0
    local addVal = 0

    attrList = self.levCfg.attr_list
    attrRatiosList = self.starCfg.attr_list

    for k, v in pairs(attrList) do
        local attrId = 0
        local attrVal = 0
            attrId = GDefine.AttrNameToId[v[1]]
            attrVal = v[2]
            local attrRatio = 10000
            for k2, v2 in pairs(attrRatiosList) do
                if v2[1] == v[1] then
                    attrRatio = v2[2]
                    break
                end
            end
            attrVal = FPMath.Divide(attrVal * attrRatio,BattleDefine.AttrRatio)
        if attrId == id then
            curVal = attrVal
            break
        end
    end
    local nextVal = nil
    if nextLevAttrList then
        for k, v in pairs(nextLevAttrList) do
            if GDefine.AttrNameToId[v[1]] == id then
                nextVal = v[2]
                break
            end
        end
        if nextVal then
            addVal = nextVal - curVal
        end
    end
    return curVal,addVal
end