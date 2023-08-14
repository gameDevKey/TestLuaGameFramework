FastConfigCardItem = BaseClass("FastConfigCardItem", BaseView)

function FastConfigCardItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
end

function FastConfigCardItem:__Delete()
end

function FastConfigCardItem:__CacheObject()
    self.btn = self:Find(nil,Button)
    self.imgJob = self:Find("img_job",Image)
    self.imgIcon = self:Find("img_icon",Image)
    self.imgQuality = self:Find("img_quality",Image)
    self.rectPgr = self:Find("img_pgr/img_pgr_fill",RectTransform)
    self.rectPgrSize = {w=self.rectPgr.rect.width,h=self.rectPgr.rect.height}
    self.txtLv = self:Find("txt_lv",Text)
    self.txtPgr = self:Find("img_pgr/txt_pgr",Text)
    self.txtName = self:Find("txt_name",Text)
    self.objUpgrade = self:Find("img_upgrade").gameObject
end

function FastConfigCardItem:__Create()
end

function FastConfigCardItem:__BindListener()
    self.btn:SetClick(self:ToFunc("OnButtonClick"))
end

--[[
    data = {
        unit_id = 10241     当前卡的id
        group_id = 1,       要替换的卡组序号
        slot = 7,           要替换的卡槽位置
    }
]]--
function FastConfigCardItem:SetData(data, index, parentWindow)
    self.data = data
    self.index = index
    self.parentWindow = parentWindow
    self.rootCanvas = parentWindow.rootCanvas
    self:RefreshStyle()
end

function FastConfigCardItem:RefreshStyle()
    self.unitConf = Config.UnitData.data_unit_info[self.data.unit_id]
    self.unitData = mod.CollectionProxy:GetDataById(self.data.unit_id)
    self.txtName.text = self.unitConf.name
    self.txtLv.text = "Lv."..self.unitData.level
    local iconPath = AssetPath.GetUnitIconCollection(self.unitConf.head)
    self:SetSprite(self.imgIcon,iconPath,true)
    local jobIcon = MainuiDefine.JobToIcon[self.unitConf.job]
    self:SetSprite(self.imgJob, jobIcon)
    local qualityIcon = MainuiDefine.QualityToIcon[self.unitConf.quality]
    self:SetSprite(self.imgQuality, qualityIcon)
    self:RefreshPgr()
end

function FastConfigCardItem:RefreshPgr()
    local nextKey = self.data.unit_id.."_"..self.unitData.level+1
    local nextLevCfg = Config.UnitData.data_unit_lev_info[nextKey]
    local ownCount = self.unitData.count
    local pgrStr = ""
    local pgr = 1
    local enoughCard = false
    local enoughMoney = false
    if nextLevCfg then
        local upNeed = nextLevCfg.lv_up_count
        if upNeed > 0 then
            pgrStr = string.format("%d/%d",ownCount,upNeed)
            pgr = Mathf.Clamp(ownCount / upNeed,0,1)
        end
        enoughCard = ownCount >= upNeed
        enoughMoney = mod.RoleItemProxy:HasItemNum(GDefine.ItemId.Gold,nextLevCfg.lv_up_coin_count)
    end
    self.txtPgr.text = pgrStr
    UnityUtils.SetSizeDelata(self.rectPgr,self.rectPgrSize.w * pgr,self.rectPgrSize.h)
    self.objUpgrade:SetActive(enoughCard and enoughMoney)
end

function FastConfigCardItem:OnRecycle()

end

function FastConfigCardItem:OnButtonClick()
    mod.CollectionFacade:SendMsg(10204, self.data.unit_id, self.data.group_id, self.data.slot)
end

--#region 静态方法

function FastConfigCardItem.Create(template)
    local item = FastConfigCardItem.New()
    item:SetObject(GameObject.Instantiate(template))
    item:Show()
    return item
end

--#endregion