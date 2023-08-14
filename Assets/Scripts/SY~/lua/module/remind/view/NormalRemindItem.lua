NormalRemindItem = BaseClass("NormalRemindItem", RemindBase)

function NormalRemindItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
    self:SetAsset("ui/prefab/common/normal_remind_item.prefab")
end

function NormalRemindItem:__CacheObject()

end

function NormalRemindItem:__BindListener()

end

function NormalRemindItem:__Create()

end