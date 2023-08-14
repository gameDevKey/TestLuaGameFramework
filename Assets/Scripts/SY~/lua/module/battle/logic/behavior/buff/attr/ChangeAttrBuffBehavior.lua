ChangeAttrBuffBehavior = BaseClass("ChangeAttrBuffBehavior",BuffBehavior)

function ChangeAttrBuffBehavior:__Init()
    self.changeAttrs = {}
end

function ChangeAttrBuffBehavior:__Delete()

end

function ChangeAttrBuffBehavior:OnExecute()
    self:ChangeAttr()
    return true
end

function ChangeAttrBuffBehavior:OnOverlay()
    self:ChangeAttr()
end

function ChangeAttrBuffBehavior:ChangeAttr()
    for i,v in ipairs(self.actionParam.attrs) do
        local attrType = BattleUtils.GetConfAttr(v.attr)
        local fromEntityUid = self.buff.fromEntityUid
        local value = self.world.PluginSystem.CalcAttr:CalcAttr(self.entity.uid,fromEntityUid,v.mode,attrType,v)
        if v.linkStar and v.linkStar == 1 and self.entity.ObjectDataComponent.objectData.star then
            value = self.entity.ObjectDataComponent.objectData.star * value
        end
        self.entity.AttrComponent:AddValue(attrType,value)

        if not self.changeAttrs[i] then
            self.changeAttrs[i] = {attrType = attrType,value = value}
        else
            self.changeAttrs[i].value = self.changeAttrs[i].value + value
        end
    end
end


function ChangeAttrBuffBehavior:OnDestroy()
    for i,v in ipairs(self.changeAttrs) do
        self.entity.AttrComponent:AddValue(v.attrType,-v.value)
    end
    self.changeAttrs = {}
end