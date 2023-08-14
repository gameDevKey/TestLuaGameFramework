TerminologyPanel = BaseClass("TerminologyPanel",ExtendView)

function TerminologyPanel:__Init()

end

function TerminologyPanel:__Delete()

end

function TerminologyPanel:__CacheObject()
    self.transParent = self:Find(nil)
    self.trans = self:Find("terminology")
    self.title = self:Find("bg/title",Text,self.trans)
    self.desc = self:Find("bg/desc",Text,self.trans)
    self.horn = self:Find("horn",nil,self.trans)
end

function TerminologyPanel:__Create()
    self.originWidth = self.trans.rect.width
    self.originHeight = self.trans.rect.height
end

function TerminologyPanel:OnActive(args,richTextTrans)
    local tipsText = Config.TipsTextData.data_terminology_info[tonumber(args.textId)]
    self.title.text = TI18N(tipsText.title)
    self.desc.text = TI18N(tipsText.content)

    self:SetSizeAndPos(richTextTrans)

    self.trans.gameObject:SetActive(true)
end

function TerminologyPanel:OnInactive()
    self.trans.gameObject:SetActive(false)
    self.title.text = ""
    self.desc.text = ""
    UnityUtils.SetSizeDelata(self.trans, self.originWidth, self.originHeight)
end

function TerminologyPanel:SetSizeAndPos(richTextTrans)
    local toHeight = self.originHeight + self.desc.preferredHeight
    UnityUtils.SetSizeDelata(self.trans, self.originWidth, toHeight)

    self.trans:SetParent(richTextTrans)
    local transLocalPos = self.trans.localPosition
    UnityUtils.SetLocalPosition(self.trans, transLocalPos.x, 25, transLocalPos.z)

    local richTextPos = richTextTrans.position
    local hornPos = self.horn.position
    UnityUtils.SetPosition(self.horn, richTextPos.x, hornPos.y, hornPos.z)
    self.trans:SetParent(self.transParent)
end