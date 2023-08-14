BattlePveAttrView = BaseClass("BattlePveAttrView",ExtendView)

BattlePveAttrView.Event = EventEnum.New(
    "RefreshAttr"
)

function BattlePveAttrView:__Init()
    self.attrItemObjects = {}

    self.attrOrder = {
        [1] = {fn="GetAtk", iconPath = UITex("pve/29") },
        [2] = {fn="GetAtkSpeed", iconPath = UITex("pve/28") },
        [3] = {fn="GetRange", iconPath = UITex("pve/24") },
    }
    self.commanderEntity = nil
    self.baseRange = 0
end

function BattlePveAttrView:__Delete()
    self.commanderEntity = nil
end

function BattlePveAttrView:__CacheObject()
    for i = 1, 3 do self:GetAttrItemObject(i) end
end

function BattlePveAttrView:GetAttrItemObject(index)
    local object = {}
    local item = self:Find("main/operate_con/attr_con/attr_item_"..tostring(index)).gameObject
    object.gameObject = item
    object.transform = item.transform

    object.icon = item.transform:Find("icon").gameObject:GetComponent(Image)
    object.title = item.transform:Find("title").gameObject:GetComponent(Text)
    object.num = item.transform:Find("num").gameObject:GetComponent(Text)

    table.insert(self.attrItemObjects,object)
end

function BattlePveAttrView:__BindEvent()
    self:BindEvent(BattleFacade.Event.InitComplete)
    self:BindEvent(BattlePveAttrView.Event.RefreshAttr)
end

function BattlePveAttrView:__Create()
end

function BattlePveAttrView:__Show()
end

function BattlePveAttrView:__Hide()
    self.commanderEntity = nil
end

function BattlePveAttrView:InitComplete()
    local roleUid = RunWorld.BattleDataSystem.roleUid
    self.commanderEntity = RunWorld.EntitySystem:GetRoleCommander(roleUid)

    local baseConf = RunWorld.BattleCommanderSystem:GetCommanderInfo(roleUid).baseConf
    self.atkTime = baseConf.atk_time
    self.baseRange = baseConf.atk_radius_show

    self:RefreshAttr()
end

function BattlePveAttrView:RefreshAttr()
    for i = 1, 3 do
        self:SetAttrItem(i)
    end
end

function BattlePveAttrView:SetAttrItem(index)
    local path = self.attrOrder[index].iconPath
    local title,val = self[self.attrOrder[index].fn](self)
    self:SetSprite(self.attrItemObjects[index].icon,path)
    self.attrItemObjects[index].title.text = title
    self.attrItemObjects[index].num.text = val
end

function BattlePveAttrView:GetAtk()
    local title = TI18N(GDefine.AttrIdToDesc[GDefine.Attr.atk])
    local val = self:GetCurAttr(GDefine.Attr.atk)
    return title,val
end

function BattlePveAttrView:GetAtkSpeed()
    local title = TI18N(GDefine.AttrIdToDesc[GDefine.Attr.atk_speed])
    local val = self:GetCurAttr(GDefine.Attr.atk_speed)

    local conf = Config.CommanderData.data_const_info["atk_speed_show"]
    val = string.format("%.2f秒",conf.val[1] / (val * 0.0001))

    return title,val
end

function BattlePveAttrView:GetRange()
    local title = TI18N("射程")
    local val = self:GetCurAttr(GDefine.Attr.atk_distance)

    local conf = Config.CommanderData.data_const_info["atk_distance_show"]
    val = string.format("%.2f",(conf.val[1] + val - conf.val[2]) / conf.val[3] / conf.val[4] + conf.val[5])

    return title,val
end

function BattlePveAttrView:GetCurAttr(attrType)
    local val = self.commanderEntity.AttrComponent:GetValue(attrType)
    return val
end