CollectionLibraryView = BaseClass("CollectionLibraryView",ExtendView)

CollectionLibraryView.Event = EventEnum.New(
    "RefreshLibraryView"
)

function CollectionLibraryView:__Init()
    self.cards = {}
end

function CollectionLibraryView:__Delete()
    for i, v in ipairs(self.cards) do
        v:Destroy()
    end
end

function CollectionLibraryView:__CacheObject()
    self.collectCount = self:Find("main/scroll_view/view_port/content/library/title/collect_count")
    self.collectNum = self:Find("main/scroll_view/view_port/content/library/title/collect_count/collected_num",Text)
    self.notCollectNum = self:Find("main/scroll_view/view_port/content/library/title/collect_count/not_collected_num",Text)
    self.cardCon = self:Find("main/scroll_view/view_port/content/library/card_con")
    self.itemTemp = self:Find("template/item").gameObject
end

function CollectionLibraryView:__Create()
end

function CollectionLibraryView:__BindEvent()
    self:BindEvent(CollectionLibraryView.Event.RefreshLibraryView)
end

function CollectionLibraryView:__BindListener()
end


function CollectionLibraryView:__Show()
    local data = mod.CollectionProxy:GetLibraryData()
    self:RefreshLibraryView(data)
end

function CollectionLibraryView:RefreshLibraryView(data)
    local index = 0

    for i, unitId in ipairs(data.order) do
        if not mod.CollectionProxy:IsEmbattled(unitId) then
            index = index + 1
            local card = self.cards[index]
            if not card then
                card = CollectionItem.Create(self.itemTemp)
                card.transform:SetParent(self.cardCon)
                card.transform:Reset()
                self.cards[index] = card
            end

            local conf = Config.UnitData.data_unit_info[unitId]
            local unitData = data.dict[unitId]
            card:SetAnim(AssetPath.collectionItemCtrl, self.MainView.collectionItemCtrl)
            card:SetData({conf = conf, data = unitData})
            card:Show()
            card:RemoveRemind()
            card.newRemindNode:SetActive(false)
            card:SetNewRemind()
            card:SetLibraryUpgradeRemind()
            card:SetClickCb(self:ToFunc("ShowDetails"),conf.id)
        end
    end

    for i = index + 1, #self.cards do
        self.cards[i]:Hide()
    end

    self:SetCollectNum()
end

function CollectionLibraryView:SetCollectNum()
    local collectNum, notCollectNum = mod.CollectionProxy:GetCollectCount()
    self.collectNum.text = collectNum
    self.notCollectNum.text = collectNum + notCollectNum
end

function CollectionLibraryView:ShowDetails(unitId)
    self.MainView:ShowDetails(unitId)
end