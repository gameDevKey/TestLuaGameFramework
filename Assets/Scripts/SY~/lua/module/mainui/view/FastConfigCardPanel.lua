FastConfigCardPanel = BaseClass("FastConfigCardPanel",BaseWindow)
FastConfigCardPanel.Event = EventEnum.New(
    "RefreshCardGroup",
    "ReOpen"
)

FastConfigCardPanel.TAB_COLOR_SELECT = Color(45/255,49/255,63/255,255/255)
FastConfigCardPanel.TAB_COLOR_UNSELECT = Color(243/255,250/255,252/255,255/255)

function FastConfigCardPanel:__Init()
    self:SetAsset("ui/prefab/mainui/mainui_fast_config.prefab",AssetType.Prefab)
    self.tbTab = {}
end

function FastConfigCardPanel:__CacheObject()
    -- self.btnBgClose = self:Find("btn_bg_close",Button)
    self.objArrow = self:Find("img_arrow").gameObject
    self.objArrow:SetActive(false)
    self.rectArrow = self:Find("img_arrow",RectTransform)
    self.tabContent = self:Find("main/tabs")
    self.tabTemplate = self:Find("main/tabs/tab").gameObject
    self.tabTemplate:SetActive(false)
    self.btnClose = self:Find("main/cards/btn_close",Button)
    self.scrollview = self:Find("main/cards/sv",ScrollRect)
    self.cardTemplate = self:Find("main/cards/sv/Viewport/Content/card_item").gameObject
    self.cardTemplate:SetActive(false)
end

function FastConfigCardPanel:__Create()
end

function FastConfigCardPanel:__BindListener()
    -- self.btnBgClose:SetClick(self:ToFunc("OnBgCloseBtnClick"))
    self.btnClose:SetClick(self:ToFunc("OnCloseBtnClick"))
end

function FastConfigCardPanel:__BindEvent()
    self:BindEvent(FastConfigCardPanel.Event.RefreshCardGroup)
    self:BindEvent(FastConfigCardPanel.Event.ReOpen)
end

function FastConfigCardPanel:__Hide()

end

--[[
    args = {
        data = {
            group_id = 1, 
            slot = 1, 
            unit_id = 10091
        },
        arrowPos
    }
]]--
function FastConfigCardPanel:__Show()
    self.objArrow:SetActive(false)
    self:LoadAllTab()
    self:LoadAllCard()
    self:RefreshCardGroup()
    mod.MainuiFacade:SendEvent(MainuiPanel.Event.ActiveSceneNode,true)
    mod.MainuiFacade:SendEvent(MainuiModelView.Event.MoveCameraToFar, self:ToFunc("OnMoveCameraFinish"))
end

function FastConfigCardPanel:ReOpen(args)
    self.args = args
    self:RefreshCardGroup()
    self:FixArrowPos()
end

function FastConfigCardPanel:OnMoveCameraFinish()
    self.objArrow:SetActive(true)
    self:FixArrowPos()
end

function FastConfigCardPanel:LoadAllTab()
    local count = Config.ConstData.data_const_info["card_group_count"].val
    for i = 1, count do
        local tab = GameObject.Instantiate(self.tabTemplate)
        tab:SetActive(true)
        tab.transform:SetParent(self.tabContent)
        tab.transform:Reset()
        local txtNum = tab.transform:Find("txt_num"):GetComponent(Text)
        local objSelect = tab.transform:Find("img_select").gameObject
        local btn = tab:GetComponent(Button)
        btn:SetClick(self:ToFunc("OnTabClick"),i)
        txtNum.text = i
        self.tbTab[i] = {
            root = tab,
            txtNum = txtNum,
            objSelect = objSelect,
        }
    end
end

function FastConfigCardPanel:DeleteAllTab()
    for _, tab in ipairs(self.tbTab) do
        GameObject.Destroy(tab.root)
    end
    self.tbTab = {}
end

function FastConfigCardPanel:LoadAllCard()
    self.loopSv = self:GetLoopScrollView()
end

function FastConfigCardPanel:RefreshCardGroup()
    local index = mod.CollectionProxy:GetBattleGroupCurIndex()
    self.args.data.group_id = index
    for i, tab in ipairs(self.tbTab) do
        if i == index then
            tab.objSelect:SetActive(true)
            tab.txtNum.color = FastConfigCardPanel.TAB_COLOR_SELECT
        else
            tab.objSelect:SetActive(false)
            tab.txtNum.color = FastConfigCardPanel.TAB_COLOR_UNSELECT
        end
    end
    local datas = {}
    for _, sc in ipairs(mod.CollectionProxy:GetCardFromLibrary(false)) do
        table.insert(datas,{data = {
            unit_id = sc.unit_id,
            group_id = self.args.data.group_id,
            slot = self.args.data.slot
        }})
    end
    self.loopSv:SetDatas(datas,true)
end

function FastConfigCardPanel:FixArrowPos()
    local tpose = self.args.tpose
    local camera = self.args.camera
    if not tpose or not camera then
        return
    end
    local objPos = tpose.gameObject.transform.position
    local arrowPos = BaseUtils.WorldToUIPoint(camera, objPos)
    local h = 130
    UnityUtils.SetAnchoredPosition(self.rectArrow, arrowPos.x, arrowPos.y+h)
end

function FastConfigCardPanel:OnTabClick(index)
    if index ~= mod.CollectionProxy:GetBattleGroupCurIndex() then
        if mod.OpenFuncProxy:JudgeFuncUnlockAndMsg(GDefine.FuncUnlockId.ChangeCardGroup) then
            mod.CollectionFacade:SendMsg(10205, index)
        end
    end
end

function FastConfigCardPanel:GetLoopScrollView()
    local helper = GridLoopScrollView.New(self.scrollview, {
        alignType = LoopScrollViewDefine.AlignType.Top,
        onCreate = self:ToFunc("OnItemCreate"),
        onRender = self:ToFunc("OnItemRender"),
        onRecycle = self:ToFunc("OnItemRecycle"),
        itemWidth = 170,
        itemHeight = 300,
    })
    return helper
end

function FastConfigCardPanel:DeleteLoopScrollView()
    if self.loopSv then
        self.loopSv:Delete()
        self.loopSv = nil
    end
end

function FastConfigCardPanel:OnItemCreate(index,data)
    return FastConfigCardItem.Create(self.cardTemplate)
end

function FastConfigCardPanel:OnItemRender(item, index, data)
    item:SetData(data.data, index, self)
end

function FastConfigCardPanel:OnItemRecycle(item)
    item:OnRecycle()
end

function FastConfigCardPanel:OnCloseBtnClick()
    self:DeleteLoopScrollView()
    self:DeleteAllTab()
    ViewManager.Instance:CloseWindow(FastConfigCardPanel)
    mod.MainuiFacade:SendEvent(MainuiModelView.Event.MoveCameraToNeer)
end

function FastConfigCardPanel:OnBgCloseBtnClick()
    -- self:OnCloseBtnClick()
    -- CustomUnityUtils.PointerClickHandler(clickObj,pointerData)
end