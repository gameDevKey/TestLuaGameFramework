CustomRemindItem = BaseClass("CustomRemindItem", RemindBase)

function CustomRemindItem:__Init(obj)
    self:SetViewType(UIDefine.ViewType.item)
    self:SetEnableName(false)
    self:SetObject(obj)
end

function CustomRemindItem:__Delete()
    self.gameObject = nil
end

function CustomRemindItem:__CacheObject()

end

function CustomRemindItem:__BindListener()

end

function CustomRemindItem:__Create()

end