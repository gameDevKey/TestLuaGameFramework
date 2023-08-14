ViewModelTpose = BaseClass("ViewModelTpose")
ViewModelTpose.RootObjKey = "ViewModelTposeRoot"

function ViewModelTpose:__Init()
    self.callBack = nil
    self.assetLoader = nil
    self.autoReleaser = nil
    self.setting = nil
    self.isComplete = false
    self.root = nil
    self.pointerId = nil
    self.moveListenId = nil
    self.ModelDownFunc = self:ToFunc("OnModelDown")
end

function ViewModelTpose:__Delete()
    if self.gameObject then
        GameObject.Destroy(self.gameObject)
        self.gameObject = nil
    end

    if self.root then
        PoolManager.Instance:Push(PoolType.object, ViewModelTpose.RootObjKey, self.root)
        self.root = nil
    end

    self:RemoveDragListeners()
    self:RemoveLoader()
end

--[[
    setting = {
        (unitId,) modelId, animId, skinId, args, parent,
        onClick, onDrag, 
    }
]]--
function ViewModelTpose:Load(setting,callBack)
    -- LogYqh("ViewModelTpose:Load",tostring(self),setting)
    self.setting = setting
    self.callBack = callBack

    if self.setting.unitId then
        local unitData = Config.UnitData.data_unit_info[self.setting.unitId]
        if unitData then
            self.setting.modelId = unitData.model_id
            self.setting.skinId = unitData.skin_id
            self.setting.animId = unitData.anim_id
        end
    end

    self.modelFile = string.format("unit/%s/%s.prefab",self.setting.modelId,self.setting.modelId)
    self.animFile = string.format("unit/%s/%s.controller",self.setting.modelId,self.setting.animId)
    self.skinFile = string.format("unit/%s/%s_albedo.tga",self.setting.modelId,self.setting.skinId)
    self.maskFile = string.format("unit/%s/%s_mask.tga",self.setting.modelId,self.setting.skinId)
    self.normalFile = string.format("unit/%s/%s_normal.tga",self.setting.modelId,self.setting.skinId)

    local assetList = {}
    table.insert(assetList, {file = self.modelFile,type = AssetType.Prefab })
    table.insert(assetList, {file = self.animFile,type = AssetType.Object })
    table.insert(assetList, {file = self.skinFile,type = AssetType.Object })
    table.insert(assetList, {file = self.maskFile,type = AssetType.Object })
    table.insert(assetList, {file = self.normalFile,type = AssetType.Object })

    self.root = PoolManager.Instance:Pop(PoolType.object, ViewModelTpose.RootObjKey)
    if not self.root then
        table.insert(assetList, {file = AssetPath.viewModelRoot, type = AssetType.Prefab })
    end

    self.assetLoader = AssetBatchLoader.New()
    self.assetLoader:Load(assetList,self:ToFunc("OnLoaded"))
end

function ViewModelTpose:OnLoaded()
    if self:CancelBuildTpose() then
        return
    end

    self:BuildModel()
    self:BuildSkin()
    self:BuildAnim()

    self:RemoveLoader()

    self.isComplete = true
    self:TposeComplete()
end

function ViewModelTpose:BuildModel()
    self.gameObject = self.assetLoader:GetAsset(self.modelFile)
    self.gameObject:SetActive(true)
    self.transform = self.gameObject.transform
    self.autoReleaser = self.gameObject:GetComponent(AssetReleaser)
    self.renderer = self.gameObject:GetComponentInChildren(Renderer)
    self.mat = self.renderer.material

    self.renderer.receiveShadows = false

    if GDefine.platform == GDefine.PlatformType.WebGLPlayer then
        self.renderer.shadowCastingMode = ShadowCastingMode.Off
    else
        self.renderer.shadowCastingMode = ShadowCastingMode.On
    end

    if not self.root then
        self.root = self.assetLoader:GetAsset(AssetPath.viewModelRoot)
    end

    if self.setting.parent then
        self.root.transform:SetParent(self.setting.parent)
        local rect = self.root:GetComponent(RectTransform)
        rect.anchoredPosition3D = Vector3.zero
    end
    self.transform:SetParent(self.root.transform:Find("tpose"))
    self.transform:Reset()

    if self.setting.layer then
        BaseUtils.ChangeLayers(self.root, self.setting.layer, false)
    end

    if self.setting.eulerAngles then
        UnityUtils.SetLocalEulerAngles(self.transform,
            self.setting.eulerAngles.x,self.setting.eulerAngles.y,self.setting.eulerAngles.z)
    end

    if self.setting.scale then
        UnityUtils.SetLocalScale(self.root.transform,
            self.setting.scale.x,self.setting.scale.y,self.setting.scale.z)
    end
end

function ViewModelTpose:BuildSkin()
    self.skinTex = self.assetLoader:GetAsset(self.skinFile)
    AssetLoaderProxy.Instance:AddReference(self.skinFile)
    self.autoReleaser:Add(self.skinFile)

    self.maskTex = self.assetLoader:GetAsset(self.maskFile)
    AssetLoaderProxy.Instance:AddReference(self.maskFile)
    self.autoReleaser:Add(self.maskFile)

    self.normalTex = self.assetLoader:GetAsset(self.normalFile)
    AssetLoaderProxy.Instance:AddReference(self.normalFile)
    self.autoReleaser:Add(self.normalFile)

    self.mat:SetTexture("_BaseMap",self.skinTex)
    self.mat:SetTexture("_MaskMap",self.maskTex)
    self.mat:SetTexture("_BumpTex",self.normalTex)
end

function ViewModelTpose:BuildAnim()
    self.animCtrl = self.assetLoader:GetAsset(self.animFile)
    AssetLoaderProxy.Instance:AddReference(self.animFile)
    self.autoReleaser:Add(self.animFile)
    self.animator = self.gameObject:GetComponent(Animator)
    self.animator.runtimeAnimatorController = self.animCtrl
end

function ViewModelTpose:TposeComplete()
    self:CacheObjects()
    self:BindListeners()
    if self.callBack then
        self.callBack(self, self.setting.args)
    end
end

function ViewModelTpose:IsComplete()
    return self.isComplete
end

function ViewModelTpose:CancelBuildTpose()
    if not self.isCancel then return false end
    self:RemoveLoader()
    self:Delete()
    return true
end

function ViewModelTpose:RemoveLoader()
    if self.assetLoader then
        self.assetLoader:Destroy()
        self.assetLoader = nil
    end
end

function ViewModelTpose:OnReset()
end

function ViewModelTpose.GetSetting(config,args)
    local setting = {}
    setting.modelId = config.modelId
    setting.skinId = config.skinId
    setting.animId = config.animId
    setting.args = args
    return setting
end

function ViewModelTpose:CacheObjects()
    self.objClickArea = self.root.transform:Find("click_area")
    self.boxClickArea = self.objClickArea:GetComponent(BoxCollider)
    self.pointerHandler = self.objClickArea:GetComponent(PointerHandler)
end

function ViewModelTpose:BindListeners()
    self.pointerHandler:SetOwner(self,"ModelDownFunc","","")
    self.pointerHandler.isPointerDown = true
    self.pointerHandler.args = self.setting

    EventManager.Instance:AddEvent(EventDefine.on_app_focus, self:ToFunc("OnAppFocus"))
end

function ViewModelTpose:RemoveDragListeners()
    if self.slotMoveListenId then
        TouchManager.Instance:RemoveListen(self.slotMoveListenId)
        self.slotMoveListenId = nil
    end
    if self.slotCancelListenId then
        TouchManager.Instance:RemoveListen(self.slotCancelListenId)
        self.slotCancelListenId = nil
    end
end

function ViewModelTpose:SetBoxSize(size,center)
    if center then
        self.boxClickArea.center = center
    end
    self.boxClickArea.size = size
end

function ViewModelTpose:OnModelDown(eventData, setting)
    self.pointerId = eventData.pointerId
    -- LogYqh("ViewModelTpose:OnModelDown",self.pointerId)
    if self.setting.onClick then
        self.setting.onClick(eventData,self.setting)
    end
    local args = {setting = setting,pointerId = self.pointerId}
    self.slotMoveListenId = TouchManager.Instance:AddListen(TouchDefine.TouchEvent.move,self:ToFunc("OnModelDrag"),self.pointerId,args)
    self.slotCancelListenId = TouchManager.Instance:AddListen(TouchDefine.TouchEvent.cancel,self:ToFunc("OnModelDragCancel"),self.pointerId,args)
end

function ViewModelTpose:OnModelDrag(touchData, args)
    -- LogYqh("ViewModelTpose:OnModelDrag",args.pointerId,'/',self.pointerId)
    if args.pointerId == self.pointerId and self.setting.onDrag then
        self.setting.onDrag(touchData,self.setting)
    end
end

function ViewModelTpose:OnModelDragCancel(touchData, args)
    -- LogYqh("ViewModelTpose:OnModelDragCancel",args.pointerId,'/',self.pointerId)
    if args.pointerId == self.pointerId then
        self:RemoveDragListeners()
    end
end

function ViewModelTpose:OnAppFocus(flag)
    if not flag then
        self:RemoveDragListeners()
    end
end