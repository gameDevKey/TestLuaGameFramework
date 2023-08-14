RankCursorItem = BaseClass("RankCursorItem", BaseView)

function RankCursorItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
    self.tbItem = {}
end

function RankCursorItem:__CacheObject()
    self.rect = self:Find(nil,RectTransform)
    self.btn = self:Find("canvas/img_rank_arrow",Button)
    self.imgIcon = self:Find("canvas/img_rank_arrow/img_player_icon",Image)

    self.objSingleView = self:Find("canvas/rank_s_root").gameObject
    self.txtSingleName = self:Find("canvas/rank_s_root/txt_name",Text)
    self.txtSingleTrophy = self:Find("canvas/rank_s_root/txt_trophy",Text)
    self.txtSingleBattlecount = self:Find("canvas/rank_s_root/txt_battlecount",Text)
    self.txtSingleWinrate = self:Find("canvas/rank_s_root/txt_winrate",Text)

    self.objMultiView = self:Find("canvas/rank_m_root").gameObject
    self.templateMulti = self:Find("canvas/rank_m_root/content/img_rank_m_item").gameObject
    self.templateMulti:SetActive(false)
    self.transMultiItemParent = self.templateMulti.transform.parent
end

function RankCursorItem:__Create()
end

function RankCursorItem:__BindListener()
    self.btn:SetClick(self:ToFunc("OnButtonClick"))
end

function RankCursorItem:SetData(data, index)
    self.data = data
    self.index = index
    self:RefreshAllStyle()
end

function RankCursorItem:RefreshAllStyle()
    self:CloseAllView()
end

function RankCursorItem:CloseAllView()
    self.objSingleView:SetActive(false)
    self.objMultiView:SetActive(false)
end

function RankCursorItem:SetPos(x,y)
    UnityUtils.SetAnchoredPosition(self.rect, x, y)
end

function RankCursorItem:OnReset()
    self.data = nil
    self.index = nil
end

function RankCursorItem:OnRecycle()
    self:CloseAllView()
    self:RemoveAllItem()
end

function RankCursorItem:OnButtonClick()
    if #self.data > 1 then
        self.objMultiView:SetActive(true)
        self.objSingleView:SetActive(false)
        self:LoadMultiViewItem(self.data)
    else
        self.objMultiView:SetActive(false)
        self.objSingleView:SetActive(true)
        local data = self.data[1]
        self.txtSingleName.text = data.name
        self.txtSingleTrophy.text = data.trophy
        self.txtSingleBattlecount.text = data.battle_count
        self.txtSingleWinrate.text = UIUtils.GetWinrateText(data.win_count,data.battle_count)
    end
    mod.DivisionFacade:SendEvent(RankWindow.Event.ActiveFocusButton, true)
end

function RankCursorItem:LoadMultiViewItem(list)
    self:RemoveAllItem()
    for index, data in ipairs(list) do
        local item = GameObject.Instantiate(self.templateMulti)
        item:SetActive(true)
        local trans = item.transform
        trans:SetParent(self.transMultiItemParent)
        trans:Reset()
        local txtName = trans:Find("txt_name"):GetComponent(Text)
        local txtTrophy = trans:Find("txt_trophy"):GetComponent(Text)
        local txtBattlecount = trans:Find("txt_battlecount"):GetComponent(Text)
        local txtWinrate = trans:Find("txt_winrate"):GetComponent(Text)
        txtName.text = data.name
        txtTrophy.text = data.trophy
        txtBattlecount.text = data.battle_count
        txtWinrate.text = UIUtils.GetWinrateText(data.win_count,data.battle_count)
        table.insert(self.tbItem, item)
    end
end

function RankCursorItem:RemoveAllItem()
    for _, item in ipairs(self.tbItem) do
        GameObject.Destroy(item)
    end
    self.tbItem = {}
end

--#region 静态方法

function RankCursorItem.Create(template)
    local item = RankCursorItem.New()
    item:SetObject(GameObject.Instantiate(template))
    item:Show()
    return item
end

--#endregion