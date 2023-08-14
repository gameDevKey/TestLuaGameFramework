BattleHeroGridView = BaseClass("BattleHeroGridView",ExtendView)

BattleHeroGridView.Event = EventEnum.New(
    "RefreshHeroGrid",
    "RefreshExtGrid",
    "LimitSwapGird",
    "EnableGridTips",
    "EnableRecycle",
    "EnableSaleCard",
    "AddSaleCardCallback",
    "ShowEffectOnGrid"
)

function BattleHeroGridView:__Init()
    self.OnTriggerEnter = self:ToFunc("HeroGridTriggerEnter")
	self.OnTriggerExit = self:ToFunc("HeroGridTriggerExit")

    self.dragGrid = 0
    self.targetGrid = 0
    self.dragEnterGrids = {}
    self.gridDragObjects = nil

    self.maxStar = 0
    self.clickShowGridTips = false
    self.timer = nil

    self.limitSwapGird = nil
    self.enableGridTips = true
    self.enableRecycle = true
    self.enableSaleCard = true
    self.onSaleCard = nil
end

function BattleHeroGridView:__Delete()

end

function BattleHeroGridView:__CacheObject()
    self.obstacle = self:Find("main/operate/obstacle").gameObject
    self.gridItem = self:Find("main/operate/hero_grid_con/hero_grid").gameObject
    self.gridParent =  self:Find("main/operate/hero_grid_con")

    self.gridDragObjects = {}
    local item = self:Find("main/operate_objects/drag_hero_grid_item")
    self.gridDragObjects.gameObject = item.gameObject
    self.gridDragObjects.transform = item.transform
    self.gridDragObjects.normalNode = item:Find("normal").gameObject
    self.gridDragObjects.mainNode =  item:Find("normal/main").gameObject
    self.gridDragObjects.qualityBg = item:Find("normal/main/quality_bg").gameObject:GetComponent(Image)
    self.gridDragObjects.headIcon = item:Find("normal/main/icon").gameObject:GetComponent(Image)
    self.gridDragObjects.qualityFrame = item:Find("normal/main/quality_frame").gameObject:GetComponent(Image)
    self.gridDragObjects.starNode = item:Find("normal/main/star_node").gameObject
    self.gridDragObjects.starNum = item:Find("normal/main/star_node/num").gameObject:GetComponent(Text)
    self.gridDragObjects.starMax = item:Find("normal/main/star_max").gameObject
    self.gridDragObjects.job = item:Find("normal/main/job").gameObject:GetComponent(Image)

    self.gridDragObjects.uiTrigger = item:Find("trigger").gameObject:AddComponent(UITrigger)
    self.gridDragObjects.uiTrigger:SetOwner(self,"OnTriggerEnter","OnTriggerExit")
    self.gridDragObjects.uiTrigger.isTriggerEnter = true
    self.gridDragObjects.uiTrigger.isTriggerExit = true
    self.gridDragObjects.uiTrigger.group = "hero_grid"

    self:SetRecycleNode()
end

function BattleHeroGridView:__BindEvent()
    self:BindEvent(BattleFacade.Event.CancelOperate)
    self:BindEvent(BattleHeroGridView.Event.RefreshHeroGrid)
    self:BindEvent(BattleHeroGridView.Event.RefreshExtGrid)
    self:BindEvent(BattleHeroGridView.Event.LimitSwapGird)
    self:BindEvent(BattleHeroGridView.Event.EnableGridTips)
    self:BindEvent(BattleHeroGridView.Event.EnableRecycle)
    self:BindEvent(BattleHeroGridView.Event.EnableSaleCard)
    self:BindEvent(BattleHeroGridView.Event.AddSaleCardCallback)
    self:BindEvent(BattleHeroGridView.Event.ShowEffectOnGrid)
end

function BattleHeroGridView:__BindListener()

end

function BattleHeroGridView:__Hide()
    if self.battleHeroDetailsPanel then
        self.battleHeroDetailsPanel:Destroy()
    end
    self.battleHeroDetailsPanel = nil

    for i, v in ipairs(self.gridItems) do
        GameObject.Destroy(v.gameObject)
    end
end

function BattleHeroGridView:__Create()
    self.gridItems = {}
    local col = 5
    for i=1,BattleDefine.GridNum do
        local item = GameObject.Instantiate(self.gridItem)
        item.transform:SetParent(self.gridParent)
        item.transform:Reset()
        local x = math.fmod(i-1,col) * 122 - 244
        local y = math.floor((i-1)/col) * (-136) + 136
        
        --TODO:临时战斗代码
        if RunWorld.BattleDataSystem.pvpConf.id == 8 then
            item.transform:SetLocalScale(1,0.7,1)
            y = math.floor((i-1)/col) * (-95) + 159
        end

        UnityUtils.SetAnchoredPosition(item.transform, x, y)

        local object = {}
        object.gameObject = item
        object.transform = item.transform
        object.normalNode = item.transform:Find("normal").gameObject
        object.mainNode =  item.transform:Find("normal/main").gameObject
        object.qualityBg = item.transform:Find("normal/main/quality_bg").gameObject:GetComponent(Image)
        object.headIcon = item.transform:Find("normal/main/icon").gameObject:GetComponent(Image)
        object.qualityFrame = item.transform:Find("normal/main/quality_frame").gameObject:GetComponent(Image)
        object.starNode = item.transform:Find("normal/main/star_node").gameObject
        object.starNum = item.transform:Find("normal/main/star_node/num").gameObject:GetComponent(Text)
        object.starMax = item.transform:Find("normal/main/star_max").gameObject
        object.job = item.transform:Find("normal/main/job").gameObject:GetComponent(Image)

        object.lockNode = item.transform:Find("lock").gameObject

        object.extInfoNode = item.transform:Find("lock/ext_info").gameObject
        object.extCostText = item.transform:Find("lock/ext_info/cost").gameObject:GetComponent(Text)

        --object.boxIcon = item.transform:Find("main/box").gameObject:GetComponent(Image)
        --object.maskNode = item.transform:Find("main/mask").gameObject

        object.eventTrigger = item.gameObject:AddComponent(EventSystems.EventTrigger)

        object.uiTriggerTarget = item.transform:Find("trigger").gameObject:AddComponent(UITriggerTarget)
        object.uiTriggerTarget.args = {index = i}
        object.uiTriggerTarget.group = "hero_grid"

        table.insert(self.gridItems,object)

        object.gameObject:SetActive(RunWorld.BattleDataSystem:CanExtGrid(i) and BattleDefine.ViewSlotIndex[i])
        object.normalNode:SetActive(false)
    end

    self.maxStar = RunWorld.BattleDataSystem.pvpConf.star_up_count_limit
    self.obstacle:SetActive(RunWorld.BattleDataSystem.pvpConf.max_embattle_count == 5)
    self.roleUid = RunWorld.BattleDataSystem.roleUid
end

--TODO:可以优化下效率
function BattleHeroGridView:RefreshHeroGrid()
    for i=1,BattleDefine.GridNum do
        local object = self.gridItems[i]

        local isUnlock = RunWorld.BattleDataSystem:IsUnlockGrid(self.roleUid,i)
        local heroGridInfo = RunWorld.BattleDataSystem:GetUnitDataByGrid(self.roleUid,i)

        object.normalNode:SetActive(isUnlock)
        object.lockNode:SetActive(not isUnlock)

        object.eventTrigger:ClearEvent()
        self:SetHeroGridItem(object,heroGridInfo)
        if heroGridInfo then
            object.eventTrigger:SetEvent(EventSystems.EventTriggerType.PointerDown,self:ToFunc("HeroGridDown"),i)
        end
    end

    self:RefreshExtGrid()
end

function BattleHeroGridView:RefreshExtGrid()
    for i=1,BattleDefine.GridNum do
        local object = self.gridItems[i]

        local isUnlock = RunWorld.BattleDataSystem:IsUnlockGrid(self.roleUid,i)

        if isUnlock then
            object.extInfoNode:SetActive(false)
        else
            if not RunWorld.BattleDataSystem:CanExtGrid(i) then
                object.extInfoNode:SetActive(false)
            else
                object.extInfoNode:SetActive(true)
                local needMoney = RunWorld.BattleDataSystem:GetExtendMoney(self.roleUid)
                local flag = RunWorld.BattleDataSystem:HasMoney(self.roleUid,needMoney)
                local color = flag and "63E73C" or "E73C3C"
                object.extCostText.text = string.format("<color='#%s'>SP:%s</color>",color,needMoney)
                object.eventTrigger:SetEvent(EventSystems.EventTriggerType.PointerDown,self:ToFunc("ExtendHeroGrid"),i)
            end
        end
    end
end

function BattleHeroGridView:SetRecycleNode()
    self.recycleNode = self:Find("main/operate/recycle_node").gameObject
    self.recycleAddNum = self:Find("main/operate/recycle_node/add_num").gameObject:GetComponent(Text)

    local recycleTriggerTarget = self.recycleNode:AddComponent(UITriggerTarget)
    recycleTriggerTarget.args = {index = -1}
    recycleTriggerTarget.group = "hero_grid"

    self.recycleNode:SetActive(false)
end

function BattleHeroGridView:ExtendHeroGrid(pointerData,index)
    local needMoney = RunWorld.BattleDataSystem:GetExtendMoney(self.roleUid)
    local flag = RunWorld.BattleDataSystem:HasMoney(self.roleUid,needMoney)
    if not flag then
        SystemMessage.Show(TI18N("能量不足，请等待回合开始时补充"))
        return
    end

    RunWorld.BattleInputSystem:AddExtendGrid(index)
end

function BattleHeroGridView:HeroGridDown(pointerData,index)
    -- Log("按下英雄了")

    if pointerData.pointerId < -1 or self.pointerId then 
        return
    end

    if self.enableGridTips then
        self.clickShowGridTips = true
        self.timer = TimerManager.Instance:AddTimer(1,0.2, function()
            self.clickShowGridTips = false
        end)
    end

    self.pointerId = pointerData.pointerId

    self.dragEnterGrids[index] = true
    self.dragGrid = index
    self.targetGrid = self.dragGrid

    self.gridDragObjects.uiTrigger.args = {index = index}

    local heroGridInfo = RunWorld.BattleDataSystem:GetUnitDataByGrid(self.roleUid,index)

    local objects = self.gridItems[index]
    objects.normalNode:SetActive(false)

    local parent = self.gridDragObjects.transform.parent

    self.gridDragObjects.gameObject:SetActive(true)

    self:SetHeroGridItem(self.gridDragObjects,heroGridInfo)

    self.gridDragObjects.transform:SetParent(objects.transform)
    self.gridDragObjects.transform:SetAnchoredPosition(0,0)

    self.gridDragObjects.transform:SetParent(parent)

    self.moveListenId = TouchManager.Instance:AddListen(TouchDefine.TouchEvent.move,self:ToFunc("HeroGridDrag"),self.pointerId)
    self.cancelListenId = TouchManager.Instance:AddListen(TouchDefine.TouchEvent.cancel,self:ToFunc("HeroGridCancel"),self.pointerId)
end

function BattleHeroGridView:HeroGridDrag(touchData)
   -- Log("拖动了")
    if not self.recycleNode.gameObject.activeSelf and self.enableRecycle then
        self.recycleNode:SetActive(true)
        mod.BattleFacade:SendEvent(BattleInfoView.Event.ActiveCurMoney,false)
        local addMoney = RunWorld.BattleDataSystem:GetHeroSellMoney(self.roleUid, self.dragGrid)
        self.recycleAddNum.text = "+"..tostring(addMoney)
    end

    if self.clickShowGridTips then
        self.clickShowGridTips = false
        self:RemoveTimer()
    end

    local _,toPos = RectTransformUtility.ScreenPointToLocalPointInRectangle(self.gridDragObjects.transform.parent,Vector2(touchData.pos.x,touchData.pos.y),UIDefine.uiCamera)
    --local x = self.heroDragObjects.transform.anchoredPosition.x + touchData.deltaPos.x
    --local y = self.heroDragObjects.transform.anchoredPosition.y + touchData.deltaPos.y
    self.gridDragObjects.transform:SetAnchoredPosition(toPos.x,toPos.y)

    --Log("位置",self.gridDragObjects.transform.position.x,self.gridDragObjects.transform.position.y,self.gridDragObjects.transform.position.z)


    local dragPos = self.gridDragObjects.transform.position
    dragPos.z = 0

    local latelyGrid = self.dragGrid
    local minDis = nil
    for index,v in pairs(self.dragEnterGrids) do
        local objects = index == -1 and self.recycleNode or self.gridItems[index]
        local gridPos = objects.transform.position
        gridPos.z = 0

        local dis = (dragPos - gridPos).magnitude

        if not minDis or dis < minDis then
            latelyGrid = index
            minDis = dis
        end
    end

    self.targetGrid = latelyGrid
end

function BattleHeroGridView:HeroGridCancel(touchData)
    self.pointerId = nil

    self:RemoveListen()
    self:RemoveTimer()

    self.gridDragObjects.gameObject:SetActive(false)
    self.recycleNode:SetActive(false)
    mod.BattleFacade:SendEvent(BattleInfoView.Event.ActiveCurMoney,true)

    local objects = self.gridItems[self.dragGrid]
    objects.normalNode:SetActive(true)

    if self.clickShowGridTips then
        local heroGridInfo = RunWorld.BattleDataSystem:GetUnitDataByGrid(self.roleUid,self.dragGrid)
        self:ShowHeroDetails(heroGridInfo)
        return
    end

    if self.targetGrid == -1 then
        self:RecycleHandle()
    else
        self:SwapHandle()
    end

    self.dragGrid = 0
    self.targetGrid = 0
    self.dragEnterGrids = {}
end

function BattleHeroGridView:CancelOperate()
    if not self.pointerId then
        return
    end

    self.pointerId = nil

    self:RemoveListen()
    self:RemoveTimer()
    self.clickShowGridTips = false

    self.gridDragObjects.gameObject:SetActive(false)
    self.recycleNode:SetActive(false)
    mod.BattleFacade:SendEvent(BattleInfoView.Event.ActiveCurMoney,true)

    local objects = self.gridItems[self.dragGrid]
    objects.normalNode:SetActive(true)

    self.dragGrid = 0
    self.targetGrid = 0
    self.dragEnterGrids = {}
end

function BattleHeroGridView:SwapHandle()
    local flag = self.targetGrid ~= self.dragGrid

    if flag and self.limitSwapGird then
        if self.dragGrid ~= self.limitSwapGird.fromGrid or self.targetGrid ~= self.limitSwapGird.toGrid then
            flag = false
        end
    end

    if flag then
        -- 立即交换英雄信息 优化延迟感
        local fromObject = self.gridItems[self.dragGrid]
        local toObject = self.gridItems[self.targetGrid]
        local fromInfo = RunWorld.BattleDataSystem:GetUnitDataByGrid(self.roleUid,self.dragGrid)
        self:SetHeroGridItem(toObject,fromInfo)
        local toInfo = RunWorld.BattleDataSystem:GetUnitDataByGrid(self.roleUid,self.targetGrid)
        self:SetHeroGridItem(fromObject,toInfo)

        local flag = RunWorld.BattleInputSystem:AddSwapGrid(self.targetGrid,self.dragGrid)
        if flag then
            mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.swap_unit_grid,self.dragGrid,self.targetGrid)
        end
    end
end

function BattleHeroGridView:RecycleHandle()
    if self.enableSaleCard then
        RunWorld.BattleInputSystem:AddSellHero(self.dragGrid)
        -- 立即隐藏英雄信息 优化延迟感
        local object = self.gridItems[self.dragGrid]
        object.mainNode:SetActive(false)
        object.eventTrigger:ClearEvent()
    end

    if self.onSaleCard then
        local success = self.enableSaleCard
        self.onSaleCard(self.dragGrid,success)
    end
end

function BattleHeroGridView:SetHeroGridItem(itemObject,info)
    if not info then
        itemObject.mainNode:SetActive(false)
        return
    end
    itemObject.mainNode:SetActive(true)
    local unitConf = Config.UnitData.data_unit_info[info.unit_id]
    local headFile = AssetPath.GetUnitIconBattleOperate(unitConf.head)
    self:SetSprite(itemObject.headIcon,headFile)

    local path = AssetPath.QualityToBattleOperateGrid[unitConf.quality]
    self:SetSprite(itemObject.qualityBg,path.bg)
    self:SetSprite(itemObject.qualityFrame,path.frame)
    self:SetSprite(itemObject.job,AssetPath.JobToIcon[unitConf.job])

    itemObject.starNode:SetActive(info.star > 0 and info.star < self.maxStar)
    itemObject.starMax:SetActive(info.star == self.maxStar)
    if info.star > 0 then
        itemObject.starNum.text = info.star
    end
end

function BattleHeroGridView:RemoveListen()
    if self.moveListenId then
        TouchManager.Instance:RemoveListen(self.moveListenId)
        self.moveListenId = nil
    end
    if self.cancelListenId then
        TouchManager.Instance:RemoveListen(self.cancelListenId)
        self.cancelListenId = nil
    end
end

function BattleHeroGridView:HeroGridTriggerEnter(dragArgs,targetArgs)
    local dragIndex = dragArgs.index
    local targetIndex = targetArgs.index

    if targetIndex == -1 then
        self.dragEnterGrids[targetIndex] = true
    elseif RunWorld.BattleDataSystem:IsUnlockGrid(self.roleUid,targetIndex) then
        self.dragEnterGrids[targetIndex] = true
    end
end

function BattleHeroGridView:HeroGridTriggerExit(dragArgs,targetArgs)
    local dragIndex = dragArgs.index
    local targetIndex = targetArgs.index

    if dragIndex ~= targetIndex then
        self.dragEnterGrids[targetIndex] = nil
    end
end

function BattleHeroGridView:LimitSwapGird(limitSwapGird)
    self.limitSwapGird = limitSwapGird
end

function BattleHeroGridView:EnableGridTips(flag)
    self.enableGridTips = flag
end

function BattleHeroGridView:EnableRecycle(flag)
    self.enableRecycle = flag
end

function BattleHeroGridView:EnableSaleCard(flag)
    self.enableSaleCard = flag
end

function BattleHeroGridView:AddSaleCardCallback(callback)
    self.onSaleCard = callback
end

function BattleHeroGridView:RemoveTimer()
    if self.timer then
        TimerManager.Instance:RemoveTimer(self.timer)
        self.timer = nil
    end
end

function BattleHeroGridView:ShowHeroDetails(args)
    if self.battleHeroDetailsPanel == nil then
        self.battleHeroDetailsPanel = BattleHeroDetailsPanel.New()
        self.battleHeroDetailsPanel:SetParent(UIDefine.canvasRoot)
    end
    local data = RunWorld.BattleDataSystem:GetBaseUnitData(self.roleUid,args.unit_id)
    data.star = RunWorld.BattleDataSystem:GetHeroStarByUnitId(self.roleUid,args.unit_id)
    self.battleHeroDetailsPanel:SetData(data)
    self.battleHeroDetailsPanel:Show()
end

function BattleHeroGridView:ShowEffectOnGrid(grid,effectId,duration)
    if self.gridItems[grid] then
        self:LoadUIEffect({
            confId = effectId,
            parent = self.gridItems[grid].transform,
            order = self:GetOrder() + 1,
            lastTime = duration,
        },true)
    end
end