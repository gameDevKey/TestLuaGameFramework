BattleEnemyGridView = BaseClass("BattleEnemyGridView",ExtendView)

BattleEnemyGridView.Event = EventEnum.New(
    "RefreshEnemyHeroGrid",
    "ActiveEnemyUnitStar",
    "GetUIPosByUnitId",
    "RefreshGridUnlock"
)

function BattleEnemyGridView:__Init()
    self.grids = {}

    self.lastInfos = {}
    self.tailIndex = 1
    self.unlockNum = 0
end

function BattleEnemyGridView:__CacheObject()
    self.gridItem = self:Find("main/top_node/enemy_info/enemy_grids_list/grid_con/item").gameObject
    self.gridParent = self:Find("main/top_node/enemy_info/enemy_grids_list/grid_con")
end

function BattleEnemyGridView:__BindEvent()
    self:BindEvent(BattleEnemyGridView.Event.RefreshEnemyHeroGrid)
    self:BindEvent(BattleEnemyGridView.Event.ActiveEnemyUnitStar)
    self:BindEvent(BattleEnemyGridView.Event.GetUIPosByUnitId)
    self:BindEvent(BattleEnemyGridView.Event.RefreshGridUnlock)
end

function BattleEnemyGridView:CreateEnemyGrids()
    self.maxEmbattleCount = RunWorld.BattleDataSystem.pvpConf.max_embattle_count
    local col = 3
    for i = 1, 6 do
        local item = GameObject.Instantiate(self.gridItem)
        item.transform:SetParent(self.gridParent)
        item.transform:Reset()
        local x = math.fmod((i-1),col) * 51.5
        local y = -58 * math.floor((i-1)/col)
        UnityUtils.SetAnchoredPosition(item.transform,x,y)
        local grid = {}
        grid.gameObject = item
        grid.bg = item.transform:Find("bg").gameObject:GetComponent(Image)
        grid.btn = item.transform:Find("bg").gameObject:GetComponent(Button)
        grid.icon = item.transform:Find("bg/icon").gameObject:GetComponent(Image)
        grid.quality = item.transform:Find("bg/quality").gameObject:GetComponent(Image)
        grid.starNum = item.transform:Find("bg/star/star_num").gameObject:GetComponent(Text)
        grid.starMax = item.transform:Find("bg/star_max").gameObject
        grid.emptyNode = item.transform:Find("empty_node").gameObject
        grid.lockNode = item.transform:Find("lock_node").gameObject
        grid.args = nil
        table.insert(self.grids,grid)
    end
    self.gridItem:SetActive(false)
end

function BattleEnemyGridView:__Show()
    if next(self.grids) == nil then
        self:CreateEnemyGrids()
    end

    self:SetGridView()
end

function BattleEnemyGridView:__Hide()
    for k, v in pairs(self.grids) do
        if v.upStarEffect then
            v.upStarEffect:Delete()
            v.upStarEffect = nil
        end
        if v.downStarEffect then
            v.downStarEffect:Delete()
            v.downStarEffect = nil
        end
        v.bg.gameObject:SetActive(false)
        v.emptyNode:SetActive(false)
        v.lockNode:SetActive(true)
    end
    self.tailIndex = 1
    if self.battleUnitDetailsPanel then
        self.battleUnitDetailsPanel:Destroy()
    end
    self.battleUnitDetailsPanel = nil

    if self.battleHeroDetailsPanel then
        self.battleHeroDetailsPanel:Destroy()
    end
    self.battleHeroDetailsPanel = nil
    self.lastInfos = {}
end

function BattleEnemyGridView:RefreshEnemyHeroGrid()
    local enemyRoleUid = RunWorld.BattleDataSystem:GetEnemyRoleUid()
    local heroInfos = {}
    for i=1,BattleDefine.PlaceSlotNum do
        local heroGridInfo = RunWorld.BattleDataSystem:GetUnitDataByGrid(enemyRoleUid,i)
        if heroGridInfo ~= nil then
            heroInfos[heroGridInfo.unit_id] = heroGridInfo
        end
    end
    for k, v in pairs(heroInfos) do
        local info = self.lastInfos[k]
        if info == nil or next(info) == nil then
            local index = self.tailIndex
            self.lastInfos[k] = {index = index, info = v}  -- 远端有本地无：新增
            self.tailIndex = self.tailIndex + 1
        else
            self.lastInfos[k].info = v                              -- 远端有本地有：更新
        end
    end
    for k, v in pairs(self.lastInfos) do
        local info = heroInfos[k]
        if info == nil then
            local delIndex = self.lastInfos[k].index
            self.lastInfos[k] = nil                                 -- 远端无本地有：删除
            self.tailIndex = self.tailIndex - 1
            for k2, v2 in pairs(self.lastInfos) do
                if v2.index > delIndex then
                    v2.index = v2.index - 1  -- 被删除的格子后面的都往前一
                end
            end
        end
    end
    self:SetGridView()
    self:RefreshGridUnlock()
end

function BattleEnemyGridView:SetGridView()
    for k, v in pairs(self.lastInfos) do
        local grid = self.grids[v.index]
        local info = v.info

        local conf = RunWorld.BattleConfSystem:UnitData_data_unit_info(info.unit_id)
        self:SetSprite(grid.icon,AssetPath.GetUnitIconHead(conf.head),false)
        local path = AssetPath.QualityToBattleEnemyGrid[conf.quality]
        self:SetSprite(grid.bg,path.bg)
        self:SetSprite(grid.quality,path.quality)
        grid.starNum.text = info.star

        local isStarMax = info.star == RunWorld.BattleDataSystem.pvpConf.star_up_count_limit
        grid.starMax:SetActive(isStarMax)
        grid.btn:SetClick( self:ToFunc("ShowHeroDetails"),info )
        grid.bg.gameObject:SetActive(true)
        grid.emptyNode:SetActive(false)
    end
    for i = self.tailIndex, self.unlockNum do
        local grid = self.grids[i]
        if grid then
            grid.bg.gameObject:SetActive(false)
            grid.emptyNode:SetActive(true)
            grid.lockNode:SetActive(false)
        end
    end

    for i = self.maxEmbattleCount + 1, 6 do
        local grid = self.grids[i]
        if grid then
            grid.gameObject:SetActive(false)
        end
    end
end

function BattleEnemyGridView:ActiveEnemyUnitStar(unitId,offsetStar)
    if offsetStar == 0 then
        return
    end

    local info = self.lastInfos[unitId]
    if not info then
        return
    end

    local grid = self.grids[info.index]
    
    if offsetStar > 0 then
        --播放升星特效
        if not grid.upStarEffect then
            local setting = {}
            setting.confId = 5001012
            setting.parent = grid.gameObject.transform
            --TODO:层级需要优化
            setting.order = self.MainView.rootCanvas.sortingOrder + 1
            local effect = UIEffect.New()
            effect:Init(setting)
            effect:SetPos(22.5,-22.5)
            grid.upStarEffect = effect
        end

        grid.upStarEffect:Play()
    else
        --播放降星特效
        if not grid.downStarEffect then
            local setting = {}
            setting.confId = 5002012
            setting.parent = grid.gameObject.transform

            --TODO:层级需要优化
            setting.order = self.MainView.rootCanvas.sortingOrder + 1
    
            local effect = UIEffect.New()
            effect:Init(setting)
            effect:SetPos(22.5,-22.5)
            grid.downStarEffect = effect
        end

        grid.downStarEffect:Play()

    end
end

function BattleEnemyGridView:ShowUnitDetails(args)
    if self.battleUnitDetailsPanel == nil then
        self.battleUnitDetailsPanel = BattleUnitDetailsPanel.New()
        self.battleUnitDetailsPanel:SetParent(UIDefine.canvasRoot)
    end
    local enemyRoleUid = RunWorld.BattleDataSystem:GetEnemyRoleUid()
    local data = RunWorld.BattleDataSystem:GetBaseUnitData(enemyRoleUid,args.unit_id)
    data.star = RunWorld.BattleDataSystem:GetHeroStarByUnitId(enemyRoleUid,args.unit_id)
    self.battleUnitDetailsPanel:SetData(data)
    self.battleUnitDetailsPanel:Show()
end

function BattleEnemyGridView:ShowHeroDetails(args)
    if self.battleHeroDetailsPanel == nil then
        self.battleHeroDetailsPanel = BattleHeroDetailsPanel.New()
        self.battleHeroDetailsPanel:SetParent(UIDefine.canvasRoot)
    end
    local enemyRoleUid = RunWorld.BattleDataSystem:GetEnemyRoleUid()
    local data = RunWorld.BattleDataSystem:GetBaseUnitData(enemyRoleUid,args.unit_id)
    data.star = RunWorld.BattleDataSystem:GetHeroStarByUnitId(enemyRoleUid,args.unit_id)
    self.battleHeroDetailsPanel:SetData(data)
    self.battleHeroDetailsPanel:Show()
end

function BattleEnemyGridView:GetUIPosByUnitId(unitId,targetTrans)
    local info = self.lastInfos[unitId]
    if info and info.index then
        targetTrans.transform = self.grids[info.index].bg.transform
    end
end

function BattleEnemyGridView:RefreshGridUnlock()
    self.unlockNum = RunWorld.BattleDataSystem:GetUnlockGridNum(RunWorld.BattleDataSystem:GetEnemyRoleUid())
    for i = 1,self.unlockNum do
        local grid = self.grids[i]
        if grid then
            grid.lockNode:SetActive(false)
        end
    end
    for i = self.unlockNum + 1, self.maxEmbattleCount do
        local grid = self.grids[i]
        if grid then
            grid.lockNode:SetActive(true)
        end
    end
end