BattlePveSelectItemView = BaseClass("BattlePveSelectItemView",ExtendView)

BattlePveSelectItemView.Event = EventEnum.New(
    "InitComplete",
    "RefreshSelectItems",
    "RefreshCountDownTime",
    "SelectItem"
)

function BattlePveSelectItemView:__Init()
    self.waitSelectItems = nil
    self.selectItemObjects = {}
    self.selectIndex = nil
end

function BattlePveSelectItemView:__Delete()
end

function BattlePveSelectItemView:__BindEvent()
    self:BindEvent(BattleFacade.Event.InitComplete)
    self:BindEvent(BattlePveSelectItemView.Event.RefreshSelectItems)
    self:BindEvent(BattlePveSelectItemView.Event.RefreshCountDownTime)
    self:BindEvent(BattlePveSelectItemView.Event.SelectItem)
end

function BattlePveSelectItemView:__CacheObject()
    self.selectItemNode = self:Find("main/select_item_node").gameObject
    for i = 1, 3 do self:GetSelectSkillObjects(i) end
    self.countDown = self:Find("main/select_item_node/count_down_tips",Text)
    self.canvas = self:Find("main/select_item_node",Canvas)
end

function BattlePveSelectItemView:GetSelectSkillObjects(index)
    local object = {}
    local item = self:Find("main/select_item_node/item_root/item_"..tostring(index).."_root/item_"..tostring(index)).gameObject
    object.gameObject = item
    object.transform = item.transform

    object.icon = item.transform:Find("icon").gameObject:GetComponent(Image)
    object.typeAct = item.transform:Find("type/act").gameObject
    object.typePasv = item.transform:Find("type/pasv").gameObject
    object.itemName = item.transform:Find("name").gameObject:GetComponent(Text)
    object.cdNode = item.transform:Find("cd").gameObject
    object.cdNum =  item.transform:Find("cd/text").gameObject:GetComponent(Text)
    object.desc =  item.transform:Find("desc").gameObject:GetComponent(Text)
    object.btn = item.transform:Find("btn").gameObject:GetComponent(Button)

    object.btn:SetClick(self:ToFunc("SelectItem"),index)

    table.insert(self.selectItemObjects,object)
end


function BattlePveSelectItemView:__Create()
    self:Find("main/select_item_node/title",Text).text = TI18N("技能选择")
    self:AddAnimEffectListener("item_root",self:ToFunc("OnAnimEffectPlay"))
    self:AddAnimEffectListener("item_1",self:ToFunc("OnAnimEffectPlay"))
    self:AddAnimEffectListener("item_2",self:ToFunc("OnAnimEffectPlay"))
    self:AddAnimEffectListener("item_3",self:ToFunc("OnAnimEffectPlay"))
end

function BattlePveSelectItemView:__Show()
end

function BattlePveSelectItemView:__Hide()
end

function BattlePveSelectItemView:InitComplete()
end

function BattlePveSelectItemView:RefreshSelectItems(waitSelectItems)
    self.canvas.sortingOrder = self:GetOrder() + GDefine.EffectOrderAdd
    self.waitSelectItems = waitSelectItems
    for i = 1, 3 do
        self:SetSelectItem(i)
    end
    self:ActiveSelectItemView(true)
    self:PlayAnim("item_root")
    TimerManager.Instance:AddTimer(1, 0.5, self:ToFunc("OnOpenViewFinish"))
end

function BattlePveSelectItemView:OnOpenViewFinish()
    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_open, "pve_select")
end

function BattlePveSelectItemView:SetSelectItem(i)
    local object = self.selectItemObjects[i]
    local item = self.waitSelectItems[i]

    local itemInfo = RunWorld.BattleConfSystem:PveData_data_pve_item(item.item_group_id, item.item_id)

    if not itemInfo then
        assert(false,string.format("读取[group_id:%s][item_id:%s]的pve局内道具配置为空",item.item_group_id,item.item_id))
    end
    local iconPath = AssetPath.GetPveItemShortIcon(itemInfo.icon)
    self:SetSprite(object.icon,iconPath)
    if itemInfo.type == BattleDefine.pveItemEffectType.manual_skill then
        object.typeAct:SetActive(true)
        object.typePasv:SetActive(false)
    else
        object.typeAct:SetActive(false)
        object.typePasv:SetActive(true)
    end
    object.itemName.text = TI18N(itemInfo.name)
    object.cdNode:SetActive(itemInfo.cd > 0)
    object.cdNum.text = tostring(itemInfo.cd / 1000).."s"
    object.desc.text = TI18N(itemInfo.desc)
end

function BattlePveSelectItemView:ActiveSelectItemView(flag)
    self.selectItemNode:SetActive(flag)
    if not flag then
        self.waitSelectItems = nil
        -- self:HideEffects()
    end
end

function BattlePveSelectItemView:RefreshCountDownTime(time)
    local text = TI18N(string.format("%ss后自动选择",time))
    self.countDown.text = text
end

function BattlePveSelectItemView:SelectItem(index)
    self.selectIndex = index
    self:PlayAnim("item_"..tostring(index))
    self:RemoveAllEffect()
    TimerManager.Instance:AddTimer(1, 0.5, self:ToFunc("OnSelectItemFinish"))
end

function BattlePveSelectItemView:OnSelectItemFinish()
    RunWorld.SelectPveItemSystem:SelectPveItem(self.selectIndex)
    self.selectIndex = nil
    self:ActiveSelectItemView(false)
    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_close, "pve_select")
end

function BattlePveSelectItemView:OnAnimEffectPlay(animName,data)
    self:LoadUIEffectByAnimData(data,false)
end