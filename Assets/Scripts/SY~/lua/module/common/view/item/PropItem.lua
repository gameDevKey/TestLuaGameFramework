PropItem = BaseClass("PropItem", BaseView)
PropItem.Width = 122
PropItem.Height = 127

function PropItem:__Init()
    self:SetViewType(UIDefine.ViewType.item)
    self.data = nil
    self.enableTips = true
    self.enableNum = true
end

function PropItem:__CacheObject()
    self.qualityBg = self:Find(nil,Image)
    self.propIcon = self:Find("icon", Image)
    self.numNode = self:Find("num_node").gameObject
    self.numText = self:Find("num_node/num", Text)
end

function PropItem:__BindListener()
    self:Find("btn",Button):SetClick(self:ToFunc("ItemClick"))
end


function PropItem:SetData(data)
    self.data = data
    self.conf = Config.ItemData.data_item_info[data.item_id]
    self:SetQualityBg()
    self:SetIcon()
    self:SetNum(self.data.count)
end

function PropItem:SetQualityBg()
    self:SetSprite(self.qualityBg,AssetPath.QualityToItemSquare[self.conf.quality])
end

function PropItem:SetIcon()
    local icon = AssetPath.GetItemIcon(tostring(self.conf.icon))
    self:SetSprite(self.propIcon, icon, true)
end

function PropItem:SetNum(num)
    local show = self.enableNum and (num and num > 0)
    self.numNode:SetActive(show)
    if show then
        self.numText.text = num
        local height = self.numNode.transform.rect.height
        UnityUtils.SetSizeDelata(self.numNode.transform, self.numText.preferredWidth+10, height)
    end
end

function PropItem:SetClickCb(cb)

end

function PropItem:EnableTips(flag)
    self.enableTips = flag
end

function PropItem:EnableNum(flag)
    self.enableNum = flag
end

function PropItem:ItemClick()
    if self.enableTips then
        mod.TipsCtrl:OpenItemTips(self.data,self.transform)
    end
end

function PropItem:SetSize(w,h)
    self.transform:SetLocalScale(w / PropItem.Width,h / PropItem.Height,1)
end

function PropItem:SetScale(x,y)
    self.transform:SetLocalScale(x,y,1)
end

function PropItem.Create(template)
    local propItem = nil
    if not propItem then
        propItem = PropItem.New()
        propItem:SetObject(GameObject.Instantiate(PreloadManager.Instance:GetAsset(AssetPath.propItem)))
    end
    return propItem
end

