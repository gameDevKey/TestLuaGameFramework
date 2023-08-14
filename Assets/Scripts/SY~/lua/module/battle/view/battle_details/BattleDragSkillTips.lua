BattleDragSkillTips = BaseClass("BattleDragSkillTips",BaseView)

function BattleDragSkillTips:__Init()
    self:SetAsset("ui/prefab/battle_details/battle_drag_skill_tips.prefab", AssetType.Prefab)
end

function BattleDragSkillTips:__Delete()
    if self.richTextTipsPanel then
        self.richTextTipsPanel:Destroy()
    end
end

function BattleDragSkillTips:__CacheObject()
    self.canvasGroup = self:Find("",CanvasGroup)
    self.skillIcon = self:Find("main/icon",Image)
    self.skillName = self:Find("main/name",Text)
    self.richTextParent = self:Find("main/desc")
end

function BattleDragSkillTips:__Create()
    self.name = self.transform.name
    self:SetOrder()

    if not self.richTextTipsPanel then
        self.richTextTipsPanel = RichTextTipsPanel.New()
        self.richTextTipsPanel:SetParent(self:Find("main"))
    end
    self.richTextTipsPanel:Show()
end

function BattleDragSkillTips:__BindListener()
    self:Find("mask_bg", Button):SetClick( self:ToFunc("OnCloseClick") )
end

function BattleDragSkillTips:__BindEvent()
end

function BattleDragSkillTips:__Hide()
    self.canvasGroup.alpha = 0
    self.canvasGroup.interactable = false
    self.canvasGroup.blocksRaycasts = false
end

function BattleDragSkillTips:__Show()
    local path = AssetPath.GetBattleCommanderSkillIcon(self.baseConf.icon)  -- 设置技能图标
    self:SetSprite(self.skillIcon,path)
    self.skillName.text = self.baseConf.name
    local descId = tonumber(self.baseConf.skill_desc)
    local content = TI18N(Config.UnitData.data_unit_up_desc[descId].desc)
    self:CreateRichText(content)

    self.canvasGroup.alpha = 1
    self.canvasGroup.interactable = true
    self.canvasGroup.blocksRaycasts = true
end

function BattleDragSkillTips:SetData(data)
    self.data = data
    self.baseConf = RunWorld.BattleConfSystem:SkillData_data_skill_base(self.data.skillId)
end

function BattleDragSkillTips:CreateRichText(content)
    local richTextInfo = RichTextInfo.New()
    richTextInfo.content = TI18N(content)
    richTextInfo.lineSpacing = 1.2
    richTextInfo.viewWidth = 276
    richTextInfo.minX = 0
    richTextInfo.minY = 1
    richTextInfo.maxX = 0
    richTextInfo.maxY = 1
    richTextInfo.pivotX = 0
    richTextInfo.pivotY = 1
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

    if self.richTextItem then
        self.richTextItem:Delete()
        self.richTextItem = nil
    end
    self.richTextItem = RichText.Create(richTextInfo)
end

function BattleDragSkillTips:ShowRichTextTips(logicElementType,args,richTextTrans)
    self.richTextTipsPanel:ShowRichTextTips(logicElementType,args,richTextTrans)
end

function BattleDragSkillTips:HideRichTextTips()
    self.richTextTipsPanel:HideRichTextTips()
end

function BattleDragSkillTips:OnCloseClick()
    self:Hide()
end