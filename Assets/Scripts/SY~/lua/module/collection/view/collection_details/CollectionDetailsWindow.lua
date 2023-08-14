CollectionDetailsWindow = BaseClass("CollectionDetailsWindow",BaseWindow)

CollectionDetailsWindow.__showMainui = false
CollectionDetailsWindow.__topInfo = true
CollectionDetailsWindow.__bottomTab = false

CollectionDetailsWindow.Event = EventEnum.New(
    "ResetDetailsData"
)

function CollectionDetailsWindow:__Init()
    self:SetAsset("ui/prefab/collection/collection_details_window.prefab", AssetType.Prefab)

    self.attrItems = {}
    self.attrOrder = {}
    self.skillItems = {}
    self.collectEnough = false
    self.coinEnough = false
    self.upgradeEffect = nil

    self.attrInfo = {
        ["生命"] = {fn="GetMaxHp",iconPath=UITex("collection/details/12")},
        ["攻击"] = {fn="GetAtk",iconPath=UITex("collection/details/13")},
        ["射程"] = {fn="GetAtkRadius",iconPath=UITex("collection/details/14")},
        ["攻速"] = {fn="GetAtkSpeed",iconPath=UITex("collection/details/15")},
    }
end

function CollectionDetailsWindow:__Delete()
    if self.richTextTipsPanel then
        self.richTextTipsPanel:Destroy()
    end
    for i, v in ipairs(self.skillItems) do
        GameObject.Destroy(v.gameObject)
    end
    if self.upgradeEffect then
        self.upgradeEffect:Delete()
        self.upgradeEffect = nil
    end
end

function CollectionDetailsWindow:__ExtendView()
    self.skillTips = self:ExtendView(CollectionDetailsSkillTips)
    self.modelView = self:ExtendView(CollectionDetailsModelView)
end

function CollectionDetailsWindow:__CacheObject()
    self:CacheBaseInfo()
    self:CacheStand()
    self:CacheLevCon()
    self:CacheAttrCon()
    self:CacheSkillCon()
    self:CacheBtn()
end

function CollectionDetailsWindow:__Create()
    self:CreateSkillItem()
    local mask = self:Find("main/level_con_adaptation/level_con/slider/filled/mask")
    self.minFilledWidth = mask.offsetMin.x
    self.maxFilledWidth = self.filled.rect.width

    self.richTextTipsPanel = RichTextTipsPanel.New()
    self.richTextTipsPanel:SetParent(self:Find(""))
    self.richTextTipsPanel:Show()
end

function CollectionDetailsWindow:__BindEvent()
    self:BindEvent(CollectionDetailsWindow.Event.ResetDetailsData)
end

function CollectionDetailsWindow:__BindListener()
    self.lastBtn:SetClick( self:ToFunc("SwitchBesideUnitDetails"), -1 )
    self.nextBtn:SetClick( self:ToFunc("SwitchBesideUnitDetails"), 1 )
    self.videoBtn:SetClick( self:ToFunc("ShowVideoPanel") )
    self.backBtn:SetClick( self:ToFunc("OnBackBtnClick") )
    self.upgradeBtn:SetClick( self:ToFunc("Upgrade") )

    self:AddAnimEffectListener("details_window_enter",self:ToFunc("OnAnimEffectPlay"))
end

function CollectionDetailsWindow:__Hide()
end

function CollectionDetailsWindow:__Show()
    mod.RemindCtrl:SetRemind(RemindDefine.RemindId.collection_new_unit,false,self.args.id)
    self:SetData(self.args.id)

    mod.PlayerGuideEventCtrl:Trigger(PlayerGuideDefine.Event.on_view_open, "roleAttr")

    self:PlayAnim("details_window_enter")
end

function CollectionDetailsWindow:CacheBaseInfo()
    self.qualityImg = self:Find("main/base_info_adaptation/base_info/quality_pivot/quality_img",Image)
    self.nameText = self:Find("main/base_info_adaptation/base_info/name_bg/name_text",Text)
    self.jobIcon = self:Find("main/base_info_adaptation/base_info/job",Image)
    self.featureText = self:Find("main/base_info_adaptation/base_info/feature",Text)
end

function CollectionDetailsWindow:CacheStand()
    self.standInverted = self:Find("main/stand_model_adaptation/stand/stand_inverted",Image)
    self.standShadow = self:Find("main/stand_model_adaptation/stand/stand_shadow",Image)
    self.stand = self:Find("main/stand_model_adaptation/stand/stand",Image)
end

function CollectionDetailsWindow:CacheLevCon()
    self.filled = self:Find("main/level_con_adaptation/level_con/slider/filled")
    self.count = self:Find("main/level_con_adaptation/level_con/slider/count",Text)
    self.lev = self:Find("main/level_con_adaptation/level_con/lev_bg/lev",Text)
    self.upgradeBtnNode = self:Find ("main/upgrade_btn_adaptation/upgrade_btn").gameObject
    self.consumeNode = self:Find("main/upgrade_btn_adaptation/upgrade_btn/btn/layout/consume").gameObject
    self.consumeCoinText = self:Find("main/upgrade_btn_adaptation/upgrade_btn/btn/layout/consume/num",Text)
end

function CollectionDetailsWindow:CacheAttrCon()
    for i = 1, 4 do
        local attrItem = {}
        attrItem.transform = self:Find("main/attr_con_adaptation/attr_con/attr_"..i)
        attrItem.gameObject = attrItem.transform.gameObject
        attrItem.icon = attrItem.transform:Find("icon_bg/icon").gameObject:GetComponent(Image)
        attrItem.title = attrItem.transform:Find("title").gameObject:GetComponent(Text)
        attrItem.num = attrItem.transform:Find("num").gameObject:GetComponent(Text)
        attrItem.add = attrItem.transform:Find("add").gameObject:GetComponent(Text)

        table.insert(self.attrItems,attrItem)
    end
end

function CollectionDetailsWindow:CacheSkillCon()
    self.skillCon = self:Find("main/skill_con_adaptation/skill_con")
    self.skillItemTemp = self:Find("main/skill_con_adaptation/skill_con/skill_item").gameObject
end

function CollectionDetailsWindow:CacheBtn()
    self.lastBtn = self:Find("main/switch_btn_adaptation/last_btn",Button)
    self.nextBtn = self:Find("main/switch_btn_adaptation/next_btn",Button)
    self.videoBtn = self:Find("main/video_btn_adaptation/video_btn",Button)
    self.backBtn = self:Find("main/back_btn_adaptation/back_btn/btn",Button)
    self.upgradeBtn = self:Find("main/upgrade_btn_adaptation/upgrade_btn/btn",Button)
end

function CollectionDetailsWindow:CreateSkillItem()
    for i = 1, 4 do
        local skillItem = {}
        skillItem.gameObject = GameObject.Instantiate(self.skillItemTemp)
        skillItem.transform = skillItem.gameObject.transform
        skillItem.transform:SetParent(self.skillCon)
        skillItem.transform:Reset()

        skillItem.icon = skillItem.transform:Find("icon").gameObject:GetComponent(Image)
        skillItem.btn = skillItem.transform:Find("icon").gameObject:GetComponent(Button)
        skillItem.normalNode = skillItem.transform:Find("normal").gameObject
        skillItem.lev = skillItem.transform:Find("normal/lev").gameObject:GetComponent(Text)
        skillItem.lockNode = skillItem.transform:Find("lock").gameObject
        skillItem.gameObject:SetActive(false)
        table.insert(self.skillItems,skillItem)
    end
    self.skillItemTemp.gameObject:SetActive(false)
end

function CollectionDetailsWindow:ResetDetailsData(id)
    mod.RemindCtrl:SetRemind(RemindDefine.RemindId.collection_new_unit,false,id)
    self:SetData(id)
end

function CollectionDetailsWindow:SetData(id)
    self.unitConf = Config.UnitData.data_unit_info[id]
    self.data = mod.CollectionProxy:GetDataById(id)
    local key = nil
    local nextKey = nil
    if self.data then
        key = id.."_"..self.data.level
        nextKey = id.."_"..self.data.level + 1
    else
        key = id.."_"..1
    end
    self.levConf = Config.UnitData.data_unit_lev_info[key]
    self.nextLevConf = Config.UnitData.data_unit_lev_info[nextKey]

    self:SetShow()
end

function CollectionDetailsWindow:SetShow()
    self:SetBaseInfo()
    self:SetStand()
    self:SetLevCon()
    self:SetAttrCon()
    self:SetSkillCon()
    -- self:SetUpgradeBtnState()
end

function CollectionDetailsWindow:SetBaseInfo()
    local path = CollectionDefine.DetailsQualityImg[self.unitConf.quality]
    self:SetSprite(self.qualityImg,path)
    self.qualityEffectId = CollectionDefine.DetailsQualityEffectId[self.unitConf.quality]
    if self.qualityEffectUid then
        self:RemoveEffect(self.qualityEffectUid)
        local effect = self:LoadUIEffect({
            confId = self.qualityEffectId,
            delayTime = 0.2166,
            lastTime = 0,
            scale = {x=1000,y=1000,z=1000},
            pos = {x=0,y=0,z=0},
            parent = self.qualityImg.transform,
            order = self:GetOrder() + 10,
        },true)
        self.qualityEffectUid = effect.uid
    end

    self.nameText.text = self.unitConf.name

    path = CollectionDefine.JobToIcon[self.unitConf.job]
    self:SetSprite(self.jobIcon,path)

    self.featureText.text = self.unitConf.feature
end

function CollectionDetailsWindow:SetStand()
    --[[ -- 2d立绘
    -- local path = { inverted = "", shadow = "", stand = "" }
    local path = CollectionDefine.GetDetailsStandPath(self.unitConf.head)
    -- self:SetSprite(self.standInverted,path.inverted)
    -- self:SetSprite(self.standShadow,path.shadow)
    self:SetSprite(self.stand,path.stand,true)
    ]]
    self.modelView:LoadModel(self.unitConf.id)
end

function CollectionDetailsWindow:SetLevCon()
    local progress = 0
    local countText = ""
    self.collectEnough = false
    self.coinEnough = false
    if self.data and self.data.level then
        self.lev.text = self.data.level

        local consumeNum = 0
        if self.nextLevConf then
            consumeNum = self.nextLevConf.lv_up_count
            if consumeNum > 0 then
                progress = Mathf.Clamp(self.data.count / consumeNum, 0, 1)
            else
                progress = 1
            end
            countText = self.data.count.."/"..consumeNum
            self.collectEnough = progress == 1
            local consumeCoin = self.nextLevConf.lv_up_coin_count
            self.consumeCoin = consumeCoin

            local roleGold = mod.RoleItemProxy:GetItemNum(GDefine.ItemId.Gold)
            local color = "#CF4147"
            if roleGold >= consumeCoin then
                color = "#FFFFFF"
                self.coinEnough = true
            end
            self.consumeCoinText.text = UIUtils.GetColorText(consumeCoin,color)
            self.consumeNode:SetActive(true)
            self.upgradeBtnNode.gameObject:SetActive(true)
        else
            self.consumeNode:SetActive(false)
            self.upgradeBtnNode.gameObject:SetActive(false)
        end
    else
        self.lev.text = "1"
        self.consumeNode:SetActive(false)
        self.upgradeBtnNode.gameObject:SetActive(false)
    end
    self.count.text = countText
    local width = Mathf.Lerp(self.minFilledWidth, self.maxFilledWidth, progress)
    UnityUtils.SetSizeDelata(self.filled,width,self.filled.rect.height)
end

function CollectionDetailsWindow:SetAttrCon()
    local attrOrderConf = Config.ConstData.data_const_info["unit_attr_name_order"].val
    for k, v in pairs(attrOrderConf) do
        self.attrOrder[v[1]] = v[2]
    end
    for i = 1, #self.attrOrder do
        local title = TI18N(self.attrOrder[i])
        local info = self.attrInfo[self.attrOrder[i]]
        local val,addVal = self[info.fn](self)
        if addVal > 0 then
            addVal = "+"..tostring(addVal)
        else
            addVal = ""
        end

        local attrItem = self.attrItems[i]
        self:SetSprite(attrItem.icon, info.iconPath,true)
        attrItem.title.text = title
        attrItem.num.text = val
        attrItem.add.text = addVal
    end
end

function CollectionDetailsWindow:GetMaxHp()
    local maxHp = 0
    local addNum = 0
    maxHp,addNum = AttrUtils.GetAttrValue(self.unitConf.id,GDefine.Attr.max_hp)
    return maxHp,addNum
end

function CollectionDetailsWindow:GetAtk()
    local atk = 0
    local addNum = 0
    atk,addNum = AttrUtils.GetAttrValue(self.unitConf.id,GDefine.Attr.atk)
    return atk,addNum
end

function CollectionDetailsWindow:GetAtkRadius()
    local atkRadius = 0
    local addNum = 0
    atkRadius = self.unitConf.atk_radius_show
    return atkRadius,addNum
end

function CollectionDetailsWindow:GetAtkSpeed()
    local val,addNum = AttrUtils.GetAttrValue(self.unitConf.id,GDefine.Attr.atk_speed)
    local atkSpeed = self.unitConf.atk_time / val
    local atkSpeedAddNum = addNum~=0 and self.unitConf.atk_time / addNum or 0
    return atkSpeed,atkSpeedAddNum
end

function CollectionDetailsWindow:SetSkillCon()
    for i, v in ipairs(self.levConf.show_skill_list) do
        local skillId = v[1]
        local skillLev = v[2]
        local isUnlock = v[3] == 0
        local unlockStar = v[3] ~= 0 and v[3] and v[3]
        local skillBaseConf = Config.SkillData.data_skill_base[skillId]
        -- local skillLevConf = Config.SkillData.data_skill_lev[skillId.."_"..skillLev]

        local skillItem = self.skillItems[i]
        self:SetSprite(skillItem.icon,AssetPath.GetSkillIcon(skillBaseConf.icon))
        skillItem.lev.text = "Lv."..tostring(skillLev)
        -- skillItem.data = {baseConf = skillBaseConf, levConf = skillLevConf}
        skillItem.data = {baseConf = skillBaseConf}
        skillItem.btn:SetClick( self:ToFunc("ShowSkillTips"),i )
        UIUtils.Grey(skillItem.icon, not isUnlock)
        skillItem.normalNode:SetActive(isUnlock)
        skillItem.lockNode:SetActive(not isUnlock)

        skillItem.gameObject:SetActive(true)
    end

    for i = #self.levConf.show_skill_list + 1, 4 do
        self.skillItems[i].gameObject:SetActive(false)
    end
end

function CollectionDetailsWindow:SetUpgradeBtnState()
    --[[  -- 火焰特效常驻 屏蔽
    if self.collectEnough and self.coinEnough then
        if not self.upgradeEffect then
            local setting = {}
            setting.confId = 99999
            setting.parent = self.upgradeBtn.transform
            setting.order = 10  --TODO:层级需要优化

            local effect = UIEffect.New()
            effect:Init(setting)
            effect:SetPos(0,0)
            self.upgradeEffect = effect
        end
        if not self.upgradeEffect:IsActive() then
            self.upgradeEffect:Play()
        end
    else
        if self.upgradeEffect and self.upgradeEffect:IsActive() then
            self.upgradeEffect:Stop()
        end
    end
    ]]
end

function CollectionDetailsWindow:ShowSkillTips(index)
    local skillItem = self.skillItems[index]
    self.skillTips:SetData(skillItem.data,skillItem.transform)
    self.skillTips:OnActive()
end

function CollectionDetailsWindow:ShowRichTextTips(logicElementType,args,richTextTrans)
    self.richTextTipsPanel:ShowRichTextTips(logicElementType,args,richTextTrans)
end

function CollectionDetailsWindow:HideRichTextTips()
    self.richTextTipsPanel:HideRichTextTips()
end

function CollectionDetailsWindow:SwitchBesideUnitDetails(index)
    mod.CollectionCtrl:SwitchBesideUnitDetails(self.unitConf.id,index)
end

function CollectionDetailsWindow:ShowVideoPanel()
SystemMessage.Show("功能暂未实现…")
end

function CollectionDetailsWindow:OnBackBtnClick()
    ViewManager.Instance:CloseWindow(CollectionDetailsWindow)
    mod.CollectionFacade:SendEvent(CollectionWindow.Event.PlayEnterAnim)
end

function CollectionDetailsWindow:Upgrade()
    if self.nextLevConf then
        if self.data.count >= self.nextLevConf.lv_up_count then
            local costItemId = GDefine.ItemId.Gold
            local costItemNum = self.nextLevConf.lv_up_coin_count
            local flag = mod.JumpCtrl:CheckItemNumJumpWay(costItemId,costItemNum)
            if flag then
                return
            else
                mod.CollectionFacade:SendMsg(10202, self.data.unit_id)
            end
        else
            SystemMessage.Show(TI18N("您需要"..self.nextLevConf.lv_up_count.."张卡才能升级"))
        end
    else
        SystemMessage.Show(TI18N("当前卡牌已满级"))
    end
end

function CollectionDetailsWindow:OnAnimEffectPlay(animName,data)
    self:LoadUIEffectByAnimData(data,true)
    local effect = self:LoadUIEffect({
        confId = self.qualityEffectId,
        delayTime = 0.2166,
        lastTime = 0,
        scale = {x=1000,y=1000,z=1000},
        pos = {x=0,y=0,z=0},
        parent = self.qualityImg.transform,
        order = self:GetOrder() + 10,
    },true)
    self.qualityEffectUid = effect.uid
end