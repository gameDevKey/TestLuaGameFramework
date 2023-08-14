BattleUnitDetailsScrollPanel = BaseClass("BattleUnitDetailsScrollPanel", ExtendView)

function BattleUnitDetailsScrollPanel:__Init()
    self.enum = {
        PageMode = {
            onePageMode = 1,
            twoPageMode = 2,
            threePageMode = 3,
        },
        SkillIconX = {
            [1] = {
                [1] = 0,
            },
            [2] = {
                [1] = -85.5,
                [2] = 85.5,
            },
            [3] = {
                [1] = -141,
                [2] = 0,
                [3] = 141,
            },
            [4] = {
                [1] = -211.5,
                [2] = -70.5,
                [3] = 70.5,
                [4] = 211.5,
            }
        },
        SkillTipsX = {
            [1] = {
                [1] = 0,
            },
            [2] = {
                [1] = -24,
                [2] = 24,
            },
            [3] = {
                [1] = -59,
                [2] = 0,
                [3] = 59,
            },
            [4] = {
                [1] = -124,
                [2] = -6,
                [3] = 6,
                [4] = 124,
            }
        }
    }

    self.attrList = {
        [self.enum.PageMode.onePageMode] = {},
        [self.enum.PageMode.twoPageMode] = {},
        [self.enum.PageMode.threePageMode] = {},
    }

    self.skillItems = {}
    self.pageMode = self.enum.PageMode.threePageMode
    self.pageCount = 3
    self.page = 1
    self.ratio = 0

    self.starDescList = {}
    self.levDescList = {}
end

function BattleUnitDetailsScrollPanel:__CacheObject()
    self.scrollView = self:Find("main/high_level_info/scroll_view").gameObject
    self.scrollContent = self:Find("main/high_level_info/scroll_view/viewport/content")
    self.cacheObj = {
        [self.enum.PageMode.onePageMode] = {
            obj = self:Find("main/high_level_info/scroll_view/viewport/content/one_page_mode").gameObject,
            attrParent = self:Find("main/high_level_info/scroll_view/viewport/content/one_page_mode/attribute"),
            attrItem = self:Find("main/high_level_info/scroll_view/viewport/content/one_page_mode/attribute/attr_item").gameObject,

            lowestStarDesc = self:Find("main/high_level_info/scroll_view/viewport/content/one_page_mode/up_desc/lowest_star_desc").gameObject,
            highestStarDesc = self:Find("main/high_level_info/scroll_view/viewport/content/one_page_mode/up_desc/highest_star_desc").gameObject,
            star = self:Find("main/base_info/star").gameObject,
            starNum = self:Find("main/base_info/star/num",Text),
        },
        [self.enum.PageMode.twoPageMode] = {
            obj = self:Find("main/high_level_info/scroll_view/viewport/content/two_page_mode").gameObject,
            attrParent = self:Find("main/high_level_info/scroll_view/viewport/content/two_page_mode/attribute"),
            attrItem = self:Find("main/high_level_info/scroll_view/viewport/content/two_page_mode/attribute/attr_item").gameObject,
            skillItem = self:Find("main/high_level_info/scroll_view/viewport/content/two_page_mode/attribute/skill_item").gameObject,
            biography = self:Find("main/high_level_info/scroll_view/viewport/content/two_page_mode/biography/text", Text),
            scrollbarObj = self:Find("main/high_level_info/scroll_view/scrollbar_2_page").gameObject,
            scrollbar = self:Find("main/high_level_info/scroll_view/scrollbar_2_page/sliding_area"),
            handle = self:Find("main/high_level_info/scroll_view/scrollbar_2_page/sliding_area/handle"),
            skillTips = self:Find("skill_tips").gameObject,
            skillTipsMain = self:Find("skill_tips/main/bg"),
            skillTipsHorn = self:Find("skill_tips/main/horn"),
            skillName = self:Find("skill_tips/main/bg/name",Text),
            skillDesc = self:Find("skill_tips/main/bg/desc",Text),
            skillUnlockCond = self:Find("skill_tips/main/bg/unlock_condition",Text),
        },
        [self.enum.PageMode.threePageMode] = {
            obj = self:Find("main/high_level_info/scroll_view/viewport/content/three_page_mode").gameObject,
            attrParent = self:Find("main/high_level_info/scroll_view/viewport/content/three_page_mode/attribute"),
            attrItem = self:Find("main/high_level_info/scroll_view/viewport/content/three_page_mode/attribute/attr_item").gameObject,

            upDescParent = self:Find("main/high_level_info/scroll_view/viewport/content/three_page_mode/up_desc/up_scroll_view/viewport/content"),
            upDescStarItem = self:Find("main/high_level_info/scroll_view/viewport/content/three_page_mode/up_desc/up_scroll_view/viewport/content/star_up_item").gameObject,
            upDescSplitLine = self:Find("main/high_level_info/scroll_view/viewport/content/three_page_mode/up_desc/up_scroll_view/viewport/content/split_line"),
            upDescLevItem = self:Find("main/high_level_info/scroll_view/viewport/content/three_page_mode/up_desc/up_scroll_view/viewport/content/lev_up_item").gameObject,

            biography = self:Find("main/high_level_info/scroll_view/viewport/content/three_page_mode/biography/text", Text),
            scrollbarObj = self:Find("main/high_level_info/scroll_view/scrollbar_3_page").gameObject,
            scrollbar = self:Find("main/high_level_info/scroll_view/scrollbar_3_page/sliding_area"),
            handle = self:Find("main/high_level_info/scroll_view/scrollbar_3_page/sliding_area/handle"),
        }
    }
end

function BattleUnitDetailsScrollPanel:__Create()
    self.scrollEventTrigger = self.scrollView:AddComponent(EventSystems.EventTrigger)
    self.scrollEventTrigger:SetEvent(EventSystems.EventTriggerType.PointerDown,self:ToFunc("ScrollViewDown"))
end


function BattleUnitDetailsScrollPanel:InitAttribute()
    local column_num = 2
    for i = 1, 6 do
        local attr = GameObject.Instantiate(self.cacheObj[self.pageMode].attrItem)
        attr.transform:SetParent(self.cacheObj[self.pageMode].attrParent)
        attr.transform:Reset()
        local x = (i-1) % column_num * 283 + 8
        local y = -59.5 * math.floor((i-1) /column_num) - 13.5
        UnityUtils.SetAnchoredPosition(attr.transform, x, y)
        attr:SetActive(false)
        local item = {}
        item.attr = attr
        item.icon = attr.transform:Find("icon"):GetComponent(Image)
        item.title = attr.transform:Find("title"):GetComponent(Text)
        item.value = attr.transform:Find("value"):GetComponent(Text)
        item.addValue = attr.transform:Find("add_value"):GetComponent(Text)
        -- item.btn = attr.transform:Find("more_msg"):GetComponent(Button)
        table.insert(self.attrList[self.pageMode], item)
    end
    self.cacheObj[self.pageMode].attrItem:SetActive(false)
end

function BattleUnitDetailsScrollPanel:__BindListener()
    self:Find("skill_tips/panel_bg",Button):SetClick( self:ToFunc("HideSkillTips"))
end

function BattleUnitDetailsScrollPanel:__BindEvent()
    self:BindEvent(BattleFacade.Event.CancelOperate)
end

function BattleUnitDetailsScrollPanel:SetData()
    self.unitCfg = self.MainView.unitCfg
    self.data = self.MainView.data
    self.levCfg = self.MainView.levCfg
    self.nextLevCfg = self.MainView.nextLevCfg
    self.pageMode = self.MainView.pageMode
    self.pageCount = self.pageMode
end

function BattleUnitDetailsScrollPanel:SetBattleData(data)
    self.battleData = data
end

function BattleUnitDetailsScrollPanel:SetScrollPanel()
    if self.pageMode == self.enum.PageMode.onePageMode then
        self.scrollEventTrigger:ClearEvent()
        self.cacheObj[self.pageMode].star:SetActive(true)
        self.cacheObj[self.pageMode].obj:SetActive(true)
        UnityUtils.SetSizeDelata(self.scrollContent, 573, 355)
        self:ShowBattleData()
        return
    end
    self.cacheObj[self.pageMode].obj:SetActive(true)
    self.cacheObj[self.pageMode].scrollbarObj:SetActive(true)
    self:SetAttribute()
    self:SetUpDesc()
    self:SetBiography()
    local x = 573 * self.pageCount
    UnityUtils.SetSizeDelata(self.scrollContent, x, 355)
end

function BattleUnitDetailsScrollPanel:SetAttribute()
    if next(self.attrList[self.pageMode]) == nil then
        self:InitAttribute()
    end
    local i = 1
    local attrList = nil
    local nextLevAttrList = nil
    local obtained = true
    if self.data and self.data.attr_list then
        attrList = self.data.attr_list
        obtained = true
        if self.nextLevCfg then
            nextLevAttrList = self.nextLevCfg.attr_list
        end
    else
        attrList = self.levCfg.attr_list
        obtained = false
    end
    for k, v in pairs(attrList) do
        local item = self.attrList[self.pageMode][i]
        local key = obtained and v.attr_id or v[1]
        local iconPath = obtained and AssetPath.AttrIdToIcon[key] or AssetPath.AttrNameToIcon[key]
        local titleDesc = obtained and GDefine.AttrIdToDesc[key] or GDefine.AttrNameToDesc[key]
        local nextVal = 0
        if nextLevAttrList then
            for k1, v1 in pairs(nextLevAttrList) do
                if GDefine.AttrNameToId[v1[1]] == v.attr_id then
                    nextVal = v1[2]
                    break
                end
            end
        end
        local add = obtained and nextVal - v.attr_val or 0
        if iconPath and titleDesc then
            self:SetSprite(item.icon,iconPath)
            item.title.text = TI18N(titleDesc)
            local val = 0
            if obtained then
                val = v.attr_val
            else
                val = v[2]
            end
            if obtained and (v.attr_id == GDefine.Attr.atk_speed) or (v[1] == GDefine.AttrIdToName[GDefine.Attr.atk_speed]) then
                if val ~= 0 then
                    val = self.unitCfg.atk_time / val
                end
            end
            item.value.text = val
            item.addValue.text = obtained and add > 0 and "+"..add or ""
            UnityUtils.SetAnchoredPosition(item.addValue.transform,-63 + 10 + item.value.preferredWidth, -13.5)
            item.attr:SetActive(true)
            i = i+1
        end
    end

    for j = i, 6 do
        local item = self.attrList[self.pageMode][j]
        item.attr:SetActive(false)
    end
end

function BattleUnitDetailsScrollPanel:ShowBattleData()
    if next(self.attrList[self.pageMode]) == nil then
        self:InitAttribute()
    end

    self.cacheObj[self.pageMode].starNum.text = self.battleData.star

    local index = 1
    for i=1,#self.battleData.attr_list do
        local item = self.attrList[self.pageMode][index]
        local key = self.battleData.attr_list[i].attr_id
        local iconPath = AssetPath.AttrIdToIcon[key]
        local titleDesc = GDefine.AttrIdToDesc[key]

        if iconPath and titleDesc then
            self:SetSprite(item.icon,iconPath)
            item.title.text = TI18N(titleDesc)
            local val = self.battleData.attr_list[i].attr_val
            if key == GDefine.Attr.atk_speed then
                val = self.unitCfg.atk_time / val
            end
            item.value.text = val
            item.attr:SetActive(true)
            index = index+1
        end
    end

    local starDescs = self.unitCfg.star_up_desc
    if next(starDescs) == nil then
        local lowestStarDesc = self.cacheObj[self.pageMode].lowestStarDesc
        local highestStarDesc = self.cacheObj[self.pageMode].highestStarDesc
        local title = lowestStarDesc.transform:Find("title/text"):GetComponent(Text)
        title.text = ""
        local desc = lowestStarDesc.transform:Find("desc"):GetComponent(Text)
        local descId = self.unitCfg.lev_up_desc[self.data.level][2]
        desc.text = TI18N(Config.UnitData.data_unit_up_desc[descId].desc)

        lowestStarDesc:SetActive(true)
        highestStarDesc:SetActive(false)
        return
    end
    local lowestStarDesc = self.cacheObj[self.pageMode].lowestStarDesc
    local title = lowestStarDesc.transform:Find("title/text"):GetComponent(Text)
    title.text = TI18N(starDescs[1][1].."星")
    local desc = lowestStarDesc.transform:Find("desc"):GetComponent(Text)
    local descId = starDescs[1][2]
    desc.text = TI18N(Config.UnitData.data_unit_up_desc[descId].desc)

    local highestStarDesc = self.cacheObj[self.pageMode].highestStarDesc
    highestStarDesc:SetActive(true)
    title = highestStarDesc.transform:Find("title/text"):GetComponent(Text)
    title.text = TI18N(starDescs[2][1].."星")
    desc = highestStarDesc.transform:Find("desc"):GetComponent(Text)
    descId = starDescs[2][2]
    desc.text = TI18N(Config.UnitData.data_unit_up_desc[descId].desc)
end

function BattleUnitDetailsScrollPanel:SetUpDesc()
    local descData = Config.UnitData.data_unit_up_desc
    if self.pageMode == self.enum.PageMode.twoPageMode then
        local skillList = self.unitCfg.skill_list
        if #skillList < 1 then
            return
        end
        self.cacheObj[self.pageMode].skillItem:SetActive(true)
        for i, v in ipairs(skillList) do
            local skillItem = GameObject.Instantiate(self.cacheObj[self.pageMode].skillItem)
            skillItem.transform:SetParent(self.cacheObj[self.pageMode].attrParent)
            skillItem.transform:Reset()
            local x = self.enum.SkillIconX[#skillList][i]
            local y = -30
            UnityUtils.SetAnchoredPosition(skillItem.transform, x, y)
            table.insert(self.skillItems, skillItem)

            local iconPath = AssetPath.GetSkillIcon(v)
            self:SetSprite(skillItem.transform:Find("icon"):GetComponent(Image),iconPath,false)

            local skillCfg = Config.SkillData.data_skill_base[v]
            if not skillCfg then
                LogError(string.format("不存在的技能基础配置[skillId %s]",v))
            end
            local key = v .. "_" .. self.data.level
            local skillLevCfg = Config.SkillData.data_skill_lev[key]
            if not skillLevCfg then
                LogError(string.format("不存在的技能等级配置[skillId %s][skillLev %s]",v,self.data.level))
                key = v .. "_1"
                skillLevCfg = Config.SkillData.data_skill_lev[key]
            end
            if not skillLevCfg then
                LogError(string.format("不存在的技能等级配置[skillId %s][skillLev %s]",v,1))
                return
            end
            skillItem:GetComponent(Button):SetClick( self:ToFunc("ShowSkillTips"),#skillList,i,{skillCfg = skillCfg,skillLevCfg =skillLevCfg} )
        end
        self.cacheObj[self.pageMode].skillItem:SetActive(false)
    elseif self.pageMode == self.enum.PageMode.threePageMode then
        self.cacheObj[self.pageMode].upDescStarItem:SetActive(true)
        self.cacheObj[self.pageMode].upDescLevItem:SetActive(true)
        local type = self.unitCfg.type
        local starDescs = self.unitCfg.star_up_desc
        local levDescs = self.unitCfg.lev_up_desc
        for i, v in ipairs(starDescs) do
            local starDesc = GameObject.Instantiate(self.cacheObj[self.pageMode].upDescStarItem)
            starDesc.transform:SetParent(self.cacheObj[self.pageMode].upDescParent)
            starDesc.transform:Reset()
            local x = 8
            local y = -60 * (i-1) - 13.5
            UnityUtils.SetAnchoredPosition(starDesc.transform, x, y)

            local icon = starDesc.transform:Find("icon").gameObject
            local titleBg = starDesc.transform:Find("title").gameObject
            local title = starDesc.transform:Find("title/text"):GetComponent(Text)
            if type == GDefine.UnitType.magicCard then -- 魔法卡不显示星级
                icon:SetActive(false)
                titleBg:SetActive(false)
            else
                title.text = TI18N(v[1].."星")
            end
            local desc = starDesc.transform:Find("desc"):GetComponent(Text)
            desc.text = TI18N(descData[v[2]].desc)
            -- local btn = star.transform:Find("more_msg"):GetComponent(Button)
            table.insert(self.starDescList, starDesc)
        end
        local starConHeight = #self.starDescList * 60 +13.5
        UnityUtils.SetAnchoredPosition(self.cacheObj[self.pageMode].upDescSplitLine, 12.5, -starConHeight)
        for i, v in ipairs(levDescs) do
            local levDesc = GameObject.Instantiate(self.cacheObj[self.pageMode].upDescLevItem)
            levDesc.transform:SetParent(self.cacheObj[self.pageMode].upDescParent)
            levDesc.transform:Reset()
            local x = 8
            local y = -60 * (i-1) - starConHeight -8
            UnityUtils.SetAnchoredPosition(levDesc.transform, x, y)

            local icon = levDesc.transform:Find("icon").gameObject
            local titleBg = levDesc.transform:Find("title").gameObject
            local title = levDesc.transform:Find("title/text"):GetComponent(Text)
            title.text = TI18N(v[1].."级")
            if self.data and self.data.level >= v[1] then
                self:SetSprite(levDesc:GetComponent(Image),UITex("backpack/backpack_35"))
            else
                self:SetSprite(levDesc:GetComponent(Image),UITex("backpack/backpack_34"))
            end
            local desc = levDesc.transform:Find("desc"):GetComponent(Text)
            desc.text = TI18N(descData[v[2]].desc)
            -- local btn = star.transform:Find("more_msg"):GetComponent(Button)
            table.insert(self.levDescList, levDesc)
        end
        local levConHeight = #self.levDescList * 60 +16.5
        UnityUtils.SetSizeDelata(self.cacheObj[self.pageMode].upDescParent,573,starConHeight+levConHeight)
        self.cacheObj[self.pageMode].upDescStarItem:SetActive(false)
        self.cacheObj[self.pageMode].upDescLevItem:SetActive(false)
    end
end

function BattleUnitDetailsScrollPanel:SetBiography()
    self.cacheObj[self.pageMode].biography.text = TI18N(self.unitCfg.biography)
end

function BattleUnitDetailsScrollPanel:ShowSkillTips(count,index,cfg)
    self.cacheObj[self.enum.PageMode.twoPageMode].skillName.text = TI18N(cfg.skillCfg.name)
    self.cacheObj[self.enum.PageMode.twoPageMode].skillDesc.text = TI18N(cfg.skillLevCfg.skill_desc) --TODO 技能等级表-skill_desc
    self.cacheObj[self.enum.PageMode.twoPageMode].skillUnlockCond.text = TI18N("解锁条件") --TODO 设置解锁条件
    UnityUtils.SetAnchoredPosition(self.cacheObj[self.enum.PageMode.twoPageMode].skillTipsMain,self.enum.SkillTipsX[count][index],95.5)
    UnityUtils.SetAnchoredPosition(self.cacheObj[self.enum.PageMode.twoPageMode].skillTipsHorn,self.enum.SkillIconX[count][index],53)
    self.cacheObj[self.enum.PageMode.twoPageMode].skillTips:SetActive(true)
end

function BattleUnitDetailsScrollPanel:HideSkillTips()
    self.cacheObj[self.enum.PageMode.twoPageMode].skillTips:SetActive(false)
end

function BattleUnitDetailsScrollPanel:ScrollViewDown(pointerData)
    self.clickPosX = pointerData.position.x
    self.clickPosY = pointerData.position.y
    self.clickTime = os.time()

    if pointerData.pointerId < -1 or self.pointerId then
        return
    end

    self.pointerId = pointerData.pointerId
    self.moveListenId = TouchManager.Instance:AddListen(TouchDefine.TouchEvent.move,self:ToFunc( "ScrollViewDrag" ),self.pointerId)
    self.cancelListenId = TouchManager.Instance:AddListen(TouchDefine.TouchEvent.cancel,self:ToFunc( "ScrollViewCancel" ),self.pointerId)
end

function BattleUnitDetailsScrollPanel:ScrollViewDrag(touchData)
    local contentPosX = self.scrollContent.anchoredPosition.x
    local width = self.scrollContent.sizeDelta.x
    local ratio = -1 * contentPosX / (width * (self.pageCount-1) / self.pageCount)
    self:SetScrollbar(ratio)
end

function BattleUnitDetailsScrollPanel:ScrollViewCancel(touchData)
    self:RemoveListen()
    if self.pageMode == self.enum.PageMode.threePageMode and self.page == 2 and math.abs(touchData.pos.y - self.clickPosY) > 100 then
        return
    end
    local contentPosX = self.scrollContent.anchoredPosition.x
    local width = self.scrollContent.sizeDelta.x
    local threshold = -1 * width / self.pageCount / 2
    local to = self.page
    if os.time() - self.clickTime >= 1 then
        if contentPosX >= threshold then
            to = to - 1
        else
            to = to + 1
        end
    else
        if math.abs(touchData.pos.x - self.clickPosX) > 100 then
            if touchData.pos.x < self.clickPosX then
                to = to + 1
            else
                to = to - 1
            end
        end
    end
    if to < 1 then
        to = 1
    elseif to > self.pageCount then
        to = self.pageCount
    end
    self:TurnPage(to)
end

function BattleUnitDetailsScrollPanel:SetScrollbar(ratio)
    local width = self.cacheObj[self.pageMode].scrollbar.sizeDelta.x
    self.ratio = ratio
    UnityUtils.SetAnchoredPosition(self.cacheObj[self.pageMode].handle, ratio * width, 0)
end

function BattleUnitDetailsScrollPanel:TurnPage(page)
    self.page = page
    local toX = 0
    local toVal = 0
    if page == 1 then
        toX = 0
        toVal = 0
    elseif page == self.pageCount then
        toX = -573 * (self.pageCount - 1)
        toVal = 1
    else
        toX = -573
        toVal = 0.5
    end
    self:ClearAnim()

    self.anim1 = MoveLocalXAnim.Create(self.scrollContent, {path = "", toX = toX, time = 0.2})
    self.anim1:Play()
    self.anim2 = ToFloatValueAnim.Create(nil, {fromValue = self.ratio, toValue = toVal, time = 0.2})
    self.anim2:SetValueCb(function (v)
        self:SetScrollbar(v)
    end)
    self.anim2:Play()
end

function BattleUnitDetailsScrollPanel:CancelOperate()
    self:RemoveListen()
    self:TurnPage(self.page)
end

function BattleUnitDetailsScrollPanel:RemoveListen()
    self.pointerId = nil
    if self.moveListenId then
        TouchManager.Instance:RemoveListen(self.moveListenId)
        self.moveListenId = nil
    end
    if self.cancelListenId then
        TouchManager.Instance:RemoveListen(self.cancelListenId)
        self.cancelListenId = nil
    end
end

function BattleUnitDetailsScrollPanel:ClearAnim()
    if self.anim1 then
        self.anim1:Destroy()
        self.anim1 = nil
    end
    if self.anim2 then
        self.anim2:Destroy()
        self.anim2 = nil
    end
end

function BattleUnitDetailsScrollPanel:ClearUpDesc()
    if self.pageMode == self.enum.PageMode.onePageMode then
        return
    end
    for k, v in pairs(self.starDescList) do
        GameObject.Destroy(v)
    end
    self.starDescList = {}
    for k, v in pairs(self.levDescList) do
        GameObject.Destroy(v)
    end
    self.levDescList= {}
end

function BattleUnitDetailsScrollPanel:ResetScroll()
    if self.pageMode == self.enum.PageMode.onePageMode then
        return
    end
    UnityUtils.SetAnchoredPosition(self.scrollContent, 0, 0)
    if self.pageMode == self.enum.PageMode.threePageMode then
        UnityUtils.SetAnchoredPosition(self.cacheObj[self.pageMode].upDescParent, 0, 0)
    end
    self.page = 1
    self:SetScrollbar(0)
end