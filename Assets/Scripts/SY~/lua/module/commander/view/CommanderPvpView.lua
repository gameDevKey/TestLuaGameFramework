CommanderPvpView = BaseClass("CommanderPvpView",ExtendView)

CommanderPvpView.Event = EventEnum.New(
)

function CommanderPvpView:__Init()
end

function CommanderPvpView:__Delete()
end

function CommanderPvpView:__CacheObject()
    self.commanderLevText = self:Find("main/pvp/base_info_node/lev",Text)
    self.commanderExpText = self:Find("main/pvp/base_info_node/exp",Text)
    self.expProgress = self:Find("main/pvp/base_info_node/exp_progress",Image)

    self.battlePowerText = self:Find("main/pvp/base_info_node/battle_power",Text)

    self.hpAttrText = self:Find("main/pvp/base_info_node/attr_node/hp",Text)
    self.atkAttrText = self:Find("main/pvp/base_info_node/attr_node/atk",Text)
    self.atkSpeedAttrText = self:Find("main/pvp/base_info_node/attr_node/atk_speed",Text)
    self.atkRangeAttrText = self:Find("main/pvp/base_info_node/attr_node/atk_range",Text)



    self.skillObjs = {}
    for i = 1, 3 do self:GetSkillObj(i) end

    self.attrTipsObjs = {}
    for i = 1, 10 do self:GetAttrTipsObj(i) end
    self.attrTipsNode = self:Find("main/pvp/attr_tips").gameObject
    self.attrTipsListRectTrans = self:Find("main/pvp/attr_tips/attr_list",RectTransform)
    self.attrTipsRectTrans = self:Find("main/pvp/attr_tips",RectTransform)
end

function CommanderPvpView:GetSkillObj(index)
    local object = {}
    local item = self:Find("main/pvp/base_info_node/skill_node/"..tostring(index)).gameObject
    object.gameObject = item
    object.transform = item.transform

    object.btn = item.transform:Find("btn").gameObject:GetComponent(Button)
    object.icon = item.transform:Find("icon").gameObject:GetComponent(CircleImage)
    object.lock = item.transform:Find("lock").gameObject

    self.skillObjs[index] = object
end

function CommanderPvpView:GetAttrTipsObj(index)
    local object = {}
    local item = self:Find("main/pvp/attr_tips/attr_list/"..tostring(index)).gameObject
    object.gameObject = item

    object.attr = {}

    local attrObj = {}
    attrObj.nameText = item.transform:Find("attr_name_1").gameObject:GetComponent(Text)
    attrObj.valText = item.transform:Find("attr_val_1").gameObject:GetComponent(Text)
    table.insert(object.attr,attrObj)

    local attrObj = {}
    attrObj.nameText = item.transform:Find("attr_name_2").gameObject:GetComponent(Text)
    attrObj.valText = item.transform:Find("attr_val_2").gameObject:GetComponent(Text)
    table.insert(object.attr,attrObj)

    self.attrTipsObjs[index] = object
end

function CommanderPvpView:__BindListener()
    self:Find("main/pvp/base_info_node/attr_tips_btn",Button):SetClick(self:ToFunc("AttrTipsClick"))
    self:Find("main/pvp/attr_tips/close_btn",Button):SetClick(self:ToFunc("AttrTipsCloseClick"))
end

function CommanderPvpView:__BindEvent()
    self:BindEvent(CommanderFacade.Event.RefreshCommanderAttr)
end

function CommanderPvpView:__Create()

end

function CommanderPvpView:__Show()
    self:RefreshCommanderAttr()
    self:RefreshSkill()
end

--刷新统帅属性
function CommanderPvpView:RefreshCommanderAttr()
    local lev = mod.CommanderProxy.commanderInfos.level
    local upLevConf = Config.CommanderData.data_up_lev_info[lev]
    self.commanderLevText.text = lev
    self.commanderExpText.text = mod.CommanderProxy.commanderInfos.exp .. "/" .. upLevConf.up_lv_exp
    self.expProgress.fillAmount = mod.CommanderProxy.commanderInfos.exp / upLevConf.up_lv_exp

    self.battlePowerText.text = mod.CommanderProxy:GetModeAttr(CommanderDefine.Mode.pvp,GDefine.Attr.battle_power)

    self.hpAttrText.text = mod.CommanderProxy:GetModeAttr(CommanderDefine.Mode.pvp,GDefine.Attr.max_hp) or 0
    self.atkAttrText.text = mod.CommanderProxy:GetModeAttr(CommanderDefine.Mode.pvp,GDefine.Attr.atk)

    local conf = Config.CommanderData.data_const_info["atk_speed_show"]
    local atkSpeed = mod.CommanderProxy:GetModeAttr(CommanderDefine.Mode.pvp,GDefine.Attr.atk_speed) or 0
    atkSpeed = conf.val[1] / (atkSpeed * 0.0001)
    self.atkSpeedAttrText.text = string.format("%.2f秒",atkSpeed)

    -- local conf = Config.CommanderData.data_const_info["atk_distance_show"]
    local atkDistance = mod.CommanderProxy:GetModeAttr(CommanderDefine.Mode.pvp,GDefine.Attr.atk_distance) or 0
    -- atkDistance = (conf.val[1] + atkDistance - conf.val[2]) / conf.val[3] / conf.val[4] + conf.val[5]
    self.atkRangeAttrText.text = CommanderUtils.FormatAttrShow(GDefine.Attr.atk_distance,atkDistance,mod.CommanderProxy:GetCommanderUnitId())
end

function CommanderPvpView:RefreshSkill()
    local modeData = mod.CommanderProxy:GetModeData(CommanderDefine.Mode.pvp)
    for i,v in ipairs(modeData.skill_list) do
        local objs = self.skillObjs[i]
        local conf = Config.SkillData.data_skill_base[v.skill_id]
        self:SetSprite(objs.icon,AssetPath.GetSkillIcon(conf.id))
        objs.btn:SetClick(self:ToFunc("SkilllClick"),i,v.skill_id,v.skill_level)
    end
end

function CommanderPvpView:AttrTipsClick()
    self:ActiveTips(true)
end

function CommanderPvpView:AttrTipsCloseClick()
    self:ActiveTips(false)
end

function CommanderPvpView:ActiveTips(flag)
    self.attrTipsNode:SetActive(flag)
    if not flag then
        return
    end 

    local attrs = mod.CommanderProxy:GetModeAttrList(CommanderDefine.Mode.pvp)
    local attrNum = #attrs

    local a = attrNum % 2
    local num = (attrNum - a) / 2
    if a > 0 then num =  num + 1 end

    local index = 1
    for i = 1, num do
        local attrInfo = attrs[index]
        local attrConf = Config.AttrData.data_attr_info[attrInfo.attr_id]

        local objs = self.attrTipsObjs[i]
        objs.gameObject:SetActive(true)

        objs.attr[1].nameText.text = attrConf.name
        objs.attr[1].valText.text = CommanderUtils.FormatAttrShow(attrInfo.attr_id, attrInfo.attr_val,mod.CommanderProxy:GetCommanderUnitId())

        index = index + 1

        if not attrs[index] then
            objs.attr[2].nameText.gameObject:SetActive(false)
            objs.attr[2].valText.gameObject:SetActive(false)
        else
            objs.attr[2].nameText.gameObject:SetActive(true)
            objs.attr[2].valText.gameObject:SetActive(true)

            local attrInfo = attrs[index]
            local attrConf = Config.AttrData.data_attr_info[attrInfo.attr_id]

            objs.attr[2].nameText.text = attrConf.name
            objs.attr[2].valText.text = CommanderUtils.FormatAttrShow(attrInfo.attr_id, attrInfo.attr_val,mod.CommanderProxy:GetCommanderUnitId())

            index = index + 1
        end
    end

    for i = num + 1, #self.attrTipsObjs do
        self.attrTipsObjs[i].gameObject:SetActive(false)
    end

    Canvas.ForceUpdateCanvases()
    UIUtils.ForceRebuildLayoutImmediate(self.attrTipsListRectTrans.gameObject)
    self.attrTipsRectTrans:SetSizeDelata(333,130 + self.attrTipsListRectTrans.sizeDelta.y)
end

function CommanderPvpView:SkilllClick(index,skillId,skillLev)
    local data = {}
    data.skill_id = skillId
    data.skill_level = skillLev
    mod.TipsCtrl:OpenSkillTips(data,self.skillObjs[index].transform)
end