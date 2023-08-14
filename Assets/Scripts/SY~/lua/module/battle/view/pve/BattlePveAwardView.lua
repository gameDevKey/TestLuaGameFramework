BattlePveAwardView = BaseClass("BattlePveAwardView",ExtendView)

BattlePveAwardView.Event = EventEnum.New(
    "RefreshAwardNum"
)

function BattlePveAwardView:__Init()
    self.tbItem = {}
end

function BattlePveAwardView:__Delete()
end

function BattlePveAwardView:__CacheObject()
    self.txtTitle = self:Find("main/operate_con/gain_con/gain_title",Text)
    self.transContent = self:Find("main/operate_con/gain_con/gain_content")
    self.template = self:Find("main/operate_con/gain_con/gain_content/gain_con_item").gameObject
    self.template:SetActive(false)
end

function BattlePveAwardView:__BindListener()
end

function BattlePveAwardView:__BindEvent()
    self:BindEvent(BattlePveAwardView.Event.RefreshAwardNum)
end

function BattlePveAwardView:__Create()
    self.txtTitle.text = TI18N("累计获得")
end

--TODO 目前先固定显示 装备箱、加速卡、钻石
function BattlePveAwardView:GetShowItemIds()
    return {GDefine.ItemId.Diamond, GDefine.ItemId.EquipChest, GDefine.ItemId.SpeedCard,}
end

function BattlePveAwardView:__Show()
    self:RecycleAllItem()
    for _, id in ipairs(self:GetShowItemIds()) do
        local obj = GameObject.Instantiate(self.template)
        obj:SetActive(true)
        obj.transform:SetParent(self.transContent)
        obj.transform:Reset()
        local img = obj.transform:Find("icon"):GetComponent(Image)
        local txt = obj.transform:Find("num"):GetComponent(Text)
        local conf = Config.ItemData.data_item_info[id]
        self:SetSprite(img, AssetPath.GetItemIcon(conf.icon),true)
        txt.text = 0
        self.tbItem[id] = {
            id = id,
            txt = txt,
            obj = obj
        }
    end
end

function BattlePveAwardView:__Hide()
    self:RecycleAllItem()
end

function BattlePveAwardView:RefreshAwardNum(id,num)
    local data = self.tbItem[id]
    if data then
        data.txt.text = num
    end
end

function BattlePveAwardView:RecycleAllItem()
    for _, data in pairs(self.tbItem) do
        GameObject.Destroy(data.obj)
    end
    self.tbItem = {}
end