AttrComponent = Class("AttrComponent",ECSLComponent)

function AttrComponent:OnInit()
    self.dataWatcher = TableDataWatcher.New()
    self.dataWatcher:SetChangeFunc(self:ToFunc("OnAttrChange"))
    self.dataWatcher:SetCompareFunc(self:ToFunc("OnAttrCompare"))
end

function AttrComponent:OnDelete()
    self.dataWatcher:Delete()
end

function AttrComponent:SetAttr(attrType,value)
    self.dataWatcher:SetVal(attrType,value)
end

function AttrComponent:GetAttr(attrType)
    return self.dataWatcher:GetVal(attrType)
end

function AttrComponent:OnAttrChange(attrType,new,old)
    self.world.GameEventSystem:Broadcast(EventConfig.Type.AttrChange,{
        entityUid = self.entity:GetUid(),
        attrType = attrType,
        new = new,
        old = old,
    })
end

function AttrComponent:OnAttrCompare(attrType,new,old)
    return new == old
end

return AttrComponent