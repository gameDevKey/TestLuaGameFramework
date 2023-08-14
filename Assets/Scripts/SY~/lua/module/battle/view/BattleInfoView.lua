BattleInfoView = BaseClass("BattleInfoView",ExtendView)

BattleInfoView.Event = EventEnum.New(
    "RefreshRoleInfo",
    "RefreshAssets",
    "RefreshMoney",
    "RefreshNextRoundTime",
    "RefreshGroupNum",
    "ShowSoloTips",
    "PlayLowHpWarning",
    "PlayUnlockGrid",
    "CommanderSkillUnlock",
    "PlayBeHitWarningWhenLowHp",
    "ActiveRestrain",
    "CheckRandomUnitTips",
    "ShowLastGroupTips",
    "ActiveWaitEnemyEnter",
    "ActiveCurMoney"
)

function BattleInfoView:__Init()
    self.roundProgressTimer = nil
    self.lastRoundTime = nil
    self.enterAnim = nil
    self.soloAnim = nil
    self.lastGroupAnim = nil

    self.lowHpEffect = nil

    self.randomUnitTipsTimer = nil
    self.activeRandomUnitTips = false

    self.enableSurrender = true
    self.onSurrender = nil
end

function BattleInfoView:__Delete()
    self.enableSurrender = true
    self.onSurrender = nil
end

function BattleInfoView:__CacheObject()
    self.selfRoleInfos = {}
    self.selfRoleInfos.transform = self:Find("main/pk_info/self_info")
    self.selfRoleInfos.nameText = self:Find("main/pk_info/self_info/name",Text)
    self.selfRoleInfos.headIcon = self:Find("main/pk_info/self_info/role_info/head/head_icon",Image)
    self.selfRoleInfos.headFrame = self:Find("main/pk_info/self_info/role_info/head/head_frame",Image)

    self.selfRoleInfos.unlockBattleNum = self:Find("main/pk_info/self_info/unlock_battle_num/info",Text)
    self.selfRoleInfos.unlockBattleNumCost = self:Find("main/pk_info/self_info/unlock_battle_num/cost",Text)

    self.enemyRoleInfos = {}
    self.enemyRoleInfos.nameText = self:Find("main/top_node/enemy_info/role_info/name",Text)
    self.enemyRoleInfos.headIcon = self:Find("main/top_node/enemy_info/role_info/head/head_icon",Image)
    self.enemyRoleInfos.headFrame = self:Find("main/top_node/enemy_info/role_info/head/head_frame",Image)

    self.roundProgressSliderFilled = self:Find("main/operate/next_round_info/round_progress/filled",Image)

    self.curMoneyNode = self:Find("main/operate/cur_money").gameObject
    self.curMoney = self:Find("main/operate/cur_money/num",Text)
    -- self.nextAddMoney = self:Find("main/operate/cur_money/add_money",Text)
    self.buyCost = self:Find("main/operate/random_buy_btn/cost",Text)

    self.syncDebugInfo = self:Find("main/top_node/debug/sync_info",Text)

    self.nextRoundTime = self:Find("main/operate/next_round_info/next_round_countdown/time",Text)

    self.groupNum = self:Find("main/top_node/group_info/num",Text)

    self.soloTipsCanvasGroup = self:Find("main/solo_tips",CanvasGroup)

    self.restrainNode = self:Find("main/restrain_node").gameObject

    self.randomUnitTips = self:Find("main/tips/buy_hero_tips").gameObject

    self.lastGroupTipsCanvasGroup = self:Find("main/last_group_tips",CanvasGroup)

    self.waitEnemyEnter = self:Find("main/top_node/wait_enemy_info").gameObject

    self.animRoot = self:Find("main/tips_node")
end

function BattleInfoView:__BindListener()
    self:Find("main/top_node/group_info/surrender_btn",Button):SetClick( self:ToFunc("Surrender") )
    self:Find("main/pk_info/self_info/chat_btn",Button):SetClick( self:ToFunc("SendChat"))
end

function BattleInfoView:__BindEvent()
    self:BindEvent(BattleInfoView.Event.RefreshRoleInfo)
    self:BindEvent(BattleInfoView.Event.RefreshAssets)
    self:BindEvent(BattleInfoView.Event.RefreshMoney)
    self:BindEvent(BattleInfoView.Event.RefreshNextRoundTime)
    self:BindEvent(BattleInfoView.Event.RefreshGroupNum)
    self:BindEvent(BattleInfoView.Event.ShowSoloTips)
    self:BindEvent(BattleInfoView.Event.PlayLowHpWarning)
    self:BindEvent(BattleInfoView.Event.PlayUnlockGrid)
    self:BindEvent(BattleInfoView.Event.CommanderSkillUnlock)
    self:BindEvent(BattleInfoView.Event.PlayBeHitWarningWhenLowHp)
    self:BindEvent(BattleInfoView.Event.ActiveRestrain)
    self:BindEvent(BattleInfoView.Event.CheckRandomUnitTips)
    self:BindEvent(BattleInfoView.Event.ShowLastGroupTips)
    self:BindEvent(BattleInfoView.Event.ActiveWaitEnemyEnter)
    self:BindEvent(BattleInfoView.Event.ActiveCurMoney)
    self:BindEvent(BattleFacade.Event.EnableSurrender)
    self:BindEvent(BattleFacade.Event.AddSurrenderCallback)
end

function BattleInfoView:__Show()
    self.roundProgressSliderFilled.fillAmount = 0.0
    self.roundProgressTimer = TimerManager.Instance:AddTimer(0,0,self:ToFunc("RoundProgressTimer"))
end

function BattleInfoView:__Hide()
    self:RemoveRoundProgressTimer()
    self.lastNextRoundTime = nil

    self.soloTipsCanvasGroup.gameObject:SetActive(false)

    self.lastGroupTipsCanvasGroup.gameObject:SetActive(false)

    if self.lowHpEffect then
        self.lowHpEffect:Stop()
    end

    if self.moneyChangeAnim then
        self.moneyChangeAnim:Destroy()
    end
    self.moneyChangeAnim = nil
    self.curMoney.text = 0

    self.enableSurrender = true
    self.onSurrender = nil

    self:RemoveRandomUnitTipsTimer()
    self:ActiveRandomUnitTips(false)
end

function BattleInfoView:__Create()
    
end

function BattleInfoView:ActiveWaitEnemyEnter(flag)
    self.waitEnemyEnter:SetActive(flag)
end

function BattleInfoView:RefreshRoleInfo()
    local roleData = mod.RoleProxy.roleData
    self.selfRoleInfos.nameText.text = roleData.name

    --
    local pkRoleData = RunWorld.BattleDataSystem:GetEnemyRoleData()
    local pkRoleName = pkRoleData.role_base.name
    -- if pkRoleData.role_base.role_id == 0 then
    --     pkRoleName = pkRoleName .."(机器人)"
    -- end
    self.enemyRoleInfos.nameText.text = pkRoleName
end

function BattleInfoView:RefreshAssets()
    self.crystalNum.text = RunWorld.BattleDataSystem:GetAsset(BattleDefine.AssetType.crystal)

    local nextCrystalNum = RunWorld.BattleDataSystem:GetNextAsset(BattleDefine.AssetType.crystal)
    self.crystalNextNum.text = "+" .. tostring(nextCrystalNum)

    local costCrystalNum = RunWorld.BattleDataSystem:GetBuyCostAsset(BattleDefine.AssetType.crystal)
    self.randomBuyCost.text = costCrystalNum
end

function BattleInfoView:RoundProgressTimer()
    local lastGroupProgress = RunWorld.BattleGroupSystem.lastGroupProgress
    local targetGroupProgress = RunWorld.BattleGroupSystem.groupProgress
    local progress = lastGroupProgress + (targetGroupProgress - lastGroupProgress) * RunWorld.lerpTime
    self.roundProgressSliderFilled.fillAmount = progress
end

function BattleInfoView:RemoveRoundProgressTimer()
    if self.roundProgressTimer then
        TimerManager.Instance:RemoveTimer(self.roundProgressTimer)
        self.roundProgressTimer = nil
    end
end

function BattleInfoView:Update()
    self.syncDebugInfo.text = string.format("[s:%s - c:%s]\n[fps:%s]",RunWorld.BattleFrameSyncSystem.frame,RunWorld.frame,DevicesFpsManager.Instance.curFps)
end

function BattleInfoView:RefreshMoney()
    local roleUid = RunWorld.BattleDataSystem.roleUid
    local money = RunWorld.BattleDataSystem:GetRoleMoney(roleUid)

    --数字滚动动画
    local oldMoney = tonumber(self.curMoney.text)
    if self.moneyChangeAnim then
        self.moneyChangeAnim:Destroy()
    end
    self.moneyChangeAnim = nil
    self.moneyChangeAnim = ToIntValueAnim.New(oldMoney,money,0.3,function (v)
        self.curMoney.text = v
    end)
    self.moneyChangeAnim:Play()
    --
    -- local addMoney = RunWorld.BattleGroupSystem:GetNextStepMoney()
    -- self.nextAddMoney.text = "+" ..tostring(addMoney)

    local buyNum = RunWorld.BattleDataSystem:GetRandomNum(roleUid)
    local buyCostConf = RunWorld.BattleConfSystem:PvpData_data_pvp_buy_cost(RunWorld.BattleDataSystem.pvpConf.id,buyNum + 1)

	local needMoney = RunWorld.BattleDataSystem:GetRandomCostMoney(roleUid)
    local flag = RunWorld.BattleDataSystem:HasMoney(roleUid,needMoney)
    local color = flag and "#FFFFFF" or "#F45959"
    
    self.buyCost.text = UIUtils.GetColorText(buyCostConf.cost,color)

    self:CheckRandomUnitTips()
end

function BattleInfoView:CheckRandomUnitTips()
    if RunWorld.firstRunning then
        return
    end

    local roleUid = RunWorld.BattleDataSystem.roleUid

    local existOp = RunWorld.BattleInputSystem:ExistOp(BattleDefine.Operation.random_hero)

    local needMoney = RunWorld.BattleDataSystem:GetRandomCostMoney(roleUid)
    local canBuy = RunWorld.BattleDataSystem:HasMoney(roleUid,needMoney)

    local existWaitSelectUnits = RunWorld.BattleDataSystem:ExistWaitSelectUnits(roleUid)

    local flag = false
    if canBuy and not existOp and not existWaitSelectUnits then
        flag = true
    end

    if flag and BattleDefine.openSelectTips then
        if not self.activeRandomUnitTips and not self.randomUnitTipsTimer then
            self.randomUnitTipsTimer = TimerManager.Instance:AddTimer(1,5,self:ToFunc("RandomUnitTipsTimerCb"))
        end
    elseif BattleDefine.openSelectTips then
        if self.activeRandomUnitTips or self.randomUnitTipsTimer then
            self:RemoveRandomUnitTipsTimer()
            self:ActiveRandomUnitTips(false)
        end
    end
end

function BattleInfoView:RandomUnitTipsTimerCb()
    self.randomUnitTipsTimer = nil
    self:ActiveRandomUnitTips(true)
end

function BattleInfoView:ActiveRandomUnitTips(flag)
    if self.activeRandomUnitTips ~= flag then
        self.activeRandomUnitTips = flag
        self.randomUnitTips:SetActive(flag)
    end 
end

function BattleInfoView:RemoveRandomUnitTipsTimer()
    if self.randomUnitTipsTimer then
        TimerManager.Instance:RemoveTimer(self.randomUnitTipsTimer)
        self.randomUnitTipsTimer = nil
    end
end

function BattleInfoView:RefreshNextRoundTime(time)
    if not self.lastNextRoundTime or self.lastNextRoundTime ~= time then
        self.nextRoundTime.text = time
        self.lastNextRoundTime = time
        if self.countDownTime then
            self.countDownTime.text = time
        end
    end
end

function BattleInfoView:RefreshGroupNum(num)
    self.groupNum.text = "WAVE:"..num .. "/" .. RunWorld.BattleGroupSystem.maxGroup
end

function BattleInfoView:Surrender()
    --TODO 弹出提示框确认是否投降 点击确认发送投降协议 点击取消返回游戏。现在先简单实现直接退出
    if self.enableSurrender then
        RunWorld.BattleResultSystem:Surrender()
    end
    if self.onSurrender then
        self.onSurrender(self.enableSurrender)
    end
end

function BattleInfoView:SendChat()
    --TODO 弹出快捷消息列表或表情列表点击发送
    SystemMessage.Show(TI18N("聊天功能正在研发中…"))
end

function BattleInfoView:ShowSoloTips()
    self:LoadUIEffect({
        confId = 10032,
        parent = self.animRoot,
        order = self:GetOrder() + 1,
        onLoad = self:ToFunc("OnEffectPlay"),
    },true)
end

function BattleInfoView:ShowLastGroupTips(lastNum)
    self.lastShowNum = lastNum
    self:LoadUIEffect({
        confId = 10031,
        parent = self.animRoot,
        order = self:GetOrder() + 1,
        onLoad = self:ToFunc("OnEffectPlay"),
    },true)
end

function BattleInfoView:OnEffectPlay(id,eff)
    if id == 10031 then
        local animator = eff.effect.gameObject:GetComponent(Animator)
        if self.lastShowNum == 1 then
            animator:Play("anim_10031_1hh",-1,0)
        elseif self.lastShowNum == 2 then
            animator:Play("anim_10031_2hh",-1,0)
        else
            animator:Play("anim_10031_3hh",-1,0)
        end
    end
end

function BattleInfoView:PlayLowHpWarning()
    if not self.lowHpEffect then
        local setting = {}
        setting.confId = 10005
        setting.parent = BattleDefine.uiObjs["mixed_effect"]

        --TODO:层级需要优化
        setting.order = 100

        self.lowHpEffect = UIEffect.New()
        self.lowHpEffect:Init(setting)
    end

    self.lowHpEffect:SetActive(false)
    self.lowHpEffect:Play()
end


function BattleInfoView:PlayUnlockGrid(grid)
    -- local pos = RunWorld.BattleMixedSystem:GetPlaceSlotPos(grid)--TODO BattleOperateView:GetPlaceSlotPos()
    -- RunWorld.BattleAssetsSystem:PlaySceneEffect(100005,pos.x * 1000,(pos.y + 0.1) * 1000,pos.z * 1000,EffectDefine.EffectType.action)
end

function BattleInfoView:CommanderSkillUnlock(roleUid,skillId)
    -- LogError(string.format("统帅头顶展示 roleUid:%s, skillId:%s",roleUid,skillId))
end

function BattleInfoView:PlayBeHitWarningWhenLowHp()
    if not self.lowHpBeHitEffect then
        local setting = {}
        setting.confId = 10010
        setting.parent = BattleDefine.uiObjs["mixed_effect"]

        --TODO:层级需要优化
        setting.order = 100

        self.lowHpBeHitEffect = UIEffect.New()
        self.lowHpBeHitEffect:Init(setting)
        self.lowHpBeHitEffect:SetPos(0,-100,0)
    end
    self.lowHpBeHitEffect:Play()
end

function BattleInfoView:ActiveRestrain(flag)
    self.restrainNode:SetActive(flag)
end

function BattleInfoView:EnableSurrender(flag)
    self.enableSurrender = flag
end

function BattleInfoView:AddSurrenderCallback(callback)
    self.onSurrender = callback
end

function BattleInfoView:ActiveCurMoney(flag)
    if flag then
        if not self.curMoneyNode.activeSelf then
            self.curMoneyNode:SetActive(true)
        end
    else
        self.curMoneyNode:SetActive(false)
    end
end