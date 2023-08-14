MarkRemindItem = BaseClass("MarkRemindItem", RemindBase)

function MarkRemindItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
    self:SetAsset("ui/prefab/common/mark_remind_item.prefab")
end

function MarkRemindItem:__CacheObject()

end

function MarkRemindItem:__BindListener()

end

function MarkRemindItem:__Create()

end