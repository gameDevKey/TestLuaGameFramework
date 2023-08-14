BattleHaloTipsView = BaseClass("BattleHaloTipsView",ExtendView)

BattleHaloTipsView.Event = EventEnum.New(
    "RefreshHaloList"
)

function BattleHaloTipsView:__Init()
    self.enum = {
        self = 1,
        enemy = 2,
    }

    self.haloIconItems = {
        [self.enum.self] ={},
        [self.enum.enemy] ={},
    }

    self.haloData = {}

    self.haloEffectItems = {}

    self.type = self.enum.self
    self.typeRoleUid = {}
    self.roleUnitHalos = {}
    self.toPlayEffectList = {}
    self.haloFlashEffects = {}
end

function BattleHaloTipsView:__Delete()
    for k,v in pairs(self.haloIconItems[self.enum.self]) do
        GameObject.Destroy(v.gameObject)
    end
    for k,v in pairs(self.haloIconItems[self.enum.enemy]) do
        GameObject.Destroy(v.gameObject)
    end
    for k, v in pairs(self.haloFlashEffects) do
        v:Delete()
    end
end

function BattleHaloTipsView:__CacheObject()
    self:Find("main/pk_info/halo_tips/main/title",Text).text = TI18N("场上光环")
    self:Find("main/pk_info/halo_tips/main/none_tips",Text).text = TI18N("当前没有生效光环")
    self.tabGroup = {}
    self.tabGroup[self.enum.self] = {}
    self.tabGroup[self.enum.self].selected = self:Find("main/pk_info/halo_tips/main/tab_group/tab_1/selected").gameObject
    self:Find("main/pk_info/halo_tips/main/tab_group/tab_1/text",Text).text = TI18N("我方光环")
    self:Find("main/pk_info/halo_tips/main/tab_group/tab_1/selected/text",Text).text = TI18N("我方光环")
    self.tabGroup[self.enum.enemy] = {}
    self.tabGroup[self.enum.enemy].selected = self:Find("main/pk_info/halo_tips/main/tab_group/tab_2/selected").gameObject
    self:Find("main/pk_info/halo_tips/main/tab_group/tab_2/selected/text",Text).text = TI18N("敌方光环")
    self:Find("main/pk_info/halo_tips/main/tab_group/tab_2/text",Text).text = TI18N("敌方光环")

    self.haloParent = {}
    self.haloParent[self.enum.self] = self:Find("main/pk_info/self_info/self_halo_list")
    self.haloParent[self.enum.enemy] = self:Find("main/top_node/enemy_info/enemy_halo_list")

    self.haloItem = {}
    self.haloItem[self.enum.self] = self:Find("main/pk_info/self_info/self_halo_list/item").gameObject
    self.haloItem[self.enum.enemy] = self:Find("main/top_node/enemy_info/enemy_halo_list/item").gameObject

    self.haloTipsPanel = self:Find("main/pk_info/halo_tips").gameObject
    self.haloEffectParent = self:Find("main/pk_info/halo_tips/main/halo_con/viewport/content")
    self.haloEffectItem = self:Find("main/pk_info/halo_tips/main/halo_con/viewport/content/halo_item").gameObject

    self.noneTips = self:Find("main/pk_info/halo_tips/main/none_tips").gameObject
end

function BattleHaloTipsView:__BindEvent()
    self:BindEvent(BattleHaloTipsView.Event.RefreshHaloList)
end

function BattleHaloTipsView:__BindListener()
    self:Find("main/pk_info/self_info/self_halo_list").gameObject:GetComponent(Button):SetClick( self:ToFunc("ShowHaloEffectTips"),self.enum.self )
    self:Find("main/top_node/enemy_info/enemy_halo_list").gameObject:GetComponent(Button):SetClick( self:ToFunc("ShowHaloEffectTips"),self.enum.enemy )

    self:Find("main/pk_info/halo_tips/main/tab_group/tab_1").gameObject:GetComponent(Button):SetClick( self:ToFunc("ChangeTabGroup"),self.enum.self )
    self:Find("main/pk_info/halo_tips/main/tab_group/tab_2").gameObject:GetComponent(Button):SetClick( self:ToFunc("ChangeTabGroup"),self.enum.enemy )

    self:Find("main/pk_info/halo_tips/panel_bg").gameObject:GetComponent(Button):SetClick( self:ToFunc("HideHaloEffectTips") )
    self:Find("main/pk_info/halo_tips/main/close_btn").gameObject:GetComponent(Button):SetClick( self:ToFunc("HideHaloEffectTips") )
end

function BattleHaloTipsView:__Create()
    for i = 1, 7 do
        local item = GameObject.Instantiate(self.haloItem[self.enum.self])
        item.transform:SetParent(self.haloParent[self.enum.self])
        item.transform:Reset()
        local enemyY = 7 + (i-1)*40
        UnityUtils.SetAnchoredPosition(item.transform, 0,enemyY)
        item:SetActive(false)
        local haloIconItem = {}
        haloIconItem.gameObject = item
        haloIconItem.bg = item.transform:Find("bg").gameObject
        haloIconItem.icon = item.transform:Find("icon").gameObject:GetComponent(Image)
        haloIconItem.num = item.transform:Find("num").gameObject:GetComponent(Text)
        table.insert(self.haloIconItems[self.enum.self],haloIconItem)

        item = GameObject.Instantiate(self.haloItem[self.enum.enemy])
        item.transform:SetParent(self.haloParent[self.enum.enemy])
        item.transform:Reset()
        local selfY = -40 * (i-1)
        UnityUtils.SetAnchoredPosition(item.transform, 0,selfY)
        item:SetActive(false)
        haloIconItem = {}
        haloIconItem.gameObject = item
        haloIconItem.bg = item.transform:Find("bg").gameObject
        haloIconItem.icon = item.transform:Find("icon").gameObject:GetComponent(Image)
        haloIconItem.num = item.transform:Find("num").gameObject:GetComponent(Text)
        table.insert(self.haloIconItems[self.enum.enemy],haloIconItem)
    end
    self.haloItem[self.enum.self]:SetActive(false)
    self.haloItem[self.enum.enemy]:SetActive(false)

    for i = 1, 10 do
        local item = GameObject.Instantiate(self.haloEffectItem)
        item.transform:SetParent(self.haloEffectParent)
        item.transform:Reset()
        local y = -66.5 * (i-1)
        UnityUtils.SetAnchoredPosition(item.transform, 0,y)
        item:SetActive(false)
        local haloEffectItem = {}
        haloEffectItem.gameObject = item
        haloEffectItem.icon = item.transform:Find("icon").gameObject:GetComponent(Image)
        haloEffectItem.title = item.transform:Find("title").gameObject:GetComponent(Text)
        haloEffectItem.effect = item.transform:Find("effect").gameObject:GetComponent(Text)
        table.insert(self.haloEffectItems,haloEffectItem)
    end
    self.haloEffectItem:SetActive(false)
end

function BattleHaloTipsView:__Show()
end

function BattleHaloTipsView:__Hide()
    self.haloData = {}
    self.roleUnitHalos = {}
    self.typeRoleUid = {}
    self.toPlayEffectList = {}
    self.type = self.enum.self
    self:HideHaloEffectTips()
    self:HideAll()
end

function BattleHaloTipsView:RefreshHaloList(roleUnitHalos,activeHalos)
    for k, v in pairs(roleUnitHalos) do
        if not self.roleUnitHalos[k] then
            self.roleUnitHalos[k] = {}
        end
        for k2, v2 in pairs(v) do
            if not self.roleUnitHalos[k][k2] then
                self.roleUnitHalos[k][k2] = {}
            end
            for k3, v3 in pairs(v2) do
                if not self.roleUnitHalos[k][k2][k3] then
                    -- LogError("有新光环",k,v3.haloId,v3.haloLev) --TODO 有新光环
                    self.roleUnitHalos[k][k2][k3] = v3

                end
            end
        end

        for k4, v4 in pairs(self.roleUnitHalos[k]) do
            if not v[k4] then
                -- LogError("有光环被移除",k4) --TODO 有光环被移除
                self.roleUnitHalos[k][k4] = nil
                self.haloData[k][k4] = nil

            end
        end
    end
    for k, v in pairs(activeHalos) do      --k:roleUid, v:self.activeHalos[roleUid]
        for k2, v2 in pairs(v) do          --k2:haloId,  v2:self.activeHalos[roleUid][haloId]
            local active = false
            local activeLev = 999
            for k3, v3 in pairs(v2) do     --k3:haloLev, v3:self.activeHalos[roleUid][haloId][haloLev] => haloStatus
                if k3 < activeLev then
                    activeLev = k3
                end
                if v3 then
                    active = true
                    activeLev = k3
                    break
                end
            end
            if not self.haloData[k] then
                self.haloData[k] = {}
            end
            if not self.haloData[k][k2] then
                self.haloData[k][k2] = {active = false, activeLev = 1, hasNext = false}
            end
            if self.haloData[k][k2].active ~= active then
                -- LogError("有光环激活状态改变",k2,tostring(self.haloData[k][k2].active),"->",tostring(active),"lev:",activeLev)--TODO 有光环激活状态改变

                if not self.haloData[k][k2].active and active then --未激活 -> 激活  --TODO 播放特效
                    if not self.toPlayEffectList[k] then
                        self.toPlayEffectList[k] = {}
                    end
                    self.toPlayEffectList[k][k2] = activeLev
                end

            elseif self.haloData[k][k2].active == active and self.haloData[k][k2].activeLev ~= activeLev then
                -- LogError("有光环等级发生改变",k2,self.haloData[k][k2].activeLev,"->",activeLev,"active:",tostring(active))--TODO 有光环等级发生改变
            end
            self.haloData[k][k2] = {active = active, activeLev = activeLev}
        end
    end
    self:SetHaloIconItem()
end

function BattleHaloTipsView:SetHaloIconItem()
    self.typeRoleUid = {}
    for k, v in pairs(self.haloData) do
        local index = 1
        local type = self.enum.self
        if RunWorld.BattleDataSystem.roleUid ~= k then
            type = self.enum.enemy
        end
        if not self.typeRoleUid[type] then
            self.typeRoleUid[type] = {}
        end
        self.typeRoleUid[type][k] = k
        local curTypeNum = RunWorld.BattleHaloSystem:GetCurTypeNum(k)
        for k2, v2 in pairs(v) do
            local halo = self.roleUnitHalos[k][k2][v2.activeLev]
            local path = AssetPath.GetBattleHaloIcon(halo.conf.icon)
            self:SetSprite(self.haloIconItems[type][index].icon,path,true)

            UIUtils.Grey(self.haloIconItems[type][index].icon, not v2.active)
            -- UIUtils.Grey(self.haloIconItems[type][index].icon, true)

            local showNum = {}

            if halo.condAction then
                for k3, v3 in pairs(halo.condAction.requiredTypeNum) do
                    local curNum = curTypeNum[k3] or 0
                    local requiredNum = v3
                    table.insert(showNum,{curNum = curNum,requiredNum = requiredNum,requiredType = k3})
                end
            end
            local str = ""
            for i = 1, #showNum do
                local curNum = showNum[i].curNum.."/"
                local requiredNum = showNum[i].requiredNum
                local requiredType = showNum[i].requiredType
                local nextLev = v2.activeLev
                local nextLevHalo = nil
                for k3, v3 in pairs(self.roleUnitHalos[k][k2]) do
                    if k3 > nextLev then
                        nextLev = k3
                        nextLevHalo = v3
                    end
                end

                if v2.active then
                    curNum = UIUtils.GetColorText(curNum,"#e7be24")
                    if nextLevHalo == nil then
                        requiredNum = UIUtils.GetColorText(requiredNum,"#e7be24")
                    else
                        requiredNum = nextLevHalo.condAction.requiredTypeNum[requiredType]
                        v2.hasNext = true
                    end
                    if type == self.enum.self then
                        if self.toPlayEffectList[k][k2] then
                            self:PlayEffect(k,requiredType,index)
                            self.toPlayEffectList[k][k2] = nil
                        else
                            -- UIUtils.Grey(self.haloIconItems[type][index].icon, true)
                        end
                    else
                        -- UIUtils.Grey(self.haloIconItems[type][index].icon, true)
                    end
                end
                if requiredNum then
                    if i == 1 then
                        str = curNum..requiredNum
                    else
                        str = str .. TI18N(" 且 ") .. curNum .. requiredNum
                    end
                end
            end
            self.haloIconItems[type][index].num.text = str
            self.haloIconItems[type][index].bg:SetActive(not StringUtils.IsEmpty(str))

            self.haloIconItems[type][index].gameObject:SetActive(true)
            index = index + 1
        end
        for j = index, #self.haloIconItems[type] do
            self.haloIconItems[type][j].gameObject:SetActive(false)
        end
    end
    if self.haloTipsPanel.activeSelf then
        self:SetEffectItem(self.type)
    end
end


function BattleHaloTipsView:ShowHaloEffectTips(type)
    --type 控制切页
    self:ChangeTabGroup(type)
    self.haloTipsPanel:SetActive(true)
end

function BattleHaloTipsView:ChangeTabGroup(type)
    self.type = type
    local hidePage = type ~= self.enum.self and self.enum.self or self.enum.enemy
    self.tabGroup[type].selected:SetActive(true)
    self.tabGroup[hidePage].selected:SetActive(false)

    self:SetEffectItem(type)
end

function BattleHaloTipsView:SetEffectItem(type)
    local isNull = true
    if not self.typeRoleUid[type] then
        self.noneTips:SetActive(isNull)
        return
    end
    for k, v in pairs(self.typeRoleUid[type]) do
        if #self.haloData[v] > 0 then
            isNull = false
            break
        end
    end
    self.noneTips:SetActive(not isNull)
    local index = 1
    for k, v in pairs(self.typeRoleUid[type]) do
        for k1, v1 in pairs(self.haloData[v]) do
            local halo = self.roleUnitHalos[k][k1][v1.activeLev]
            local path = AssetPath.GetBattleHaloIcon(halo.conf.icon)
            self:SetSprite(self.haloEffectItems[index].icon,path,true)

            UIUtils.Grey(self.haloEffectItems[index].icon, not v1.active)

            self.haloEffectItems[index].title.text = halo.conf.name
            local str = ""
            if v1.hasNext then
                str = TI18N("[可升级]")
            end
            self.haloEffectItems[index].effect.text = string.format(halo.conf.desc,self.haloIconItems[type][index].num.text,str)
            self.haloEffectItems[index].gameObject:SetActive(true)
            index = index+1
        end
    end
    for j = index, #self.haloEffectItems do
        self.haloEffectItems[j].gameObject:SetActive(false)
    end
end

function BattleHaloTipsView:HideHaloEffectTips()
    self.haloTipsPanel:SetActive(false)
end

function BattleHaloTipsView:HideAll()
    self.haloData = {
        [self.enum.self] ={},
        [self.enum.enemy] ={},
    }
    for k,v in pairs(self.haloIconItems[self.enum.self]) do
        v.gameObject:SetActive(false)
    end
    for k,v in pairs(self.haloIconItems[self.enum.enemy]) do
        v.gameObject:SetActive(false)
    end
    for k, v in pairs(self.haloEffectItems) do
        v.gameObject:SetActive(false)
    end
    self:HideEffects()
end

function BattleHaloTipsView:HideEffects()
    for k, v in pairs(self.haloFlashEffects) do
        v:Stop()
    end
end

function BattleHaloTipsView:PlayEffect(roleUid,raceType,iconIndex)
    local grids = {}
    local unitDatas = RunWorld.BattleDataSystem.rolePkDatas[roleUid].unitDatas
    for k, v in pairs(unitDatas) do
        local conf = RunWorld.BattleConfSystem:UnitData_data_unit_info(k)
        if conf.race_type == raceType then
            table.insert(grids,v.grid_id)
        end
    end

    local iconItem = self.haloIconItems[self.enum.self][iconIndex]
    local iconPos = iconItem.gameObject.transform:Find("icon").transform.position

    local setting = {}
    local bloomEffects = {}
    local trailingEffects = {}
    local moveAnims = {}
    for i, gridId in ipairs(grids) do
        setting = {}
        setting.confId = 10004
        setting.parent = BattleDefine.uiObjs["mixed_effect"]
        local worldPos = RunWorld.BattleMixedSystem:GetPlaceSlotPos(gridId) --TODO BattleOperateView:GetPlaceSlotPos()
        local uiPos = BaseUtils.WorldToUIPoint(BattleDefine.nodeObjs["main_camera"],worldPos)
        local bloomEffect = UIEffect.New()
        bloomEffect:Init(setting)
        bloomEffect:SetPos(uiPos.x,uiPos.y,0)
        table.insert(bloomEffects,bloomEffect)

        setting = {}
        setting.confId = 10002
        setting.parent = BattleDefine.uiObjs["mixed_effect"]
        local trailingEffect = UIEffect.New()
        trailingEffect:Init(setting)
        trailingEffect:SetPos(uiPos.x,uiPos.y,0)
        table.insert(trailingEffects,trailingEffect)

        local moveAnim = MoveAnim.New(trailingEffect.transform,iconPos,0.5)
        moveAnim:SetDelay(0.3)
        table.insert(moveAnims,moveAnim)
    end

    if not self.haloFlashEffects[iconIndex] then
        setting = {}
        setting.confId = 10003
        setting.parent = iconItem.gameObject.transform:Find("icon").transform

        local flashEffect = UIEffect.New()
        flashEffect:Init(setting)
        flashEffect:SetPos()
        self.haloFlashEffects[iconIndex] = flashEffect
    end
    local onComplete = function ()
        -- UIUtils.Grey(iconItem.icon, false)
        for k,v in pairs(bloomEffects) do
            v:Delete()
        end
        for k,v in pairs(trailingEffects) do
            v:Delete()
        end
        for k,v in pairs(moveAnims) do
            v:Destroy()
        end
        -- self:HideEffects()
    end
    self.haloFlashEffects[iconIndex]:SetComplete(onComplete)
    local cb = function ()
        self.haloFlashEffects[iconIndex]:Play()
    end
    moveAnims[1]:SetComplete(cb)

    for i, v in ipairs(bloomEffects) do
        v:Play()
        trailingEffects[i]:Play()
        moveAnims[i]:Play()
    end
end