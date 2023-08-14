RankListPlayerView = BaseClass("RankListPlayerView",ExtendView)
RankListPlayerView.RankID = 1001

function RankListPlayerView:__Init()

end

function RankListPlayerView:__CacheObject()
    self.view = self:Find("main/player_list_view").gameObject
    self.scrollview = self:Find("main/player_list_view/player_list",ScrollRect)
    self.btnMoveTop = self:Find("main/player_list_view/btn_move_top",Button)
    self.btnMoveBottom = self:Find("main/player_list_view/btn_move_bottom",Button)

    --my info
    self.objMyInfo = self:Find("main/player_list_view/my_info").gameObject
    self.txtMyName = self:Find("main/player_list_view/my_info/group/name",Text)
    self.txtMyUnion = self:Find("main/player_list_view/my_info/group/union",Text)
    self.txtMyTrophy = self:Find("main/player_list_view/my_info/trophy",Text)
    self.txtMyRank = self:Find("main/player_list_view/my_info/rank",Text)
    self.imgMyIcon = self:Find("main/player_list_view/my_info/image_70/icon",Image)

    --top3
    self.topInfo = {}
    for i = 1, 3 do
        local key = "pos_"..i
        table.insert(self.topInfo, {
            root = self:Find("main/"..key).gameObject,
            top = self:Find("main/"..key.."/top").gameObject,
            bottom = self:Find("main/"..key.."/bottom").gameObject,
            name = self:Find("main/"..key.."/top/group/name",Text),
            union = self:Find("main/"..key.."/top/group/union",Text),
            trophy = self:Find("main/"..key.."/bottom/img/trophy",Text),
            icon = self:Find("main/"..key.."/icon",Image),
            btn = self:Find("main/"..key.."/icon",Button),
        })
    end

    self.template = self:Find("main/player_list_view/player_list/Viewport/Content/player_list_item").gameObject
    self.template:SetActive(false)
end

function RankListPlayerView:__Create()
end

function RankListPlayerView:__BindListener()
    self.btnMoveTop:SetClick(self:ToFunc("OnMoveButtonClick"),true)
    self.btnMoveBottom:SetClick(self:ToFunc("OnMoveButtonClick"),false)
    for i, info in ipairs(self.topInfo) do
        info.btn:SetClick(self:ToFunc("OnTopItemClick"),i)
    end
end

function RankListPlayerView:__BindEvent()
    self:BindEvent(RankListFacade.Event.ShowPlayerList)
    self:BindEvent(RankListFacade.Event.RefreshPlayerList)
    self:BindEvent(RankListFacade.Event.HidePlayerList)
end

function RankListPlayerView:__Hide()
    self:DeleteLoopScrollView()
end

function RankListPlayerView:ShowPlayerList()
    self.view:SetActive(true)
    mod.DivisionProxy:SendMsg(11300,RankListPlayerView.RankID)
end

function RankListPlayerView:RefreshPlayerList()
    local sc = mod.DivisionProxy.tbRankData[RankListPlayerView.RankID]
    local topInfo = {}
    local otherInfo = {}
    local myInfo = nil
    local myData = mod.RoleProxy:GetRoleData()
    for i, data in ipairs(sc) do
        local tmpData = data.role_info
        tmpData.rank = data.rank
        tmpData.lastRank = 0 --TODO
        if tmpData.rank <= #self.topInfo then
            table.insert(topInfo, tmpData)
        else
            table.insert(otherInfo, {data=tmpData})
        end
        if tmpData.role_uid == myData.role_uid then
            myInfo = tmpData
        end
    end
    self:InitLoopScrollView(otherInfo)
    self:RefreshTopInfo(topInfo)
    self:RefreshMyInfo(myInfo)
end

function RankListPlayerView:HidePlayerList()
    self.view:SetActive(false)
    self:DeleteLoopScrollView()
    self:HideTopInfo()
end

function RankListPlayerView:InitLoopScrollView(datas)
    self:DeleteLoopScrollView()
    self.loopSv = self:GetLoopScrollView()
    self.loopSv:SetDatas(datas,true)
end

function RankListPlayerView:GetLoopScrollView()
    local helper = VerticalLoopScrollView.New(self.scrollview, {
        paddingTop = 0,
        paddingBottom = 0,
        gapY = 10,
        alignType = LoopScrollViewDefine.AlignType.Top,
        onCreate = self:ToFunc("OnItemCreate"),
        onRender = self:ToFunc("OnItemRender"),
        onRecycle = self:ToFunc("OnItemRecycle"),
        onComplete = self:ToFunc("OnFillComplete"),
        onRenderNew = self:ToFunc("OnRenderNew"),
        itemWidth = 598,
        itemHeight = 119,
    })
    return helper
end

function RankListPlayerView:DeleteLoopScrollView()
    if self.loopSv then
        self.loopSv:Delete()
        self.loopSv = nil
    end
end

function RankListPlayerView:OnItemCreate(index,data)
    return RankListPlayerItem.Create(self.template)
end

function RankListPlayerView:OnItemRender(item, index, data)
    item:SetData(data.data, index, self.MainView)
end

function RankListPlayerView:OnItemRecycle(item)
    item:OnRecycle()
end

function RankListPlayerView:OnFillComplete()
    self:UpdateMoveButtonState()
end

function RankListPlayerView:OnRenderNew()
    self:UpdateMoveButtonState()
end

function RankListPlayerView:UpdateMoveButtonState()
    local totalLen = #self.loopSv:GetAllData()
    local showTop = totalLen > 0
    local showBottom = totalLen > 0
    self.loopSv:RangeRenderItem(function (itemData)
        local item = itemData.obj
        if item.index == 1 then
            showTop = false
        end
        if item.index == totalLen then
            showBottom = false
        end
    end,true)
    self.btnMoveTop.gameObject:SetActive(showTop)
    self.btnMoveBottom.gameObject:SetActive(showBottom)
end

function RankListPlayerView:OnMoveButtonClick(topOrBottom)
    local index = topOrBottom and 0 or #self.loopSv:GetAllData()
    self.loopSv:ScrollToItem(index, nil, 0.5, nil, LoopScrollViewDefine.JumpType.Top)
end

function RankListPlayerView:RefreshMyInfo(myData)
    myData = myData or {}
    local roleData = mod.RoleProxy:GetRoleData()
    self.txtMyName.text = myData.name or roleData.name
    self.txtMyTrophy.text = myData.trophy or roleData.trophy
    self.txtMyRank.text = myData.rank or TI18N("未上榜")
    self.txtMyUnion.gameObject:SetActive(false) --TODO 公会
end

function RankListPlayerView:RefreshTopInfo(datas)
    self.topData = datas
    for i, cmp in ipairs(self.topInfo) do
        local data = datas[i]
        if data then
            cmp.root:SetActive(true)
            cmp.name.text = data.name
            cmp.trophy.text = data.trophy
            cmp.union.gameObject:SetActive(false) --TODO 公会
        else
            cmp.root:SetActive(false)
        end
    end
end

function RankListPlayerView:HideTopInfo()
    for i, cmp in ipairs(self.topInfo) do
        cmp.root:SetActive(false)
    end
end

function RankListPlayerView:OnTopItemClick(index)
    local data = self.topData[index]
    if data then
        mod.PersonalInfoCtrl:OpenPersonalInfo({
            uid = data.role_uid
        })
    end
end