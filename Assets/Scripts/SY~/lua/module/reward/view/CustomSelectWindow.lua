CustomSelectWindow = BaseClass("CustomSelectWindow", BaseWindow)
CustomSelectWindow.SortType = {
    None = 1,                   --不进行排序
    OwnedFirst = 2,             --已拥有的在前
    OwnedFirstAndItemOrder = 3, --已拥有的在前，且按照Item表排序
}

function CustomSelectWindow:__Init()
    self:SetAsset("ui/prefab/reward/custom_select_window.prefab",AssetType.Prefab)
    self.notTempHide = true
    self.tbItem = {}
end

function CustomSelectWindow:__Delete()
end

function CustomSelectWindow:__CacheObject()
    self.template = self:Find("scroll_view/Viewport/Content/custom_select_item").gameObject
    self.template:SetActive(false)
    self.transContent = self:Find("scroll_view/Viewport/Content")
    self.btnGet = self:Find("bottom/btn_get",Button)
    self.btnCancel = self:Find("bottom/btn_cancel",Button)
    self.btnBG = self:Find("btn_bg",Button)
    self.txtTips = self:Find("bottom/txt_tips",Text)
    self.objBottom = self:Find("bottom").gameObject
end

function CustomSelectWindow:__BindListener()
    self.btnGet:SetClick(self:ToFunc("OnSelectButtonClick"))
    self.btnCancel:SetClick(self:ToFunc("OnConfirmButtonClick"))
    self.btnBG:SetClick(self:ToFunc("OnConfirmButtonClick"))
end

function CustomSelectWindow:__BindEvent()
end

function CustomSelectWindow:__Create()
    self.txtTips.text = TI18N("可以任选一个已拥有的英雄哦")
end

--[[
    args = {
        items : List<{item_id,item_count}>      物品数据
        sortType : CustomSelectWindow.SortType  排序类型
        cbItemSelect : function                 物品被选中回调
        cbSelect : function                     确定回调
        cbClose : function                      关闭回调
        judgeOwned : boolean                    当物品未拥有时，不可选择，显示灰色
        onlyPreview: boolean                    是否仅预览(隐藏领取按钮)
    }
]]--
function CustomSelectWindow:__Show()
    self.rootCanvas.sortingOrder = ViewManager.Instance:GetCurOrderLayer() + 10 --比其他界面要高，若其他界面又要显示粒子或者模型的，预留10
    self.sortType = self.args.sortType or CustomSelectWindow.SortType.None
    self.items = self:GetSortItems(self.args.items,self.sortType)
    self.cbItemSelect = self.args.cbItemSelect
    self.cbSelect = self.args.cbSelect
    self.cbClose = self.args.cbClose
    self.judgeOwned = self.args.judgeOwned or false
    self.onlyPreview = self.args.onlyPreview or false
    self.objBottom:SetActive(not self.onlyPreview)
    self:RecycleAllItem()
    for i, data in ipairs(self.items) do
        local item = CustomSelectItem.Create(self.template)
        item.transform:SetParent(self.transContent)
        item.transform.localScale = Vector3.one
        item:SetJudgeOwned(self.judgeOwned)
        item:SetSelectCallback(self:ToFunc("OnItemSelect"))
        item:SetOnlyPreview(self.onlyPreview)
        item:SetData(data, i)
        table.insert(self.tbItem, item)
    end
    --自动选中第一个
    if #self.tbItem > 0 then
        self.tbItem[1]:OnSelect()
    end
end

function CustomSelectWindow:GetSortItems(items,sortType)
    if sortType == CustomSelectWindow.SortType.None then
        return items
    end
    local newItems = {}
    local otherItems = {}
    for _, item in ipairs(items) do
        local itemId = item.item_id
        local owned = mod.CollectionProxy:GetDataById(itemId) ~= nil
        if owned then
            table.insert(newItems, item)
        else
            table.insert(otherItems, item)
        end
    end
    if sortType == CustomSelectWindow.SortType.OwnedFirstAndItemOrder then
        CustomSelectWindow.SortItemsByItemOrder(newItems)
        CustomSelectWindow.SortItemsByItemOrder(otherItems)
    end
    for _, item in ipairs(otherItems) do
        table.insert(newItems, item)
    end
    return newItems
end

function CustomSelectWindow:__Hide()
    if self.cbClose then
        self.cbClose()
    end
    self:RecycleAllItem()
end

function CustomSelectWindow:OnItemSelect(selectItem, validate)
    for _, item in ipairs(self.tbItem) do
        if item == selectItem then
            if self.cbItemSelect then
                self.cbItemSelect(selectItem, validate)
            end
        else
            if validate then
                item:OnUnselect()
            end
        end
    end
end

function CustomSelectWindow:RecycleAllItem()
    for _, item in ipairs(self.tbItem or {}) do
        item:OnRecycle()
        item:Destroy()
    end
    self.tbItem = {}
end

function CustomSelectWindow:OnSelectButtonClick()
    if self.cbSelect then
        self.cbSelect(self.args)
    end
    self:OnCloseWin()
end

function CustomSelectWindow:OnConfirmButtonClick()
    self:OnCloseWin()
end

function CustomSelectWindow:OnCloseWin()
    ViewManager.Instance:CloseWindow(CustomSelectWindow)
end

--#region 静态函数

function CustomSelectWindow.SortItemsByItemOrder(items)
    table.sort(items, function (a,b)
        return a.item_id < b.item_id
    end)
end

--#endregion