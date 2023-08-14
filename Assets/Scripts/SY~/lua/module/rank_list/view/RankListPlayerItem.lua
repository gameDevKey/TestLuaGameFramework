RankListPlayerItem = BaseClass("RankListPlayerItem", BaseView)
RankListPlayerItem.RankUpColor = Color(112/255,201/255,87/255,1)
RankListPlayerItem.RankDownColor = Color(225/255,71/255,41/255,1)

function RankListPlayerItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
end

function RankListPlayerItem:__Delete()
end

function RankListPlayerItem:__CacheObject()
    self.btn = self:Find(nil,Button)
    self.txtRank = self:Find("txt_rank",Text)
    self.txtChange = self:Find("txt_change",Text)
    self.txtName = self:Find("group/txt_name",Text)
    self.txtUnion = self:Find("group/txt_union",Text)
    self.txtTrophy = self:Find("txt_trophy",Text)
    self.imgIcon = self:Find("head/icon",Image)
    self.objRankUp = self:Find("img_up").gameObject
    self.objRankDown = self:Find("img_down").gameObject
    -- self.imgDivision = self:Find("img_division",Image)
end

function RankListPlayerItem:__Create()
end

function RankListPlayerItem:__BindListener()
    self.btn:SetClick(self:ToFunc("OnClick"))
end

--[[
    data = {
    }
]]--
function RankListPlayerItem:SetData(data, index, parentWindow)
    self.data = data
    self.index = index
    self.parentWindow = parentWindow
    self.rootCanvas = parentWindow.rootCanvas
    self:RefreshStyle()
end

function RankListPlayerItem:RefreshStyle()
    self.txtRank.text = self.data.rank
    self.txtName.text = self.data.name
    self.txtTrophy.text = self.data.trophy
    local diffRank = self.data.lastRank - self.data.rank
    local absDiff = math.abs(diffRank)
    self.objRankUp:SetActive(diffRank > 0)
    self.objRankDown:SetActive(diffRank < 0)
    self.txtChange.gameObject:SetActive(diffRank ~= 0)
    if diffRank ~= 0 then
        self.txtChange.text = absDiff
        self.txtChange.color = diffRank > 0 and RankListPlayerItem.RankUpColor or RankListPlayerItem.RankDownColor
    end
    self.txtUnion.gameObject:SetActive(false) --TODO 公会
    -- local conf = Config.DivisionData.data_division_info[self.data.division]
    -- local icon = AssetPath.GetDivisionIconPath(conf.icon)
    -- self:SetSprite(self.imgDivision, icon, false)
end

function RankListPlayerItem:OnClick()
    mod.PersonalInfoCtrl:OpenPersonalInfo({
        uid = self.data.role_uid
    })
end

function RankListPlayerItem:OnRecycle()

end

--#region 静态方法

function RankListPlayerItem.Create(template)
    local item = RankListPlayerItem.New()
    item:SetObject(GameObject.Instantiate(template))
    item:Show()
    return item
end

--#endregion