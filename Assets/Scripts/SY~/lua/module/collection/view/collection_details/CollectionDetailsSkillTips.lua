CollectionDetailsSkillTips = BaseClass("CollectionDetailsSkillTips",ExtendView)

function CollectionDetailsSkillTips:__Init()
    self.descRichText = {}
end

function CollectionDetailsSkillTips:__Delete()
    self:RemoveRichText()
end

function CollectionDetailsSkillTips:__CacheObject()
    self.trans = self:Find("skill_tips")
    self.mainTrans = self:Find("skill_tips/con/main_adaptation/main")
    self.skillName = self:Find("skill_tips/con/main_adaptation/main/base_con/name",Text)
    self.baseDesc = self:Find("skill_tips/con/main_adaptation/main/desc_con/base_desc")
    self.levDesc = self:Find("skill_tips/con/main_adaptation/main/desc_con/lev_desc")
    self.horn = self:Find("skill_tips/con/main_adaptation/main/horn_img")
end

function CollectionDetailsSkillTips:__Create()
    self.elementTemplate =
    {
        [RichTextDefine.Element.none_text] ={original = self:Find("rich_text_templete/normal_text")
            ,textComponent = self:Find("rich_text_templete/normal_text/text",Text)},
        [RichTextDefine.Element.rich_text] ={original = self:Find("rich_text_templete/normal_text")
            ,textComponent = self:Find("rich_text_templete/normal_text/text",Text)},
        [RichTextDefine.Element.click_text] ={ original = self:Find("rich_text_templete/click_text")
            ,textComponent = self:Find("rich_text_templete/click_text/text",Text)},
    }
    self:Find("skill_tips",Canvas).sortingOrder = self:GetOrder() + GDefine.EffectOrderAdd + 10
end

function CollectionDetailsSkillTips:__BindListener()
    self:Find("skill_tips/panel_bg",Button):SetClick(self:ToFunc("OnInactive"))
end

function CollectionDetailsSkillTips:SetData(skillData,itemTrans)
    self.skillBaseConf = skillData.baseConf
    self.skillName.text = self.skillBaseConf.name
    self.baseDescId = tonumber(self.skillBaseConf.skill_desc)
    self.levDescList = self:FormatLevDesc(self.skillBaseConf.skill_lev_desc)

    self:RemoveRichText()

    local baseDescContent = TI18N(Config.UnitData.data_unit_up_desc[self.baseDescId].desc)
    self:CreateRichText(baseDescContent,10,self.baseDesc)
    for i, content in ipairs(self.levDescList) do
        self:CreateRichText(content,15,self.levDesc)
    end

    self.horn:SetParent(itemTrans)
    UnityUtils.SetAnchoredPosition(self.horn,0,self.horn.anchoredPosition.y)
    self.horn:SetParent(self.mainTrans)
end

function CollectionDetailsSkillTips:FormatLevDesc(descInfos)
    local descContent = {}
    for i, descIdInfo in ipairs(descInfos) do
        local descId = tonumber(descIdInfo[2])
        local desc = TI18N(Config.UnitData.data_unit_up_desc[descId].desc)
        local content = string.format("Lv.%s %s",descIdInfo[1],desc)
        table.insert(descContent,content)
    end

    return descContent
end

function CollectionDetailsSkillTips:CreateRichText(content,lineSpacing,parent)
    local richTextInfo = RichTextInfo.New()
    richTextInfo.content = content
    richTextInfo.lineSpacing = 0
    richTextInfo.viewWidth = 480
    richTextInfo.elementTemplate = self.elementTemplate

    richTextInfo.parent = parent
    richTextInfo.onClick = self.MainView:ToFunc("ShowRichTextTips")

    local richText = RichText.Create(richTextInfo)
    table.insert(self.descRichText,richText)
end

function CollectionDetailsSkillTips:OnActive()
    self.trans.gameObject:SetActive(true)
end

function CollectionDetailsSkillTips:OnInactive()
    self.trans.gameObject:SetActive(false)
end

function CollectionDetailsSkillTips:RemoveRichText()
    for i, v in ipairs(self.descRichText) do
        v:Delete()
    end
    self.descRichText = {}
end