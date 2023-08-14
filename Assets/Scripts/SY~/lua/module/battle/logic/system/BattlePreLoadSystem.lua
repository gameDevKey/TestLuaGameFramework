BattlePreLoadSystem = BaseClass("BattlePreLoadSystem",SECBSystem)

function BattlePreLoadSystem:__Init()
    
end

function BattlePreLoadSystem:InitMaskCamera(maskCamera)
    local mainCamera = GDefine.mainCamera
    local cameraData = mainCamera.gameObject:GetComponent(Rendering.Universal.UniversalAdditionalCameraData)
    cameraData.cameraStack:Insert(1,maskCamera)

    local cullingMask = BitUtils.LShift(1,GDefine.Layer.layer10)
    maskCamera.cullingMask = cullingMask
end

function BattlePreLoadSystem:InitData()
    self.battleAssetLoaders = {}
    self.assetList = 
    {
        {file = "mixed/battle/battle_node.prefab", type = AssetType.Prefab}
    }

    self.isBattleNode = false

    self.preLoadInfo = {
        ["battleNode"] = {
            fn = "PreLoadBattleNode",
            levelToNum = {
                [GDefine.DeviceLevel.low] = 1,
                [GDefine.DeviceLevel.middle] = 1,
                [GDefine.DeviceLevel.high] = 1,
            },
            order = 1,
        },
        ["battleMainPanel"] = {
            fn = "PreLoadBattleMainPanel",
            levelToNum = {
                [GDefine.DeviceLevel.low] = 1,
                [GDefine.DeviceLevel.middle] = 1,
                [GDefine.DeviceLevel.high] = 1,
            },
            order = 2,
        },
        ["scene"] = {
            fn = "PreLoadScene",
            levelToNum = {
                [GDefine.DeviceLevel.low] = 1,
                [GDefine.DeviceLevel.middle] = 1,
                [GDefine.DeviceLevel.high] = 1,
            },
            order = 3,
        },
        -- ["operateTexture"] = {
        --     fn = "PreLoadOperateTexture",
        --     levelToNum = {
        --         [GDefine.DeviceLevel.low] = 1,
        --         [GDefine.DeviceLevel.middle] = 1,
        --         [GDefine.DeviceLevel.high] = 1,
        --     },
        --     order = 4,
        -- },
        -- ["unitTpose"] = {
        --     fn = "PreLoadUnitTpose",
        --     levelToNum = {
        --         [GDefine.DeviceLevel.low] = 1,
        --         [GDefine.DeviceLevel.middle] = 1,
        --         [GDefine.DeviceLevel.high] = 1,
        --     },
        --     order = 5,
        -- },
        -- ["battleEffect"] = {
        --     fn = "PreLoadBattleEffect",
        --     levelToNum = {
        --         [GDefine.DeviceLevel.low] = 0,
        --         [GDefine.DeviceLevel.middle] = 0,
        --         [GDefine.DeviceLevel.high] = 1,
        --     },
        --     order = 6,
        -- }
    }
end

function BattlePreLoadSystem:PreLoadBattleAsset()
    self:InitData()
    local deviceLevel = DevicesManager.Instance:GetDeviceLevel() --TODO 根据不同设备硬件性能计算出分级
    
    -- 根据设备分级获取要预加载的内容列表总数，作为进度条的分母
    self.totalPreLoad = 0
    for k, v in pairs(self.preLoadInfo) do
        self.totalPreLoad = self.totalPreLoad + 1
    end

    --TODO 设置敌我双方单位列表
    local roleUid = mod.RoleProxy.roleData["role_uid"]
    for k, v in pairs(mod.BattleProxy.readyEnterData.role_list) do
        if v.role_base.role_uid == roleUid then
            self.selfObjectList = v.object_list
            self.selfUnitList = v.unit_list
        else
            self.enemyObjectList = v.object_list
            self.enemyUnitList = v.unit_list
        end
    end
    if not self.selfObjectList or next(self.selfObjectList) == nil then  -- 回放模式且不存在自己的roleUid
        for k, v in pairs(mod.BattleProxy.readyEnterData.role_list) do
            if v.camp == BattleDefine.Camp.attack then
                self.selfObjectList = v.object_list
                self.selfUnitList = v.unit_list
            else
                self.enemyObjectList = v.object_list
                self.enemyUnitList = v.unit_list
            end
        end
    end

    -- self:SetPreLoadUnitTposeList(self.preLoadInfo["unitTpose"].levelToNum[deviceLevel])
    -- self.totalPreLoad = self.totalPreLoad + self.unitTposeTotalLoadNum

    -- self:SetPreLoadBattleEffectList(self.preLoadInfo["battleEffect"].levelToNum[deviceLevel])
    -- self.totalPreLoad = self.totalPreLoad + self.battleEffectTotalLoadNum

    self.preLoadProgress = {}
    -- 开始调用对应预加载方法
    self.nowPreLoad = 0
    for k, v in pairs(self.preLoadInfo) do
        self[v.fn](self)
    end
end

function BattlePreLoadSystem:PreLoadBattleNode()
    if self.isBattleNode then
        self:CheckPreLoadComplete(self.preLoadInfo["battleNode"].order)
        return
    end
    self.isBattleNode = true
    local assetList = {}
    table.insert(assetList,{file = "mixed/battle/battle_node.prefab", type = AssetType.Prefab})
    local assetLoader = AssetBatchLoader.New()
    self.battleAssetLoaders["battleNode"] = {assetLoader = assetLoader,assetList = assetList}
    assetLoader:Load(assetList,self:ToFunc("BattleNodeLoaded"))
end

function BattlePreLoadSystem:BattleNodeLoaded()
    if not BattleDefine.rootNode then
        local battleNodeLoadInfo = self.battleAssetLoaders["battleNode"]
        local assetLoader = battleNodeLoadInfo.assetLoader
        BattleDefine.rootNode = assetLoader:GetAsset("mixed/battle/battle_node.prefab")
        BattleDefine.rootNode.name = "BattleNode"
        GameObject.DontDestroyOnLoad(BattleDefine.rootNode)
        BattleDefine.rootNode.transform:Reset()
        BattleDefine.rootNode:SetActive(false)
    end

    local rootTrans = BattleDefine.rootNode.transform

    BattleDefine.nodeObjs["mixed"] = rootTrans:Find("mixed")
    BattleDefine.nodeObjs["entity"] = rootTrans:Find("entity")

    BattleDefine.nodeObjs["map_parent"] = rootTrans:Find("map")

    BattleDefine.nodeObjs["template/unit_bound"] = rootTrans:Find("template/bound/unit_bound").gameObject
    BattleDefine.nodeObjs["template/empty_bound"] = rootTrans:Find("template/bound/empty_bound").gameObject

    BattleDefine.nodeObjs["terrain_collider"] = rootTrans:Find("terrain_collider").gameObject:GetComponent(BoxCollider)

    BattleDefine.nodeObjs["effect"] = rootTrans:Find("effect")

    BattleDefine.nodeObjs["mixed/commander_collider"] = rootTrans:Find("mixed/commander_collider")

    BattleDefine.nodeObjs["main_camera"] = GDefine.mainCamera--rootTrans:Find("camera/main_camera"):GetComponent(Camera)
    -- BattleDefine.nodeObjs["scene_camera"] = rootTrans:Find("camera/scene_camera"):GetComponent(Camera)

    BattleDefine.nodeObjs["camera/mask_camera"] = rootTrans:Find("camera/mask_camera").gameObject:GetComponent(Camera)
    self:InitMaskCamera(BattleDefine.nodeObjs["camera/mask_camera"])

    BattleDefine.nodeObjs["mask_panel"] = rootTrans:Find("mask_panel").gameObject
    BaseUtils.ChangeLayers(BattleDefine.nodeObjs["mask_panel"],GDefine.Layer.layer6)

    --local cameraData = GDefine.mainCamera:GetComponent(Rendering.Universal.UniversalAdditionalCameraData)
    --cameraData.cameraStack:Insert(0,BattleDefine.nodeObjs["main_camera"])

    if not BattleDefine.nodeObjs["main_camera_holder"] then
        local cameraHolder = GameObject("MainCameraHolder")
        cameraHolder.transform.localPosition = Vector3(0,0,0)
        GDefine.mainCamera.transform:SetParent(cameraHolder.transform,true)
        BattleDefine.nodeObjs["main_camera_holder"] = cameraHolder
        GameObject.DontDestroyOnLoad(cameraHolder)
    end

    local cameraAnimatorTemp = rootTrans:Find("enter_anim").gameObject:GetComponent(Animator)
    local cameraAnimator = GDefine.mainCamera.gameObject:GetComponent(Animator) or GDefine.mainCamera.gameObject:AddComponent(Animator)
    cameraAnimator.runtimeAnimatorController = cameraAnimatorTemp.runtimeAnimatorController
    BattleDefine.nodeObjs["main_camera_animator"] = cameraAnimator

    self:CheckPreLoadComplete(self.preLoadInfo["battleNode"].order)
end

function BattlePreLoadSystem:PreLoadBattleMainPanel()
    local assetList = {}
    table.insert(assetList,{file = "ui/prefab/battle/battle_main_panel.prefab", type = AssetType.Prefab})
    table.insert(assetList,{file = "anim/ui/battle/battle_main_panel.controller", type = AssetType.Object})
    -- table.insert(assetList,{file = skyBoxFile, type = AssetType.Object})
    local assetLoader = AssetBatchLoader.New()
    self.battleAssetLoaders["mainPanel"] = {assetLoader = assetLoader,assetList = assetList}
    assetLoader:Load(assetList,self:ToFunc("MainPanelLoaded"))
end

function BattlePreLoadSystem:MainPanelLoaded()
    local mainPanelLoadInfo = self.battleAssetLoaders["mainPanel"]
    local assetLoader = mainPanelLoadInfo.assetLoader
    self.mainPanelObject = assetLoader:GetAsset(mainPanelLoadInfo.assetList[1].file)
    
    local autoReleaser = self.mainPanelObject:GetComponent(AssetReleaser)
    local animator = self.mainPanelObject:GetComponent(Animator)
    animator.runtimeAnimatorController = assetLoader:GetAsset(mainPanelLoadInfo.assetList[2].file)
    AssetLoaderProxy.Instance:AddReference(mainPanelLoadInfo.assetList[2].file)
    autoReleaser:Add(mainPanelLoadInfo.assetList[2].file)

    self:CheckPreLoadComplete(self.preLoadInfo["battleMainPanel"].order)
end

function BattlePreLoadSystem:PreLoadScene()
    local sceneFile = "scene/1005/1005.prefab"
    --local skyBoxFile = "scene/1001/sky/skybox_sunset.mat"
    local assetList = {}
    table.insert(assetList,{file = sceneFile, type = AssetType.Prefab})
    -- table.insert(assetList,{file = skyBoxFile, type = AssetType.Object})
    local assetLoader = AssetBatchLoader.New()
    self.battleAssetLoaders["scene"] = {assetLoader = assetLoader,assetList = assetList}
    assetLoader:Load(assetList,self:ToFunc("SceneLoaded"))
end

function BattlePreLoadSystem:SceneLoaded()
    local sceneLoadInfo = self.battleAssetLoaders["scene"]
    local assetLoader = sceneLoadInfo.assetLoader

    self.mapObject = assetLoader:GetAsset(sceneLoadInfo.assetList[1].file, BattleDefine.nodeObjs["map_parent"]) --TODO 用于战斗结束后销毁

    self:CheckPreLoadComplete(self.preLoadInfo["scene"].order)
    ----
    -- self.skyBoxObject = assetLoader:GetAsset(sceneLoadInfo.skyBoxFile)
    -- AssetLoaderProxy.Instance:AddReference(sceneLoadInfo.skyBoxFile)

    -- RenderSettings.skybox = self.skyBoxObject
    -- local mapTex = assetLoader:GetAsset(assetLoadInfo.mapFile)
    -- AssetLoaderProxy.Instance:AddReference((assetLoadInfo.mapFile)
    --self.sharedMaterial.mainTexture = self.tex
    --self:RemoveLoader()
    
    
    --SceneManagement.SceneManager.LoadScene("1001")

    -- local assetLoadInfo = self.assetLoaders["scene"]
    -- local assetLoader = assetLoadInfo.assetLoader
    -- local sceneObj = assetLoader:GetAsset(assetLoadInfo.sceneFile)
end


function BattlePreLoadSystem:PreLoadOperateTexture()
    local operateTextureList = {}
    local commanderSkillList = nil
    for k, v in pairs(self.selfObjectList) do
        local conf = Config.UnitData.data_unit_info[v.unit_id]
        if conf.type == GDefine.UnitType.commander then
            commanderSkillList = v.skill_list
            break
        end
    end
    local dragSkillList = {}
    for k, v in pairs(commanderSkillList) do
        local conf = Config.SkillData.data_skill_base[v.skill_id]
        if conf.rel_type == SkillDefine.RelType.manual then
            table.insert(dragSkillList,{skillId = v.skill_id})
        end
    end
    for k,v in pairs(dragSkillList) do
        local skillIcon = {}
        skillIcon.file = AssetPath.GetBattleCommanderSkillIcon(v.skillId)
        skillIcon.type = AssetType.Sprite
        table.insert(operateTextureList,skillIcon)
        break
    end

    for k,v in pairs(self.selfUnitList) do
        local unitConf = Config.UnitData.data_unit_info[v.unit_id]
        local unitIcon = {}
        unitIcon.file = AssetPath.GetBattleOperateIcon(unitConf.head)
        unitIcon.type = AssetType.Sprite
        table.insert(operateTextureList,unitIcon)
    end
    local assetLoader = AssetBatchLoader.New()
    self.battleAssetLoaders["operateTexture"] = {assetLoader = assetLoader,assetList = operateTextureList}

    assetLoader:Load(operateTextureList,self:ToFunc("CheckPreLoadComplete"),self.preLoadInfo["operateTexture"].order)
end

function BattlePreLoadSystem:SetPreLoadUnitTposeList(levelToNum)
    if not self.unitTposeInfo then
        self.unitTposeInfo = SECBList.New()
    end
    self.unitTposeInfo:Clear()

    self.unitTposes = {}

    self.unitTposeTotalLoadNum = 0
    self.unitTposeLoadNum = 0
    for k, v in pairs(self.selfUnitList) do
        local conf = Config.UnitData.data_unit_info[v.unit_id]
        local setting = {}
        setting.modelId = conf.model_id
        setting.skinId = conf.skin_id
        setting.animId = conf.anim_id
        local key = string.format("%s_%s_%s",setting.modelId,setting.skinId,setting.animId)

        local unitNum = conf.unit_num * levelToNum
        local poolExistNum = PoolManager.Instance.poolDict[PoolType.hero_tpose]:ExistNum(key)
        local maxExistNum = PoolDefine.poolMaxExistNum[PoolType.hero_tpose]
        local restNum = maxExistNum - poolExistNum

        if restNum > 0 then
            if unitNum > restNum then
                unitNum = restNum
            end
            self.unitTposeInfo:Push({setting = setting,num = unitNum},v.unit_id)
            self.unitTposeTotalLoadNum = self.unitTposeTotalLoadNum + unitNum
        end
    end

    for k, v in pairs(self.enemyUnitList) do
        local conf = Config.UnitData.data_unit_info[v.unit_id]
        local setting = {}
        setting.modelId = conf.model_id
        setting.skinId = conf.skin_id
        setting.animId = conf.anim_id
        local key = string.format("%s_%s_%s",setting.modelId,setting.skinId,setting.animId)
        local poolExistNum = PoolManager.Instance.poolDict[PoolType.hero_tpose]:ExistNum(key)
        local maxExistNum = PoolDefine.poolMaxExistNum[PoolType.hero_tpose]
        local restNum = maxExistNum - poolExistNum
        if self.unitTposeInfo:ExistIndex(v.unit_id) then
            local iter = self.unitTposeInfo:GetIterByIndex(v.unit_id)
            if restNum > 0 then
                local toAddNum = iter.value.num * 2
                if toAddNum > restNum then
                    toAddNum = restNum
                end
                self.unitTposeTotalLoadNum = self.unitTposeTotalLoadNum - iter.value.num + toAddNum
                iter.value.num = toAddNum
            end
        else
            local unitNum = conf.unit_num * levelToNum
            if restNum > 0 then
                if unitNum > restNum then
                    unitNum = restNum
                end
                self.unitTposeInfo:Push({setting = setting,num = unitNum},v.unit_id)
                self.unitTposeTotalLoadNum = self.unitTposeTotalLoadNum + unitNum
            end
        end
    end
end


function BattlePreLoadSystem:PreLoadUnitTpose()
    if self.unitTposeLoadNum > 0 or self.unitTposeInfo.length <= 0 then
        return
    end
    local info = self.unitTposeInfo:PopHead()

    for i = 1, info.num do
        self.unitTposeLoadNum = self.unitTposeLoadNum + 1
        local tpose = HeroTpose.New()
        local key = string.format("%s_%s_%s",info.setting.modelId,info.setting.skinId,info.setting.animId)
        tpose:Load(info.setting,self:ToFunc("OnSingleUnitTposeLoaded"))
        table.insert(self.unitTposes,{tpose = tpose,key = key})
    end
end

function BattlePreLoadSystem:OnSingleUnitTposeLoaded()
    self.unitTposeLoadNum = self.unitTposeLoadNum - 1
    self:CheckPreLoadComplete(self.preLoadInfo["unitTpose"].order)
    self.unitTposeTotalLoadNum = self.unitTposeTotalLoadNum - 1
    if self.unitTposeTotalLoadNum > 0 then
        self:PreLoadUnitTpose()
        return
    end
    for k, v in pairs(self.unitTposes) do
        PoolManager.Instance:Push(PoolType.hero_tpose,v.key,v.tpose)
    end
    self:CheckPreLoadComplete(self.preLoadInfo["unitTpose"].order)
end

function BattlePreLoadSystem:SetPreLoadBattleEffectList(levelToNum)
    self.battleEffectInfo = {}

    self.battleEffectTotalLoadNum = 0
    self.battleEffectLoadNum = 0
    local objectList = {
        [1] = self.selfObjectList,
        [2] = self.enemyObjectList,
    }
    for k0, v0 in pairs(objectList) do
        for k, v in pairs(v0) do
            for k2, v2 in pairs(v.skill_list) do
                local skillLevConf = RunWorld.BattleConfSystem:SkillData_data_skill_lev(v2.skill_id,v2.skill_level)
                if not skillLevConf then
                    assert(false,string.format("技能skillId[%s]skillLev[%s]获取不到对应的配置",v2.skill_id,v2.skill_level))
                end
                local actConf = RunWorld.BattleConfSystem:SkillTimeline(skillLevConf.act_id)
                -- LogTable("actConf"..v2.skill_id.."-"..v2.skill_level,actConf)
                if actConf and actConf.Event then
                    for i1, v3 in ipairs(actConf.Event) do
                        for i2, v4 in ipairs(v3.action) do
                            if v4.effectId and v4.effectId ~= 0 then
                                self:SetBattleEffect(v4.effectId,levelToNum)
                            end
                            if v4.flyEffectId and v4.flyEffectId ~= 0 then
                                self:SetBattleEffect(v4.flyEffectId,levelToNum)
                            end
                            if v4.hitEffectId and v4.hitEffectId ~= 0 then
                                self:SetBattleEffect(v4.hitEffectId,levelToNum)
                            end
                            if v4.bouncingEffectId and v4.bouncingEffectId ~= 0 then
                                self:SetBattleEffect(v4.bouncingEffectId,levelToNum)
                            end
                        end
                    end
                end
            end
        end
    end
end

function BattlePreLoadSystem:SetBattleEffect(effectId,levelToNum)
    if levelToNum <= 0 then
        return
    end
    local conf = RunWorld.BattleConfSystem:EffectData_data_skill_effect(effectId)
    local effectPath = string.format("effect/%s.prefab",conf.asset_id)
    local poolExistNum = PoolManager.Instance.poolDict[PoolType.battle_effect]:ExistNum(effectPath)
    local maxExistNum = PoolDefine.poolMaxExistNum[PoolType.battle_effect]
    local restNum = maxExistNum - poolExistNum
    if self.battleEffectInfo[effectPath] then
        local info = self.battleEffectInfo[effectPath]
        if restNum > 0 then
            local toAddNum = levelToNum
            if info.num + toAddNum > maxExistNum then
                toAddNum = maxExistNum
            end
            self.battleEffectTotalLoadNum = self.battleEffectTotalLoadNum - info.num + toAddNum
            info.num = toAddNum
        end
    else
        local toAddNum = levelToNum
        if restNum > 0 then
            if toAddNum > restNum then
                toAddNum = restNum
            end
            self.battleEffectInfo[effectPath]={effectPath = effectPath,num = toAddNum}
            self.battleEffectTotalLoadNum = self.battleEffectTotalLoadNum + toAddNum
        end
    end
end

function BattlePreLoadSystem:PreLoadBattleEffect()
    local assetList = {}
    for k, v in pairs(self.battleEffectInfo) do
        local effectPath = v.effectPath
        table.insert(assetList,{file = effectPath, type = AssetType.Prefab})
    end
    local assetLoader = AssetBatchLoader.New()
    self.battleAssetLoaders["battleEffect"] = {assetLoader = assetLoader,assetList = assetList}
    assetLoader:Load(assetList,self:ToFunc("OnBattleEffectLoaded"))
end

function BattlePreLoadSystem:OnBattleEffectLoaded()
    local assetLoader = self.battleAssetLoaders["battleEffect"].assetLoader
    for k, v in pairs(self.battleEffectInfo) do
        local asset = assetLoader:GetAsset(v.effectPath)
        for i = 1, v.num-1 do
            local effect = GameObject.Instantiate(asset)
            PoolManager.Instance:Push(PoolType.battle_effect,v.effectPath,effect)
            self:CheckPreLoadComplete(self.preLoadInfo["battleEffect"].order)
        end
        PoolManager.Instance:Push(PoolType.battle_effect,v.effectPath,asset)
        self:CheckPreLoadComplete(self.preLoadInfo["battleEffect"].order)
    end
    self:CheckPreLoadComplete(self.preLoadInfo["battleEffect"].order)
end

function BattlePreLoadSystem:ClearLoadersAndAsset()
    if BattleDefine.mainPanel then
        BattleDefine.mainPanel:Destroy()
        BattleDefine.mainPanel = nil
    end
    if self.mapObject then
        GameObject.Destroy(self.mapObject)
        self.mapObject = nil
    end

    for k, v in pairs(self.battleAssetLoaders) do
        v.assetLoader:Destroy()
    end
    self.battleAssetLoaders = {}

    if self.unitTposeInfo then
        self.unitTposeInfo:Delete()
        self.unitTposeInfo = nil
    end
end

function BattlePreLoadSystem:CheckPreLoadComplete(order)
    if not self.preLoadProgress[order] then
        self.preLoadProgress[order] = 0
    end
    self.preLoadProgress[order] = self.preLoadProgress[order] + 1
    self.nowPreLoad = self.nowPreLoad + 1
    local progress = self.nowPreLoad / self.totalPreLoad * 100
    mod.BattleFacade:SendEvent(BattleLoadWindow.Event.UpdateProgress,progress)
    -- LogError(self.nowPreLoad.."/"..self.totalPreLoad)
    -- LogTable("preLoadProgress",self.preLoadProgress)
    if self.nowPreLoad >= self.totalPreLoad then
        self.waitTimer = TimerManager.Instance:AddTimer(1,0.2,self:ToFunc("PreLoadComplete"))
    end
end

function BattlePreLoadSystem:PreLoadComplete()
    self:RemoveWaitTimer()
    self:SetMapToBattleNode()
    RunWorld.BattleEnterSystem:EnterComplete()
end

function BattlePreLoadSystem:RemoveWaitTimer()
    if self.waitTimer then
        TimerManager.Instance:RemoveTimer(self.waitTimer)
        self.waitTimer = nil
    end
end

function BattlePreLoadSystem:SetMapToBattleNode()
    self.mapObject.transform:SetParent(BattleDefine.nodeObjs["map_parent"])
end