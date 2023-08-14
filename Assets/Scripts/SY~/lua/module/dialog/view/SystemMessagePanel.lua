SystemMessagePanel = BaseClass("SystemMessagePanel",BaseView)

SystemMessagePanel.Event = EventEnum.New(
	"ShowSystemMessage"
)

function SystemMessagePanel:__Init()
	self:SetAsset("ui/prefab/dialog/system_message_panel.prefab")
    --self.items = {}
    --self.itemAnim = nil
end

function SystemMessagePanel:__CacheObject()
    self.systemMessageItem = self:Find("template/system_message_item").gameObject
    self.itemParent = self:Find("items")

    self.showItemCanvasGroup = self:Find("items/show_item",CanvasGroup)
    self.showItemTrans = self:Find("items/show_item")
    self.showItemText = self:Find("items/show_item/text",Text)
end

function SystemMessagePanel:__Create()
    local anim1 = ToAlphaAnim.New(self.showItemCanvasGroup,1,0.1)
    local anim2 = DelayAnim.New(1)

    local anim3 = ToAlphaAnim.New(self.showItemCanvasGroup,0,0.3)
    local anim4 = MoveAnchorYAnim.New(self.showItemTrans,50,0.3)
    local anim5 = ParallelAnim.New({anim3,anim4})

    self.itemAnim = SequenceAnim.New({anim1,anim2,anim5})
end


function SystemMessagePanel:__BindListener()
end

function SystemMessagePanel:__BindEvent()
    self:BindEvent(SystemMessagePanel.Event.ShowSystemMessage)
end

function SystemMessagePanel:ShowSystemMessage(msg)
    self.showItemText.text = msg
    self.showItemCanvasGroup.alpha = 0
    self.showItemTrans:SetAnchoredPosition(0,0)
    self.itemAnim:Clean()
    self.itemAnim:Play()
end