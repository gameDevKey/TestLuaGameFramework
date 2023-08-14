SummonUnitPanel = BaseClass("SummonUnitPanel",ExtendView)

function SummonUnitPanel:__Init()
    local attrOrderCfg = Config.ConstData.data_const_info["unit_attr_name_order"].val
    self.attrOrder = {}
    for k, v in pairs(attrOrderCfg) do
        self.attrOrder[v[1]] = v[2]
    end

    self.getAttrInfo = {
        ["数目"] = {fn="GetUnitNum"},
        ["目标"] = {fn="GetFollowWalkType"},
        ["生命"] = {fn="GetMaxHp"},
        ["攻击"] = {fn="GetAtk"},
        ["射程"] = {fn="GetAtkRadius"},
        ["攻速"] = {fn="GetAtkSpeed"},
        ["秒伤"] = {fn="GetDPS"},
        ["速度"] = {fn="GetSpeed"},
    }

    self.attrs = {}
end

function SummonUnitPanel:__Delete()
    for k, v in pairs(self.attrs) do
        GameObject.Destroy(v.gameObject)
    end
    self.attrs = {}
end

function SummonUnitPanel:__CacheObject()
    self.transParent = self:Find(nil)
    self.trans = self:Find("summon_unit")
    self.unitName = self:Find("bg/name",Text,self.trans)
    self.attrParent = self:Find("bg/attr_con",nil,self.trans)
    self.attrItem = self:Find("bg/attr_con/attr_item",nil,self.trans).gameObject
    self.horn = self:Find("horn",nil,self.trans)

    self.richTextParent = self:Find("main/panel_bg/attr_panel/star_desc_con/star_desc_1/rich_text")
end

function SummonUnitPanel:__Create()
    local column_num = 2
    for i = 1, 8 do
        local attr = GameObject.Instantiate(self.attrItem)
        attr.transform:SetParent(self.attrParent)
        attr.transform:Reset()
        local x = i % column_num
        x = x == 0 and 53.5 or -91.5
        local y = -35 * math.floor((i-1) /column_num)
        UnityUtils.SetAnchoredPosition(attr.transform, x, y)
        attr:SetActive(true)
        local item = {}
        item.gameObject = attr
        item.title = attr.transform:Find("title").gameObject:GetComponent(Text)
        item.num = attr.transform:Find("num").gameObject:GetComponent(Text)
        table.insert(self.attrs,item)
    end
    self.attrItem:SetActive(false)
end

function SummonUnitPanel:OnActive(args,richTextTrans)
    local summonUnitId = tonumber(args.unitId)
    local masterUnitId = Config.TipsTextData.data_summon_unit_info[summonUnitId].master_unit_id
    self.unitCfg = Config.UnitData.data_unit_info[tonumber(summonUnitId)]
    local masterData = mod.CollectionProxy:GetDataById(tonumber(masterUnitId))
    local key = args.unitId.."_"..1
    if masterData and masterData.level then
        key = args.unitId.."_"..masterData.level
    end
    self.levCfg = Config.UnitData.data_unit_lev_info[key]

    self:SetAttr()

    self:SetPos(richTextTrans)


    self.trans.gameObject:SetActive(true)
end

function SummonUnitPanel:OnInactive()
    local hornLocalPos = self.horn.localPosition
    UnityUtils.SetLocalPosition(self.horn, 0, hornLocalPos.y, hornLocalPos.z)
    self.trans.gameObject:SetActive(false)
end

function SummonUnitPanel:SetPos(richTextTrans)
    self.trans:SetParent(richTextTrans)
    local transLocalPos = self.trans.localPosition
    UnityUtils.SetLocalPosition(self.trans, transLocalPos.x, 25, transLocalPos.z)

    local richTextPos = richTextTrans.position

    local transPos = self.trans.position
    UnityUtils.SetPosition(self.trans, richTextPos.x, transPos.y, transPos.z)

    self.trans:SetParent(self.transParent)
    local localPos = self.trans.localPosition
    -- 限制区域 -160 < x < 160
    local diff = 0
    if localPos.x > 160 then
        diff = localPos.x - 160
        UnityUtils.SetLocalPosition(self.trans, 160, localPos.y, localPos.z)
    elseif localPos.x < -160 then
        diff = localPos.x + 160
        UnityUtils.SetLocalPosition(self.trans, -160, localPos.y, localPos.z)
    end
    local hornLocalPos = self.horn.localPosition
    UnityUtils.SetLocalPosition(self.horn, hornLocalPos.x + diff, hornLocalPos.y, hornLocalPos.z)
end

function SummonUnitPanel:SetAttr()
    for i = 1, #self.attrOrder do
        local title = TI18N(self.attrOrder[i])
        local getAttrInfo = self.getAttrInfo[title]
        local value = self[getAttrInfo.fn](self)
        if value~=nil then
            self.attrs[i].title.text = title
            self.attrs[i].num.text = value
            self.attrs[i].gameObject:SetActive(true)
        end
    end
end

function SummonUnitPanel:GetFollowWalkType()
    local followWalkType = GDefine.FollowWalkTypeToDesc[self.unitCfg.follow_walk_type]
    return followWalkType
end

function SummonUnitPanel:GetUnitNum()
    local unitNum = self.unitCfg.unit_num
    return unitNum
end

function SummonUnitPanel:GetMaxHp()
    local unitNum = self.unitCfg.unit_num
    return unitNum
end

function SummonUnitPanel:GetMaxHp()
    local maxHp = 0
    maxHp = self:GetAttrValByAttrId(GDefine.Attr.max_hp)
    return maxHp
end

function SummonUnitPanel:GetAtk()
    local atk = 0
    atk = self:GetAttrValByAttrId(GDefine.Attr.atk)
    return atk
end

function SummonUnitPanel:GetAtkRadius()
    local atkRadius = 0
    atkRadius = self.unitCfg.atk_radius_show
    return atkRadius
end

function SummonUnitPanel:GetAtkSpeed()
    local val= self:GetAttrValByAttrId(GDefine.Attr.atk_speed)
    local atkSpeed = self.unitCfg.atk_time / val
    return atkSpeed
end

function SummonUnitPanel:GetDPS()
    local atk = self:GetAtk()
    local atkSpeed = self:GetAtkSpeed()
    local DPS = string.format("%.1f",atk/atkSpeed)
    return DPS
end

function SummonUnitPanel:GetSpeed()
    local speed = 0
    speed = self.unitCfg.move_speed_show
    return speed
end

function SummonUnitPanel:GetAttrValByAttrId(id)
    local curVal = 0
    local attrList = self.levCfg.attr_list
    for k, v in pairs(attrList) do
        local attrId = 0
        local attrVal = 0
        attrId = GDefine.AttrNameToId[v[1]]
        attrVal = v[2]
        if attrId == id then
            curVal = attrVal
            break
        end
    end
    return curVal
end