CommanderPveView = BaseClass("CommanderPveView",ExtendView)

CommanderPveView.Event = EventEnum.New(
    "RefreshTreasureChest",
    "PlayAutoOpenChest",
    "PlayFirstChestOpenAnim",
    "PlayChestCloseAnim",
    "RefreshTipsState"
)

function CommanderPveView:__Init()
    self.equipItems = {}
    self.curEquipQuality = nil
    self.chestUpRemind = nil

    self.battlePowerAnim = nil
    self.expProgressAnim = nil

    self.lastLev = nil
    self.lastBattlePower = nil

    self.isChestOpening = false
    self.isChestCloseing = false
end

function CommanderPveView:__Delete()
    EventManager.Instance:RemoveEvent(EventDefine.refresh_role_item,self:ToFunc("RefreshRoleItem"))

    for k,v in pairs(self.equipItems) do
        v.item:Destroy()
    end

    if self.chestUpRemind then
        self.chestUpRemind:Destroy()
        self.chestUpRemind = nil
    end

    if self.battlePowerAnim then
        self.battlePowerAnim:Destroy()
    end

    if self.expProgressAnim then
        self.expProgressAnim:Destroy()
    end

    if self.isChestOpening then
        mod.CommanderCtrl:HideViewChestOpen()
    end

    if self.isChestCloseing then
        mod.CommanderCtrl:HideViewChestClose()
    end
end

function CommanderPveView:__CacheObject()
    self.commanderLevText = self:Find("main/pve/base_info_node/lev",Text)
    self.commanderExpText = self:Find("main/pve/base_info_node/exp",Text)
    self.expProgress = self:Find("main/pve/base_info_node/exp_progress",Image)

    self.battlePowerText = self:Find("main/pve/base_info_node/battle_power",Text)

    self.hpAttrText = self:Find("main/pve/base_info_node/attr_node/hp",Text)
    self.atkAttrText = self:Find("main/pve/base_info_node/attr_node/atk",Text)
    self.atkSpeedAttrText = self:Find("main/pve/base_info_node/attr_node/atk_speed",Text)
    self.atkRangeAttrText = self:Find("main/pve/base_info_node/attr_node/atk_range",Text)


    self.chestLev = self:Find("main/pve/chest_info_node/treasure_chest_lev/lev",Text)
    self.chestNum = self:Find("main/pve/chest_info_node/treasure_chest_num",Text)

    self.equipItem = self:Find("template/equip_item").gameObject

    self.equipObjs = {}
    for k,v in pairs(GDefine.EquipPart) do self:GetEquipObj(v) end

    self.attrTipsObjs = {}
    for i = 1, 10 do self:GetAttrTipsObj(i) end
    self.attrTipsNode = self:Find("main/pve/attr_tips").gameObject
    self.attrTipsListRectTrans = self:Find("main/pve/attr_tips/attr_list",RectTransform)
    self.attrTipsRectTrans = self:Find("main/pve/attr_tips",RectTransform)

    self.chestOpenTips = self:Find("main/pve/chest_info_node/open_tips").gameObject
    self.chestGetTips = self:Find("main/pve/chest_info_node/get_tips").gameObject

    self.checkUpRemindParent = self:Find("main/pve/chest_info_node/treasure_chest_lev/remind_node")
end

function CommanderPveView:GetEquipObj(equipType)
    local object = {}
    local item = self:Find("main/pve/base_info_node/equip_node/"..tostring(equipType)).gameObject
    object.gameObject = item
    object.transform = item.transform

    object.btn = item.transform:Find("btn").gameObject:GetComponent(Button)
    object.equipParent = item.transform:Find("equip_node")

    self.equipObjs[equipType] = object
end

function CommanderPveView:GetAttrTipsObj(index)
    local object = {}
    local item = self:Find("main/pve/attr_tips/attr_list/"..tostring(index)).gameObject
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

function CommanderPveView:__BindListener()
    self:Find("main/pve/open_chest_btn",Button):SetClick(self:ToFunc("OpenTreasureChestClick"))
    self:Find("main/pve/chest_info_node/treasure_chest_lev",Button):SetClick(self:ToFunc("TreasureChestLevClick"))

    self:Find("main/pve/base_info_node/attr_tips_btn",Button):SetClick(self:ToFunc("AttrTipsClick"))
    self:Find("main/pve/attr_tips/close_btn",Button):SetClick(self:ToFunc("AttrTipsCloseClick"))

    for k,v in pairs(self.equipObjs) do
        v.btn:SetClick(self:ToFunc("EmptyEquilClick"))
    end

    self:Find("main/pve/chest_info_node/auto_setting_btn",Button):SetClick(self:ToFunc("AutoOpenChestClick"))
end

function CommanderPveView:__BindEvent()
    self:BindEvent(CommanderPveView.Event.RefreshTreasureChest)
    self:BindEvent(CommanderFacade.Event.RefreshCommanderAttr)
    self:BindEvent(CommanderPveView.Event.PlayAutoOpenChest)
    self:BindEvent(CommanderPveView.Event.PlayFirstChestOpenAnim)
    self:BindEvent(CommanderPveView.Event.PlayChestCloseAnim)
    self:BindEvent(CommanderPveView.Event.RefreshTipsState)
    
    EventManager.Instance:AddEvent(EventDefine.refresh_role_item,self:ToFunc("RefreshRoleItem"))
end

function CommanderPveView:__Create()
    self.effect = self:GetAsset("effect/9200000.prefab",self:Find("main/pve/chest_node"))
    self.effect.transform:Reset()
    self.chestAnim = self.effect:GetComponent(Animator)
    UIUtils.SetEffectSortingOrder(self.effect,ViewManager.Instance:GetMaxOrderLayer())
    self:Find("main/pve/chest_info_node",Canvas).sortingOrder = ViewManager.Instance:GetMaxOrderLayer()
    BaseUtils.ChangeLayers(self.effect,GDefine.Layer.ui)

    self.chestEquipIcon = self.effect.transform:Find("equip_node/9200000_equip_node/icon").gameObject:GetComponent(Image)
    local chestEquipIconCanvas = self.chestEquipIcon.gameObject:GetComponent(Canvas)
    chestEquipIconCanvas.sortingOrder = self:Find("main/pve/chest_info_node",Canvas).sortingOrder


    self.chestUpRemind = MarkRemindItem.New()
    self.chestUpRemind:SetParent(self.checkUpRemindParent)
    self.chestUpRemind:SetRemindId({{{RemindDefine.RemindId.commander_chest_intensify},{RemindDefine.RemindId.commander_chest_up_lev}}})
end

function CommanderPveView:__Show()
    -- mod.CommanderCtrl:RemoveChestChestOpen()
    -- mod.CommanderCtrl:RemoveChestCloseTimer()
    self:RefreshCommanderAttr()
    self:RefreshTreasureChest()
    self:RefreshCommanderAllEquip()
end

function CommanderPveView:FirstPlayChestAnim()
    if mod.TreasureChestProxy:ExistTempEquip() then
        self:PlayChestOpenAnim(true)
    else
        if mod.TreasureChestProxy:GetChestNum() <= 0 then
            self.chestAnim:Play(CommanderDefine.ChestQualityAnims.idle.normal_idle,-1,0)
        else
            self.chestAnim:Play(CommanderDefine.ChestQualityAnims.idle.can_open_idle,-1,0)
        end
    end
end

function CommanderPveView:RefreshRoleItem()
    self:RefreshCommanderAllEquip()
end

--刷新统帅属性
function CommanderPveView:RefreshCommanderAttr(isAnim)

    if isAnim and not self.battlePowerAnim then
        self.battlePowerAnim = NumScrollAnim.New(0,0.3,self.battlePowerText)
    end

    if isAnim and not self.expProgressAnim then
        self.expProgressAnim = FillAmountAnim.New(self.expProgress,0,0.3)
    end

    local lev = mod.CommanderProxy.commanderInfos.level
    local upLevConf = Config.CommanderData.data_up_lev_info[lev]
    self.commanderLevText.text = lev
    self.commanderExpText.text = mod.CommanderProxy.commanderInfos.exp .. "/" .. upLevConf.up_lv_exp

--self.expProgressAnim
    
    if isAnim then
        local animTime = BaseUtils.GetAnimatorClipTime(self.animator,"jindutiao")

        self.expProgressAnim:Clean()

        local toValue = nil
        if self.lastLev ~= lev then
            toValue = 1
            self.expProgressAnim:SetComplete(self:ToFunc("ExpProgressDone"))
        else
            toValue = mod.CommanderProxy.commanderInfos.exp / upLevConf.up_lv_exp
            self.expProgressAnim:SetComplete(nil)
        end
        self.expProgressAnim["time"] = animTime
        self.expProgressAnim["toValue"] = toValue
        self.expProgressAnim:Play()

        self:PlayAnim("jindutiao",1)
    else
        self.expProgress.fillAmount = mod.CommanderProxy.commanderInfos.exp / upLevConf.up_lv_exp
    end

    self.lastLev = lev

    local battlePower = mod.CommanderProxy:GetModeAttr(CommanderDefine.Mode.pve,GDefine.Attr.battle_power)
    if isAnim and battlePower ~= self.lastBattlePower then
        local animTime = BaseUtils.GetAnimatorClipTime(self.animator,"battle_power_up")
        self.battlePowerAnim:Clean()
        self.battlePowerAnim["time"] = animTime
        self.battlePowerAnim["toValue"] = battlePower
        self.battlePowerAnim:Play()
        self:PlayAnim("battle_power_up",0)
    else
        self.battlePowerText.text = battlePower
    end

    self.lastBattlePower = battlePower
    

    self.hpAttrText.text = mod.CommanderProxy:GetModeAttr(CommanderDefine.Mode.pve,GDefine.Attr.max_hp) or 0
    self.atkAttrText.text = mod.CommanderProxy:GetModeAttr(CommanderDefine.Mode.pve,GDefine.Attr.atk)

    local conf = Config.CommanderData.data_const_info["atk_speed_show"]
    local atkSpeed = mod.CommanderProxy:GetModeAttr(CommanderDefine.Mode.pve,GDefine.Attr.atk_speed) or 0
    atkSpeed = conf.val[1] / (atkSpeed * 0.0001)
    self.atkSpeedAttrText.text = string.format("%.2f秒",atkSpeed)

    -- local conf = Config.CommanderData.data_const_info["atk_distance_show"]
    local atkDistance = mod.CommanderProxy:GetModeAttr(CommanderDefine.Mode.pve,GDefine.Attr.atk_distance) or 0
    -- atkDistance = (conf.val[1] + atkDistance - conf.val[2]) / conf.val[3] / conf.val[4] + conf.val[5]
    self.atkRangeAttrText.text = CommanderUtils.FormatAttrShow(GDefine.Attr.atk_distance,atkDistance)
end

function CommanderPveView:ExpProgressDone()
    self.expProgress.fillAmount = 0
    self.expProgressAnim:SetComplete(nil)
    
    local lev = mod.CommanderProxy.commanderInfos.level
    local upLevConf = Config.CommanderData.data_up_lev_info[lev]
    local toValue = mod.CommanderProxy.commanderInfos.exp / upLevConf.up_lv_exp
    self.expProgressAnim["toValue"] = toValue
    self.expProgressAnim:Play()
end

function CommanderPveView:RefreshCommanderAllEquip()
    local equips = mod.RoleItemProxy:GetRoleItemType(GDefine.BagType.equip)
    if equips then
        for i,v in ipairs(equips) do
            local conf = Config.ItemData.data_item_info[v.item_id]
            local equipItem = self.equipItems[conf.equip_type]
            if not equipItem or equipItem.updateUid ~= v.update_uid then
                self:RefreshCommanderEquip(v)
            end
        end
    end
end

--刷新统帅装备
function CommanderPveView:RefreshCommanderEquip(data)
    local conf = Config.ItemData.data_item_info[data.item_id]
    local equipItem = self.equipItems[conf.equip_type]

    if not equipItem then
        local equipObj = self.equipObjs[conf.equip_type]
        equipItem = EquipItem.Create(self.equipItem)
        equipItem:SetParent(equipObj.equipParent)
        equipItem = {item = equipItem,updateUid = data.update_uid}
        self.equipItems[conf.equip_type] = equipItem
    end

    equipItem.item:Show()
    equipItem.item:SetData(data)
end


--刷新宝箱
function CommanderPveView:RefreshTreasureChest()
    self.chestLev.text = mod.TreasureChestProxy.treasureChestInfo.level
    self.chestNum.text = mod.TreasureChestProxy:GetChestNum()
    self:RefreshTipsState()
end

function CommanderPveView:RefreshTipsState()
    local chestNum = mod.TreasureChestProxy:GetChestNum()
    if mod.TreasureChestProxy:ExistTempEquip() 
        or (chestNum > 0 and mod.TreasureChestProxy.autoOpenFlag) then
        self.chestOpenTips:SetActive(false)
        self.chestGetTips:SetActive(false)
    else
        self.chestOpenTips:SetActive(chestNum > 0)
        self.chestGetTips:SetActive(chestNum <= 0)
    end
end

function CommanderPveView:AttrTipsClick()
    self:ActiveTips(true)
end

function CommanderPveView:AttrTipsCloseClick()
    self:ActiveTips(false)
end

function CommanderPveView:ActiveTips(flag)
    self.attrTipsNode:SetActive(flag)
    if not flag then
        return
    end 

    local attrs = mod.CommanderProxy:GetModeAttrList(CommanderDefine.Mode.pve)
    AttrUtils.SortAttr(attrs)
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
        objs.attr[1].valText.text = CommanderUtils.FormatAttrShow(attrInfo.attr_id, attrInfo.attr_val)

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
            objs.attr[2].valText.text = CommanderUtils.FormatAttrShow(attrInfo.attr_id, attrInfo.attr_val)

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


--统领属性Tips点击
function CommanderPveView:CommanderAttrTipsClick()
    
end

function CommanderPveView:EmptyEquilClick()
    SystemMessage.Show("开启宝箱获得装备")
end

--打开宝箱点击
function CommanderPveView:OpenTreasureChestClick()
    mod.CommanderCtrl:RemoveChestChestOpen()
    mod.CommanderCtrl:RemoveChestCloseTimer()
    
    if self:HasTimer("chest_open") then
        mod.TreasureChestProxy.autoOpenFlag = false
        return
    end

    local tempBag = mod.RoleItemProxy:GetRoleItemType(GDefine.BagType.temp)
    if tempBag and tempBag[1] then
        ViewManager.Instance:OpenWindow(NewEquipWindow)
    else
        local conf = Config.ItemData.data_item_info[CommanderDefine.chestItemId]
        local num = mod.TreasureChestProxy:GetChestNum()
        if num <= 0 and #conf.jump_ways > 0 then
            ViewManager.Instance:OpenWindow(JumpWindow,conf.jump_ways)
        else
            mod.CommanderFacade:SendMsg(11006)
        end
    end
end

function CommanderPveView:PlayFirstChestOpenAnim()
    self.isChestOpening = true
    local animTime = self:PlayChestOpenAnim(false)
    AudioManager.Instance:PlayUI(4)
    self:AddTimer("chest_open",1,animTime,self:ToFunc("ChestOpenAnimDone"))
end

function CommanderPveView:PlayChestOpenAnim(isIdle)
    local tempBag = mod.RoleItemProxy:GetRoleItemType(GDefine.BagType.temp)
    local conf = Config.ItemData.data_item_info[tempBag[1].item_id]
    self.curEquipQuality = tempBag[1].quality
    local animName = isIdle and CommanderDefine.ChestQualityAnims.open_idle[self.curEquipQuality] or CommanderDefine.ChestQualityAnims.open[self.curEquipQuality]
    self.chestAnim:Play(animName,-1,0)
    self:SetSprite(self.chestEquipIcon, AssetPath.GetItemIcon(conf.icon),true)
    local animTime = BaseUtils.GetAnimatorClipTime(self.chestAnim,animName)

    

    Log("播放开启",animName,animTime)
    return animTime
end

function CommanderPveView:PlayChestCloseAnim()
    self.isChestCloseing = true
    local animName = CommanderDefine.ChestQualityAnims.close[self.curEquipQuality]
    self.chestAnim:Play(animName,0,0)
    local animTime = BaseUtils.GetAnimatorClipTime(self.chestAnim,animName)
    Log("播放关闭",animName,animTime)
    self:AddTimer("chest_close",1,animTime + 0.3,self:ToFunc("ChestCloseAnimDone"))
    return animTime
end


function CommanderPveView:ChestOpenAnimDone()
    self:RemoveTimer("chest_open")
    self.isChestOpening = false
    mod.CommanderCtrl:OpenChest(mod.TreasureChestProxy.openChestData)
end


function CommanderPveView:ChestCloseAnimDone()
    self:RemoveTimer("chest_close")
    self.isChestCloseing = false
    if mod.TreasureChestProxy.autoOpenFlag then
        if mod.TreasureChestProxy:GetChestNum() <= 0 then
            --Log("箱子数量少于0,停止了")
            mod.TreasureChestProxy.autoOpenFlag = false
        else
            --Log("再次自动打开箱子")
            mod.CommanderFacade:SendMsg(11006)
        end
    end
end


function CommanderPveView:TreasureChestLevClick()
    ViewManager.Instance:OpenWindow(TreasureChestUpWindow)
end

function CommanderPveView:AutoOpenChestClick()
    mod.TreasureChestProxy.autoOpenFlag = false
    mod.CommanderCtrl:RemoveChestChestOpen()
    mod.CommanderCtrl:RemoveChestCloseTimer()
    self:RemoveTimer("auto_open_chest")
    ViewManager.Instance:OpenWindow(AutoOpenChestWindow)
end

--获取宝箱点击
function CommanderPveView:GetTreasureChestClick()
    
end


function CommanderPveView:PlayAutoOpenChest()
    --显示道具
    --Log("自动出售了")
    if mod.TreasureChestProxy:ExistTempEquip() then
        mod.CommanderFacade:SendMsg(11009,1)
    end
    
    self:AddTimer("auto_open_chest",1,1,self:ToFunc("PlayAutoOpenChestTimer"))
end

function CommanderPveView:PlayAutoOpenChestTimer()
    self:RemoveTimer("auto_open_chest")
    if mod.TreasureChestProxy:GetChestNum() <= 0 then
        --Log("箱子数量少于0,停止了")
        mod.TreasureChestProxy.autoOpenFlag = false
    else
        --Log("再次自动打开箱子")
        mod.CommanderFacade:SendMsg(11006)
    end
end