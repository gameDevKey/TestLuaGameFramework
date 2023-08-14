RichTextTipsPanel = BaseClass("RichTextTipsPanel",BaseView)

function RichTextTipsPanel:__Init()
    self:SetAsset("ui/prefab/tips/rich_text_tips_panel.prefab", AssetType.Prefab)
end

function RichTextTipsPanel:__Delete()
end

function RichTextTipsPanel:__ExtendView()
    self.terminologyPanel = self:ExtendView(TerminologyPanel)
    self.summonUnitPanel = self:ExtendView(SummonUnitPanel)
end

function RichTextTipsPanel:__CacheObject()
    self.richTextTipsPanelCanvasGroup = self:Find(nil,CanvasGroup)
end

function RichTextTipsPanel:__BindListener()
    self:Find(nil,Button):SetClick(self:ToFunc("HideRichTextTips"))
end

function RichTextTipsPanel:ShowRichTextTips(logicElementType,args,richTextTrans)
    local flag = false
    if logicElementType == RichTextDefine.LogicElementType.terminology then
        self.terminologyPanel:OnActive(args,richTextTrans)
        flag = true
    elseif logicElementType == RichTextDefine.LogicElementType.summon_unit then
        self.summonUnitPanel:OnActive(args,richTextTrans)
        flag = true
    end

    if flag then
        self.richTextTipsPanelCanvasGroup.alpha = 1
        self.richTextTipsPanelCanvasGroup.interactable = true
        self.richTextTipsPanelCanvasGroup.blocksRaycasts = true
    else
        assert(false,string.format("未实现的点击富文本效果标签[%s]",logicElementType))
    end
end

function RichTextTipsPanel:HideRichTextTips()
    self.terminologyPanel:OnInactive()
    self.summonUnitPanel:OnInactive()

    self.richTextTipsPanelCanvasGroup.alpha = 0
    self.richTextTipsPanelCanvasGroup.interactable = false
    self.richTextTipsPanelCanvasGroup.blocksRaycasts = false
end