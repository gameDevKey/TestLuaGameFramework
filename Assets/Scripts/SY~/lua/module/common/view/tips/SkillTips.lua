SkillTips = BaseClass("SkillTips",BaseTips)

function SkillTips:__Init()
    self:SetAsset("ui/prefab/tips/skill_tips_panel.prefab", AssetType.Prefab)
end

function SkillTips:__Delete()
end

function SkillTips:__CacheObject()
    self.nameText =  self:Find("main/name",Text)
    self.skillIcon =  self:Find("main/icon",Image)
    self.descText =  self:Find("main/content/desc",Text)

    self.contentRectTrans = self:Find("main/content",RectTransform)
    self.mainRectTrans = self:Find("main",RectTransform)
end

function SkillTips:__Create()
    self:SetOrder()
end

function SkillTips:__BindListener()
end

function SkillTips:__Show()
    local baseConf = Config.SkillData.data_skill_base[self.data.skill_id]
    local levConf = Config.SkillData.data_skill_lev[self.data.skill_id .. "_" .. self.data.skill_level]

    self.nameText.text = baseConf.name
    self.descText.text = levConf.desc     --TODO 技能等级表-desc

    self:SetSprite(self.skillIcon,AssetPath.GetSkillIcon(baseConf.id))

    UIUtils.ForceRebuildLayoutImmediate(self.contentRectTrans.gameObject)
    self.mainRectTrans:SetSizeDelata(385,207 + self.contentRectTrans.sizeDelta.y)

    --
    self:AdaptionPos(self.mainRectTrans)
end