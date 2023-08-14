CollectionItem = BaseClass("CollectionItem",BaseView)

function CollectionItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)

    self.conf = nil
    self.data = nil
    self.newRemind = nil
    self.embattledUpgradeRemind = nil
    self.libraryUpgradeRemind = nil

    self.clickCb = nil
    self.clickArgs = nil
end

function CollectionItem:__Delete()
    self:RemoveRemind()
end

function CollectionItem:__CacheObject()
    self.embattleEmptyNode = self:Find("main/embattle_empty_node").gameObject
    self.embattleLockNode = self:Find("main/embattle_lock_node").gameObject

    self.mainNode = self:Find("main/main").gameObject
    self.btn = self:Find("main/main",Button)
    self.qualityBg = self:Find("main/main/quality_bg",Image)
    self.icon = self:Find("main/main/icon",Image)
    self.nameText = self:Find("main/main/name",Text)

    self.lockNode = self:Find("main/lock_node").gameObject
    self.lockText = self:Find("main/lock_node/lock_text",Text)

    self.unlockNode = self:Find("main/unlock_node").gameObject
    self.jobIcon = self:Find("main/unlock_node/job",Image)
    self.lev = self:Find("main/unlock_node/lev",Text)
    self.filled = self:Find("main/unlock_node/slider/filled",Image)
    self.full = self:Find("main/unlock_node/slider/full").gameObject
    self.quantity = self:Find("main/unlock_node/slider/quantity",Text)
    self.highestText = self:Find("main/unlock_node/slider/highest_text",Text)

    self.remindNode = self:Find("main/unlock_node/remind_node")
    self.newRemindNode = self:Find("main/unlock_node/new_remind_node").gameObject
end

function CollectionItem:__Create()
    self.lockText.text = TI18N("未获得")
    self.highestText.text = TI18N("已满级")
end

function CollectionItem:__BindListener()
    self:AddAnimDelayPlayListener("collection_window_enter",self:ToFunc("OnAnimDelayPlay"))
    self.btn:SetClick(self:ToFunc("OnBtnClick"))
end

function CollectionItem:__Hide()
    self.conf = nil
    self.data = nil
    self:RemoveRemind()
    self.clickCb = nil
    self.clickArgs = nil
end

function CollectionItem:__Show()
    if self.isLock or (not self.conf and not self.data) then
        self.embattleLockNode:SetActive(self.isLock)
        self.embattleEmptyNode:SetActive(not self.conf and not self.data and not self.isLock)
        self.mainNode:SetActive(false)
        self.lockNode:SetActive(false)
        self.unlockNode:SetActive(false)
        return
    end

    if self.conf and not self.data then
        self.lockNode:SetActive(true)
        self.unlockNode:SetActive(false)
        UIUtils.Grey(self.icon,true)
    else
        self.lockNode:SetActive(false)
        self.unlockNode:SetActive(true)
        UIUtils.Grey(self.icon,false)
        self:SetUnlockNode()
    end
    self.mainNode:SetActive(true)
    self:SetMainNode()
end

function CollectionItem:SetData(data)
    self.conf = data.conf
    self.data = data.data
    self.isLock = data.isLock
end

function CollectionItem:SetMainNode()
    local path = CollectionDefine.ItemQualityToPath[self.conf.quality]
    self:SetSprite(self.qualityBg,path.bg)
    self:SetSprite(self.filled,path.filled,true)

    local iconPath = AssetPath.GetUnitIconCollection(self.conf.head)
    self:SetSprite(self.icon,iconPath,true)

    self.nameText.text = self.conf.name
end

function CollectionItem:SetUnlockNode()
    local path = CollectionDefine.JobToIcon[self.conf.job]
    self:SetSprite(self.jobIcon, path)

    self.lev.text = self.data.level
    self:SetSlider()
end

function CollectionItem:SetSlider()
    local key = self.data.unit_id.."_"..self.data.level+1
    local nextLevInfo = Config.UnitData.data_unit_lev_info[key]
    local consume = 0
    local val = 0
    local quantityText = ""

    if not nextLevInfo then
        val = 1
        self.full.gameObject:SetActive(true)
        self.highestText.gameObject:SetActive(true)
        return
    else
        self.full.gameObject:SetActive(false)
        self.highestText.gameObject:SetActive(false)
        consume = nextLevInfo.lv_up_count
        if consume > 0 then
            val = Mathf.Clamp(self.data.count / consume,0,1)
        else
            val = 1
        end
        quantityText = self.data.count.."/"..consume
    end

    self.filled.fillAmount = val
    self.quantity.text = quantityText
end

function CollectionItem:SetClickCb(cb,args)
    self.clickCb = cb
    self.clickArgs = args
end

function CollectionItem:OnBtnClick()
    if self.clickCb then
        self.clickCb(self.clickArgs)
    end
end

function CollectionItem:OnAnimDelayPlay()
    self.gameObject:SetActive(true)
    self:PlayAnim("collection_item")
end

function CollectionItem:SetNewRemind()
    if not self.data then
        return
    end
    self.newRemind = CustomRemindItem.New(self.newRemindNode)
    self.newRemind:SetRemindId(RemindDefine.RemindId.collection_new_unit,self.data.unit_id)
end

function CollectionItem:SetEmbattledUpgradeRemind()
    if not self.data then
        return
    end
    self.embattledUpgradeRemind = MarkRemindItem.New()
    self.embattledUpgradeRemind:SetParent(self.remindNode)
    self.embattledUpgradeRemind:SetRemindId(RemindDefine.RemindId.collection_embattled_card_can_upgrade,self.data.unit_id)
end

function CollectionItem:SetLibraryUpgradeRemind()
    if not self.data then
        return
    end
    self.libraryUpgradeRemind = MarkRemindItem.New()
    self.libraryUpgradeRemind:SetParent(self.remindNode)
    self.libraryUpgradeRemind:SetRemindId(RemindDefine.RemindId.collection_library_card_can_upgrade,self.data.unit_id)
end

function CollectionItem:RemoveRemind()
    if self.newRemind then
        self.newRemind:Destroy()
        self.newRemind = nil
    end

    if self.embattledUpgradeRemind then
        self.embattledUpgradeRemind:Destroy()
        self.embattledUpgradeRemind = nil
    end

    if self.libraryUpgradeRemind then
        self.libraryUpgradeRemind:Destroy()
        self.libraryUpgradeRemind = nil
    end
end

function CollectionItem:OnReset()
    self.conf = nil
    self.data = nil
    self:RemoveRemind()
    self.clickCb = nil
    self.clickArgs = nil
end

function CollectionItem.Create(template)
    local collectionItem = CollectionItem.New()
    collectionItem:SetObject(GameObject.Instantiate(template))
    return collectionItem
end