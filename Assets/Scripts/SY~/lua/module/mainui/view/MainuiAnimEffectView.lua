MainuiAnimEffectView = BaseClass("MainuiAnimEffectView",ExtendView)

MainuiAnimEffectView.FloatAnimDuration = 2

MainuiAnimEffectView.Event = EventEnum.New(
    "ShowResFloatAnim",
    "ShowDivisionRewardAnim",
    "ShowBattlepassRewardAnim"
)

function MainuiAnimEffectView:__Init()
    self.animKey = 0
end

function MainuiAnimEffectView:__CacheObject()
    self.canvasFloat = self:Find("canvas_float",Canvas)
    self.objFloatRes = self:Find("canvas_float/img_float_res").gameObject
    self.objFloatRes:SetActive(false)
end

function MainuiAnimEffectView:__Create()
    self.canvasFloat.sortingOrder = ViewDefine.Layer["MainuiPanel_Top_Bottom"] + 1
end

function MainuiAnimEffectView:__BindListener()

end

function MainuiAnimEffectView:__BindEvent()
    self:BindEvent(MainuiAnimEffectView.Event.ShowResFloatAnim)
    self:BindEvent(MainuiAnimEffectView.Event.ShowDivisionRewardAnim)
    self:BindEvent(MainuiAnimEffectView.Event.ShowBattlepassRewardAnim)
end

function MainuiAnimEffectView:__Hide()

end

function MainuiAnimEffectView:__Show()

end

function MainuiAnimEffectView:ShowRewardAnim(root,num,animId)
    -- local order = ViewDefine.Layer["MainuiPanel_Top_Bottom"] + 1
    -- self:LoadUIEffect({
    --     confId = 9400007,
    --     parent = root.transform,
    --     order = order,
    --     onLoad = self:ToFunc("OnEffectLoad"),
    --     args = {num=num,animId=animId},
    --     lastTime = 0,
    --     delayTime = 0,
    -- },true)
end

function MainuiAnimEffectView:OnEffectLoad(id,effect,args)
    if id == 9400007 then
        local animator = effect.effect:GetComponent(Animator)
        animator:Play(args.animId,-1,0)
        animator:Update(0)
        local timer = self:AddUniqueTimer("mainui_effect1", 1, MainuiAnimEffectView.FloatAnimDuration * 0.85,self:ToFunc("OnTimerCall"))
        timer:SetArgs({
            num = args.num,
            animId = args.animId,
            effect = effect,
            animator = animator,
        })
    end
end

function MainuiAnimEffectView:OnTimerCall(args)
    args.count = 0
    local timer = self:AddUniqueTimer("mainui_effect2",args.num, 0.15, self:ToFunc("OnTimerCall2"))
    timer:SetArgs(args)
end

function MainuiAnimEffectView:OnTimerCall2(args)
    args.animator:Play(args.animId,-1,0)
    args.count = args.count + 1
    if args.count == args.num then
        self:RemoveEffect(args.effect.uid)
    end
end

function MainuiAnimEffectView:ShowDivisionRewardAnim(num)
    self:ShowRewardAnim(self.MainView.objDivision,num,"anim_9400007_huode_long_wd_002")
end

function MainuiAnimEffectView:ShowBattlepassRewardAnim(num)
    self:ShowRewardAnim(self.MainView.objBattlepass,num,"anim_9400007_huode_short_wd_001")
end

function MainuiAnimEffectView:GetResFloatIcon(resType)
    if resType == GDefine.ResFloatType.Gold then
        return AssetPath.ItemIdToCurrencyIcon[GDefine.ItemId.Gold]
    end
    if resType == GDefine.ResFloatType.Diamond then
        return AssetPath.ItemIdToCurrencyIcon[GDefine.ItemId.Diamond]
    end
    if resType == GDefine.ResFloatType.Trophy then
        return UITex("mainui/main/97")
    end
    if resType == GDefine.ResFloatType.DrawCardTicket then
        local itemConf = Config.ItemData.data_item_info[GDefine.ItemId.DrawCardTicket]
        return AssetPath.GetItemIcon(itemConf.icon)
    end
    if resType == GDefine.ResFloatType.AdvTicket then
        local itemConf = Config.ItemData.data_item_info[GDefine.ItemId.AdvTicket]
        return AssetPath.GetItemIcon(itemConf.icon)
    end
    if resType == GDefine.ResFloatType.Battlepass then
        return UITex("common1/common1_92")
    end
    if resType == GDefine.ResFloatType.EquipChest then
        local itemConf = Config.ItemData.data_item_info[GDefine.ItemId.EquipChest]
        return AssetPath.GetItemIcon(itemConf.icon)
    end
    LogErrorAny("请配置漂浮资源图标 resType=",resType)
    return ""
end

function MainuiAnimEffectView:GetResFloatTargetTrans(resType)
    if resType == GDefine.ResFloatType.Gold then
        return self.MainView.topInfoPanel.imgCoin.transform
    end
    if resType == GDefine.ResFloatType.Diamond then
        return self.MainView.topInfoPanel.imgDiamond.transform
    end
    if resType == GDefine.ResFloatType.Trophy then
        return self.MainView.objDivision.transform
    end
    if resType == GDefine.ResFloatType.DrawCardTicket then
        return self.MainView.btnDarwCard.transform
    end
    -- if resType == GDefine.ResFloatType.AdvTicket then
    --     return self.MainView.btnPve.transform
    -- end
    if resType == GDefine.ResFloatType.Battlepass then
        return self.MainView.objBattlepass.transform
    end
    if resType == GDefine.ResFloatType.EquipChest then
        return self.MainView.bottomBtnPanel.tabs[4].btn.transform
    end
    return self.MainView.transform
end

function MainuiAnimEffectView:GetAnimKey()
    self.animKey = self.animKey + 1
    return self.animKey
end

function MainuiAnimEffectView:ShowResFloatAnim(resType, num, resultArgs)
    local targetTrans = self:GetResFloatTargetTrans(resType)
    if not targetTrans.gameObject.activeInHierarchy then
        resultArgs.success = false
        return
    end
    resultArgs = resultArgs or {}
    local obj = GameObject.Instantiate(self.objFloatRes)
    obj:SetActive(true)
    local img = obj:GetComponent(Image)
    self:SetSprite(img, self:GetResFloatIcon(resType),true)
    local parent = self.objFloatRes.transform.parent
    obj:SetActive(false)

    local startPos = UIUtils.GetLocalPos(UIDefine.canvasRoot,self.MainView.transform)
    local targetPos = UIUtils.GetLocalPos(UIDefine.canvasRoot,targetTrans)

    self:ShowSingleResFloatAnim({
        index = 1,
        max = num,
        key = self:GetAnimKey(),
        startPos = startPos,
        targetPos = targetPos,
        template = obj,
        parent = parent,
        ease = DG.Tweening.Ease.InBack,
        duration = MainuiAnimEffectView.FloatAnimDuration,
        onFinish = self:ToFunc("OnFinishResFloatAnim"),
    })

    local effIds = {10020}
    for _, id in ipairs(effIds or {}) do
        local effect = UIEffect.New()
        local setting = {}
        setting.confId = id
        setting.parent = parent
        setting.order = ViewDefine.Layer["PlayerGuideView_Effect"]
        setting.deleteOnComplete = true
        setting.delayTime = 0.1
        effect:Init(setting)
        effect:SetPos(startPos.x,startPos.y)
        effect:Play()
    end

    resultArgs.success = true
end

function MainuiAnimEffectView:ShowSingleResFloatAnim(param)
    if param.index > param.max then
        if param.onFinish then param.onFinish(param) end
        return
    end
    local delayTime = 0.1
    local timerKey = param.key .. "_" .. param.index
    local timer = self:AddUniqueTimer(timerKey,1,delayTime,self:ToFunc("OnShowSingleResFloatAnim"),false)
    local randPosX = param.startPos.x + math.random(-100,100)
    local randPosY = param.startPos.y + math.random(-100,100)
    param.centerPos = Vector2(randPosX,randPosY)
    timer:SetArgs(param)
end

function MainuiAnimEffectView:OnShowSingleResFloatAnim(param)
    local obj = GameObject.Instantiate(param.template)
    obj:SetActive(true)
    local rect = obj:GetComponent(RectTransform)
    rect:SetParent(param.parent)
    rect.transform:Reset()
    self:MoveToTargetPos(obj:GetComponent(RectTransform),param.centerPos,param.targetPos,param.ease,param.duration)

    param.index = param.index + 1
    self:ShowSingleResFloatAnim(param)
end

function MainuiAnimEffectView:MoveToTargetPos(rect,startPos,endPos,ease,duration)
    local anim0 = TweenMoveAnchorAnim.New(rect,startPos,0.3)
    anim0:SetEase(ease)

    local anim1 = TweenMoveAnchorAnim.New(rect,endPos,duration)
    anim1:SetEase(ease)

    local anim = TweenSequenceAnim.New({ anim0,anim1 })
    anim:SetComplete(
        self:ToFunc("OnFinishSingleResFloatAnim"),
        { rect = rect })
    anim:Play()
end

function MainuiAnimEffectView:OnFinishSingleResFloatAnim(param)
    GameObject.Destroy(param.rect.gameObject)
end

function MainuiAnimEffectView:OnFinishResFloatAnim(param)
    GameObject.Destroy(param.template)
end