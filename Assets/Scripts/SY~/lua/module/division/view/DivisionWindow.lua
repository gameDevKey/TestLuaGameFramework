DivisionWindow = BaseClass("DivisionWindow",BaseWindow)

DivisionWindow.Event = EventEnum.New(
    "RefreshRewardState"
)

function DivisionWindow:__Init()
    self:SetAsset("ui/prefab/division/division_main_window.prefab",AssetType.Prefab)
    self.nodes = {} -- 节点信息数据对象等

    self.cardPos = {
        x = {
            [1] = {222.5},
            [2] = {147.5,297.5},
            [3] = {72.5,222.5,372.5},
            [4] = {0,150,300,450}
        },
        y = -166
    }

end

function DivisionWindow:__Delete()
end

function DivisionWindow:__CacheObject()
    self.scrollView = self:Find("main/scroll_view/viewport/content")
    self.nodeTemp = self:Find("main/templete/node").gameObject
    self.divisionTemp = self:Find("main/templete/division").gameObject
    self.trophyRewardTemp = self:Find("main/templete/trophy_reward").gameObject
    self.trophyBubble = self:Find("main/trophy_bubble")
    self.backBtnTop = self:Find("main/back_btn_top").gameObject
    self.backBtnBottom = self:Find("main/back_btn_bottom").gameObject
end

function DivisionWindow:__Create()
    self:Find("main/bottom_con/confirm_btn/text",Text).text = TI18N("确认")
    local divisionCfg, trophyRewardCfg = mod.DivisionProxy:GetNodeData()
    self:SetStageNode(divisionCfg, trophyRewardCfg)
end

function DivisionWindow:__BindListener()
    self:Find("main/back_btn_top",Button):SetClick( self:ToFunc("BackToCurrStage") )
    self:Find("main/back_btn_bottom",Button):SetClick( self:ToFunc("BackToCurrStage") )
    self:Find("main/bottom_con/confirm_btn",Button):SetClick( self:ToFunc("OnCloseClick") )
end

function DivisionWindow:__BindEvent()
    self:BindEvent(DivisionWindow.Event.RefreshRewardState)
end

function DivisionWindow:__Show()
    -- self.roleData = {division = 16, trophy = 200000} -- TODO设置调试数据
    self.roleData = mod.RoleProxy:GetRoleData()
    self:SetDivisionData()

    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_open, "division")
end

function DivisionWindow:RefreshRewardState(rewardData)
    for i = 1, #self.nodes do
        if self.nodes[i].trophyRewardId and self.nodes[i].trophyRewardId == rewardData.reward_id then
            self.nodes[i].obtainedMark:SetActive(rewardData.state == 2)
            return
        end
    end
end

function DivisionWindow:SetStageNode(divisionCfg, trophyRewardCfg)
    local nodeIndex = 1
    for i = 1, #divisionCfg do
        self:CreateDivisionNode(divisionCfg[i],nodeIndex,i)
        nodeIndex = nodeIndex + 1
        local list = trophyRewardCfg[i]
        if list then
            for j = 1, #list do
                self:CreateTrophyRewardNode(list[j],nodeIndex,i)
                nodeIndex = nodeIndex + 1
            end
        end
    end
    -- 修短最后一段进度条
    local lastSlider = self.nodes[nodeIndex-1].slider.transform
    local sliderWidth = lastSlider.sizeDelta.x
    local sliderHeight = lastSlider.sizeDelta.y
    local sliderPosX = lastSlider.anchoredPosition.x
    local sliderPosY = lastSlider.anchoredPosition.y
    sliderHeight = sliderHeight/2
    sliderPosY = sliderPosY - sliderHeight
    UnityUtils.SetSizeDelata(lastSlider,sliderWidth,sliderHeight)
    UnityUtils.SetAnchoredPosition(lastSlider,sliderPosX,sliderPosY)
    self.nodes[nodeIndex-1].notchedNum.text = ""
end

function DivisionWindow:CreateDivisionNode(cfg,index,belongDivision)
    local nodeObj = GameObject.Instantiate(self.nodeTemp)
    local node = {}
    node.gameObject = nodeObj
    node.transform = nodeObj.transform
    node.transform:SetParent(self.scrollView)
    node.transform:Reset()
    local offsetMin = node.transform.offsetMin
    local offsetMax = node.transform.offsetMax
    node.transform.offsetMin = Vector2(0,offsetMin.y)
    node.transform.offsetMax = Vector2(0,offsetMax.y)

    node.slider = node.transform:Find("slider"):GetComponent(Slider)                                   -- 进度条
    node.filled = node.transform:Find("slider/fill_area/filled").gameObject                            -- 进度条满时打开，填充圆角矩形
    node.fillStart = node.transform:Find("slider/fill_area/fill_start").gameObject                     -- 第一个进度条打开
    node.fillEnd = node.transform:Find("slider/fill_area/fill_end").gameObject                         -- 超出段位上限时打开
    node.fill = node.transform:Find("slider/fill_area/fill")                                           -- 杯数泡泡挂载点
    node.notchedNum = node.transform:Find("slider/dividing_line/notched_num"):GetComponent(Text)       -- 刻度值

    local division = GameObject.Instantiate(self.divisionTemp)
    node.stageType = node.transform:Find("stage_type")                                                 -- 段位结点克隆的挂载点
    division.transform:SetParent(node.stageType)
    division.transform:Reset()
    division.transform:Find("unlock_cards/title"):GetComponent(Text).text = TI18N("解锁卡牌：")
    node.name = division.transform:Find("title/bg/name"):GetComponent(Text)                            -- 段位名称
    node.requiredNum = division.transform:Find("title/bg/required_num"):GetComponent(Text)             -- 段位所需杯数文本
    node.leagueMatch = division.transform:Find("title/league_match_bg").gameObject                     -- 联赛标签（未作动态高度处理）

    node.unlockCardsObj = division.transform:Find("unlock_cards").gameObject                           -- 该段位有待解锁卡牌时打开
    node.unlockCardsParent = division.transform:Find("unlock_cards/unlock_cards_con")                  -- 待解锁卡牌父节点
    node.unlockCard = division.transform:Find("unlock_cards/unlock_cards_con/unlock_card").gameObject  -- 待解锁卡牌模板

    -- TODO 根据配置设置相关显示，若接入动态无限滚动窗口组件，以下工作应放在另一个函数中并在无限滚动窗口刷新时调用
    -- 设置title
    node.name.text = TI18N(cfg.remark)
    node.requiredNum.text = cfg.trophy
    node.belongDivision = belongDivision                                                                -- 段位id
    node.trophyRequired = cfg.trophy                                                                    -- 设置段位所需杯数
    -- 设置待解锁卡牌
    local unlockConHeight = 0
    local unlockCardsObjHeight = 0
    local divisionHeight = 0
    node.unlocakCardList = {}
    if next(cfg.unlock_list) ~= nil then
        -- 若待解锁卡牌不为空，克隆并显示，最后根据数量动态设置布局，根据行数设置高度
        node.unlockCardsObj:SetActive(true)
        node.unlockCard:SetActive(true)
        for i = 1, #cfg.unlock_list do
            local card = GameObject.Instantiate(node.unlockCard)
            card.transform:SetParent(node.unlockCardsParent)
            card.transform:Reset()
            self:SetSprite(card.transform:Find("icon"):GetComponent(Image),AssetPath.GetUnitIconCollection(cfg.unlock_list[i]),false)
            UIUtils.Grey(card.transform:Find("icon"):GetComponent(Image),true)
            local quality = Config.UnitData.data_unit_info[cfg.unlock_list[i]].quality
            self:SetSprite(card.transform:Find("quality"):GetComponent(Image),AssetPath.QualityFrame[quality])
            card.transform:Find("bg"):GetComponent(Button):SetClick( self:ToFunc("ShowCardDetailPanel"),cfg.unlock_list[i] )
            table.insert(node.unlocakCardList,card)
        end
        node.unlockCard:SetActive(false)
        local total = #node.unlocakCardList
        local row = math.ceil( total/4 )
        local cardIndex = 1
        for i = 1, row do
            if total >= 4 then
                for j = 1, 4 do
                    UnityUtils.SetAnchoredPosition(node.unlocakCardList[cardIndex].transform, self.cardPos.x[4][j], self.cardPos.y * (i-1))
                    cardIndex = cardIndex + 1
                end
                total = total - 4
            else
                for j = 1, total do
                    UnityUtils.SetAnchoredPosition(node.unlocakCardList[cardIndex].transform, self.cardPos.x[total][j], self.cardPos.y * (i-1))
                    cardIndex = cardIndex + 1
                end
            end
        end
        unlockConHeight = row * 145
        local unlockConWidth = node.unlockCardsParent.sizeDelta.x
        UnityUtils.SetSizeDelata(node.unlockCardsParent,unlockConWidth,unlockConHeight)
        local unlockCardsObjWidth = node.unlockCardsObj.transform.sizeDelta.x
        unlockCardsObjHeight = unlockConHeight - node.unlockCardsParent.anchoredPosition.y
        UnityUtils.SetSizeDelata(node.unlockCardsObj.transform,unlockCardsObjWidth,unlockCardsObjHeight)
        divisionHeight = unlockCardsObjHeight - node.unlockCardsObj.transform.anchoredPosition.y
    else
        -- 若无待解锁卡牌，高度与段位标题背景相关
        node.unlockCardsObj:SetActive(false)
        local title = division.transform:Find("title")
        divisionHeight = title.sizeDelta.y - title.anchoredPosition.y
    end

    local divisionWidth = division.transform.sizeDelta.x
    UnityUtils.SetSizeDelata(division.transform,divisionWidth,divisionHeight)     -- 设置段位类型结点的最终高度
    UnityUtils.SetSizeDelata(node.stageType,divisionWidth,divisionHeight)         -- 设置段位类型结点父节点的最终高度
    local nodeWidth = node.transform.sizeDelta.x
    local nodeHeight = divisionHeight - node.stageType.anchoredPosition.y
    UnityUtils.SetSizeDelata(node.transform,nodeWidth,nodeHeight)                 -- 根据段位类型结点父节点的位置y与高度计算出该节点node高度并设置
    node.height = nodeHeight
    local nodeY = 0
    if index > 1 then
        nodeY = self.nodes[index - 1].height + self.nodes[index - 1].posY

        -- 设置上一个节点的进度条长度与y值
        local lastSlider = self.nodes[index - 1].slider.transform
        local sliderWidth = lastSlider.sizeDelta.x
        local sliderHeight = lastSlider.sizeDelta.y
        local sliderPosX = lastSlider.anchoredPosition.x
        local sliderPosY = lastSlider.anchoredPosition.y
        sliderHeight = sliderHeight + divisionHeight
        sliderPosY = sliderPosY + divisionHeight
        UnityUtils.SetSizeDelata(lastSlider,sliderWidth,sliderHeight)
        UnityUtils.SetAnchoredPosition(lastSlider,sliderPosX,sliderPosY)

        -- 设置上一个节点的刻度值
        self.nodes[index - 1].notchedNum.text = cfg.trophy
    else
        node.fillStart:SetActive(true) -- 如果是第一个节点设置进度条开头为true
        nodeY = 130
    end
    local nodeX = node.transform.anchoredPosition.x
    UnityUtils.SetAnchoredPosition(node.transform,nodeX,nodeY)                     -- 设置节点node位置
    node.posY = nodeY
    table.insert(self.nodes,node)
    -- 更新ScrollView.Content的高度
    local scrollWidth = self.scrollView.sizeDelta.x
    local scrollHeight = self.scrollView.sizeDelta.y
    UnityUtils.SetSizeDelata(self.scrollView,scrollWidth,scrollHeight + nodeHeight)
end

function DivisionWindow:CreateTrophyRewardNode(cfg,index,belongDivision)
    local nodeObj = GameObject.Instantiate(self.nodeTemp)
    local node = {}
    node.gameObject = nodeObj
    node.transform = nodeObj.transform
    node.transform:SetParent(self.scrollView)
    node.transform:Reset()
    local offsetMin = node.transform.offsetMin
    local offsetMax = node.transform.offsetMax
    node.transform.offsetMin = Vector2(0,offsetMin.y)
    node.transform.offsetMax = Vector2(0,offsetMax.y)

    node.slider = node.transform:Find("slider"):GetComponent(Slider)                                     -- 进度条
    node.filled = node.transform:Find("slider/fill_area/filled").gameObject                              -- 进度条满时打开，填充圆角矩形
    node.fillStart = node.transform:Find("slider/fill_area/fill_start").gameObject                       -- 第一个进度条打开
    node.fillEnd = node.transform:Find("slider/fill_area/fill_end").gameObject                           -- 超出当前段位上限时打开
    node.fill = node.transform:Find("slider/fill_area/fill")                                             -- 杯数泡泡挂载点
    node.notchedNum = node.transform:Find("slider/dividing_line/notched_num"):GetComponent(Text)         -- 刻度值

    local trophyReward = GameObject.Instantiate(self.trophyRewardTemp)
    node.stageType = node.transform:Find("stage_type")                                                   -- 杯数奖励结点克隆的挂载点
    trophyReward.transform:SetParent(node.stageType)
    trophyReward.transform:Reset()
    node.rewardBg = trophyReward.transform:Find("reward_con/bg"):GetComponent(Image)                     -- 杯数奖励背景 未开启的段位为暗色 texture/division/division_4 ，已开启的段位为亮色 division_11
    node.rewardScenery = trophyReward.transform:Find("reward_con/scenery"):GetComponent(Image)           -- 杯数奖励场景 未开启的段位关闭，已开启的段位打开，已自动根据奇偶设置样式
    node.rewardItemBg = trophyReward.transform:Find("reward_con/reward_bg"):GetComponent(Image)          -- 杯数奖励道具的背景 未开启的段位为暗色 texture/division/division_15 ，已开启的段位为亮色 division_14
    node.rewardBtn = trophyReward.transform:Find("reward_con/reward_bg"):GetComponent(Button)            -- 杯数奖励道具的按钮 点击尝试领取该奖励
    node.rewardImg = {
        single = {                                                                                       -- 奖励为单个时自动设置到此处
            obj = trophyReward.transform:Find("reward_con/reward_bg/single").gameObject,
            img = trophyReward.transform:Find("reward_con/reward_bg/single/img"):GetComponent(Image),
            num = trophyReward.transform:Find("reward_con/reward_bg/single/num"):GetComponent(Text)
        },
        double = {                                                                                       -- 奖励为双数时自动设置到此处，后续可能会有多个奖励的情况，在此处拓展为循环方法
            obj = trophyReward.transform:Find("reward_con/reward_bg/double").gameObject,
            img_1 = trophyReward.transform:Find("reward_con/reward_bg/double/img_1"):GetComponent(Image),
            num_1 = trophyReward.transform:Find("reward_con/reward_bg/double/num_1"):GetComponent(Text),
            img_2 = trophyReward.transform:Find("reward_con/reward_bg/double/img_2"):GetComponent(Image),
            num_2 = trophyReward.transform:Find("reward_con/reward_bg/double/num_2"):GetComponent(Text)
        }
    }
    node.obtainedMark = trophyReward.transform:Find("reward_con/reward_bg/obtained_mark").gameObject --奖励已领取的标记记号

    -- TODO 根据配置设置相关显示，若接入动态无限滚动窗口组件，以下工作应放在另一个函数中并在无限滚动窗口刷新时调用
    node.trophyRewardId = cfg.id                                                                         -- 杯数奖励id，用于发送协议
    node.trophyRequired = cfg.trophy                                                                     -- 杯数奖励满足该数量才能领取
    node.belongDivision = belongDivision                                                                 -- 杯数奖励所属的段位，若当前段位低于此字段则设置暗色
    if index%2 == 0 then -- 设置奖励区域在左侧还是右侧
        self:SetSprite(node.rewardScenery,UITex("division/division_8"),true)
        UnityUtils.SetAnchoredPosition(node.rewardScenery.transform,132,20)
        UnityUtils.SetAnchoredPosition(node.rewardItemBg.transform,-145,20)
    else
        self:SetSprite(node.rewardScenery,UITex("division/division_10"),true)
        UnityUtils.SetAnchoredPosition(node.rewardScenery.transform,-145,20)
        UnityUtils.SetAnchoredPosition(node.rewardItemBg.transform,132,20)
    end
    if #cfg.item_list == 1 then -- 设置奖励预览
        node.rewardImg.single.obj:SetActive(true)
        node.rewardImg.double.obj:SetActive(false)
        local itemCfg = Config.ItemData.data_item_info[cfg.item_list[1][1]]
        self:SetSprite(node.rewardImg.single.img, AssetPath.GetUnitIconCollection(cfg.item_list[1][1]),false)
        local quality = itemCfg.type == GDefine.ItemType.currency and cfg.item_list[1][1] == 1 and 2 or 5 or itemCfg.quality
        node.rewardImg.single.num.text = UIUtils.GetTextColorByQuality(cfg.item_list[1][2], quality, true)
    elseif #cfg.item_list == 2 then
        node.rewardImg.single.obj:SetActive(false)
        node.rewardImg.double.obj:SetActive(true)
        local itemCfg1 = Config.ItemData.data_item_info[cfg.item_list[1][1]]
        self:SetSprite(node.rewardImg.double.img_1, AssetPath.GetUnitIconCollection(cfg.item_list[1][1]),false)
        local quality1 = itemCfg1.type == GDefine.ItemType.currency and cfg.item_list[1][1] == 1 and 2 or 5 or itemCfg1.quality
        node.rewardImg.double.num_1.text = UIUtils.GetTextColorByQuality(cfg.item_list[1][2], quality1, true)
        local itemCfg2 = Config.ItemData.data_item_info[cfg.item_list[2][1]]
        self:SetSprite(node.rewardImg.double.img_2, AssetPath.GetUnitIconCollection(cfg.item_list[2][1]),false)
        local quality2 = itemCfg1.type == GDefine.ItemType.currency and cfg.item_list[2][1] == 1 and 2 or 5 or itemCfg2.quality
        node.rewardImg.double.num_2.text = UIUtils.GetTextColorByQuality(cfg.item_list[2][2], quality2, true)
    end
    node.rewardBtn:SetClick( self:ToFunc("ObtainReward"),node.belongDivision,node.trophyRequired,node.trophyRewardId)

    local trophyRewardWidth = trophyReward.transform.sizeDelta.x
    local trophyRewardHeight = trophyReward.transform.sizeDelta.y
    UnityUtils.SetSizeDelata(node.stageType,trophyRewardWidth,trophyRewardHeight)
    local nodeWidth = node.transform.sizeDelta.x
    local nodeHeight = trophyRewardHeight - node.stageType.anchoredPosition.y
    UnityUtils.SetSizeDelata(node.transform,nodeWidth,nodeHeight)
    node.height = nodeHeight
    local nodeY = 0
    if index > 1 then
        nodeY = self.nodes[index - 1].height + self.nodes[index - 1].posY

        -- 设置上一个节点的进度条长度与y值
        local lastSlider = self.nodes[index - 1].slider.transform
        local sliderWidth = lastSlider.sizeDelta.x
        local sliderHeight = lastSlider.sizeDelta.y
        local sliderPosX = lastSlider.anchoredPosition.x
        local sliderPosY = lastSlider.anchoredPosition.y
        sliderHeight = sliderHeight + trophyRewardHeight
        sliderPosY = sliderPosY + trophyRewardHeight
        UnityUtils.SetSizeDelata(lastSlider,sliderWidth,sliderHeight)
        UnityUtils.SetAnchoredPosition(lastSlider,sliderPosX,sliderPosY)

        -- 设置上一个节点的刻度值
        self.nodes[index - 1].notchedNum.text = node.trophyRequired
    else
        node.fillStart:SetActive(true) -- 如果是第一个节点设置进度条开头为true
        nodeY = 130
    end
    local nodeX = node.transform.anchoredPosition.x
    UnityUtils.SetAnchoredPosition(node.transform,nodeX,nodeY)
    node.posY = nodeY
    table.insert(self.nodes,node)
    -- 更新ScrollView.Content的高度
    local scrollWidth = self.scrollView.sizeDelta.x
    local scrollHeight = self.scrollView.sizeDelta.y
    UnityUtils.SetSizeDelata(self.scrollView,scrollWidth,scrollHeight + nodeHeight)
end

function DivisionWindow:SetDivisionData()
    local curNodeIndex = 1
    for i = 1, #self.nodes do
        local node = self.nodes[i]
        if node.rewardBg then -- 杯数奖励节点
            if node.belongDivision <= self.roleData.division then
                self:SetSprite(node.rewardBg,UITex("division/division_11"))
                node.rewardScenery.gameObject:SetActive(true)
                if node.trophyRequired <= self.roleData.trophy then
                    self:SetSprite(node.rewardItemBg,UITex("division/division_14"))
                    if mod.DivisionProxy:GetTrophyRewardState(node.trophyRewardId) == DivisionDefine.RewardStatus.Receive then
                        node.obtainedMark:SetActive(true)
                    else
                        node.obtainedMark:SetActive(false)
                    end
                else
                    self:SetSprite(node.rewardItemBg,UITex("division/division_15"))
                end
            else
                self:SetSprite(node.rewardBg,UITex("division/division_4"))
                node.rewardScenery.gameObject:SetActive(false)
            end
        end

        if node.belongDivision <= self.roleData.division then
            if node.trophyRequired <= self.roleData.trophy then
                node.slider.value = 1
                node.filled:SetActive(true)
                curNodeIndex = i
            else
                node.slider.value = 0
                node.filled:SetActive(false)
            end
        else
            node.slider.value = 0
            node.filled:SetActive(false)
        end
    end
    local val = 0
    local isLimit = false -- 超出当前极限段位
    if curNodeIndex < #self.nodes then
        val = (self.roleData.trophy-self.nodes[curNodeIndex].trophyRequired) / (self.nodes[curNodeIndex+1].trophyRequired - self.nodes[curNodeIndex].trophyRequired)
    else
        if self.roleData.trophy > self.nodes[curNodeIndex].trophyRequired then
            val = 1
            self.nodes[curNodeIndex-1].filled:SetActive(true)
            self.nodes[curNodeIndex-1].fillEnd:SetActive(true)
            isLimit = true
        else
            val = 0
            self.nodes[curNodeIndex-1].filled:SetActive(false)
            self.nodes[curNodeIndex-1].fillEnd:SetActive(false)
        end
    end
    if val < 0 then
        val = 0
    elseif val > 1 then
        val = 1
    end
    self.nodes[curNodeIndex].slider.value = val
    self.nodes[curNodeIndex].filled:SetActive(val == 1)
    self.nodes[curNodeIndex].fillEnd:SetActive(isLimit)
    self.trophyBubble:SetParent(self.nodes[curNodeIndex].fill)
    self.trophyBubble:Reset()
    local bubblePosY = self.nodes[curNodeIndex].slider.transform.sizeDelta.y * val
    if isLimit then
        bubblePosY = bubblePosY +10
    end
    UnityUtils.SetAnchoredPosition(self.trophyBubble,71.5,bubblePosY)
    self.trophyBubble:SetParent(self.scrollView) -- 防遮挡、方便设置contentY
    self.trophyBubble:Find("text"):GetComponent(Text).text = self.roleData.trophy

    --设置content的y值为杯数泡泡的-y+640
    local contentY = -self.trophyBubble.anchoredPosition.y + 640
    contentY = contentY < 0 and contentY or 0
    UnityUtils.SetAnchoredPosition(self.scrollView,0,contentY)
end

function DivisionWindow:BackToCurrStage()
    --TODO 判断杯数泡泡不在视窗时显现该按钮 点击后dotween滚动至杯数泡泡在屏幕中间
end

function DivisionWindow:ObtainReward(belongDivision,requiredNum,trophyRewardId)
    if mod.DivisionProxy:GetTrophyRewardState(trophyRewardId) == DivisionDefine.RewardStatus.Receive then
        return
    end
    if self.roleData.division < belongDivision then
        local divisionName = Config.DivisionData.data_division_info[belongDivision].remark
        SystemMessage.Show(TI18N(string.format("段位达到%s开放",divisionName)))
        return
    end
    if self.roleData.trophy < requiredNum then
        SystemMessage.Show(TI18N(string.format("奖杯数达到%s可领取",requiredNum)))
        return
    end
    mod.DivisionFacade:SendMsg(10601,trophyRewardId)
end

function DivisionWindow:ShowCardDetailPanel(id)
    Log(string.format("打开id为%s的详情界面",id)) --TODO 打开卡牌详情界面
end

function DivisionWindow:OnCloseClick()
    for k, v in pairs(self.nodes) do
        GameObject.Destroy(v)
    end
    ViewManager.Instance:CloseWindow(DivisionWindow)
end