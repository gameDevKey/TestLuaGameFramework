HomeTpose = BaseClass("HomeTpose")
HomeTpose.NOT_CLEAR = true

function HomeTpose:__Init()
    self.callBack = nil
    self.assetLoader = nil
    self.loaded = false
    self.autoReleaser = nil
    self.setting = nil
    self.isComplete = false
end

function HomeTpose:__Delete()
    if self.gameObject then
        GameObject.Destroy(self.gameObject)
        self.gameObject = nil
    end
end

function HomeTpose:Load(setting,callBack)
    self.setting = setting
    self.callBack = callBack

    self.modelPath = string.format("unit/%s/%s.prefab",setting.modelId,setting.modelId)
    self.skinPath = string.format("unit/%s/%s.tga",setting.modelId,setting.skinId)
    if setting.animId ~= 0 then
        self.animPath = string.format("unit/%s/%s.controller",setting.modelId,setting.animId)
    end
    
    local assetList = {}
    table.insert(assetList, {file = self.modelPath,type = AssetType.Prefab })
    table.insert(assetList, {file = self.skinPath,type = AssetType.Object })
    if setting.animId ~= 0 then
        table.insert(assetList, {file = self.animPath,type = AssetType.Object})
    end

    self.assetLoader = AssetBatchLoader.New()
    self.assetLoader:Load(assetList,self:ToFunc("OnLoaded"))
end


function HomeTpose:OnLoaded()
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

function HomeTpose:BuildModel()
    self.gameObject = self.assetLoader:GetAsset(self.modelPath)
    self.gameObject:SetActive(true)
    self.transform = self.gameObject.transform
    self.autoReleaser = self.gameObject:GetComponent(AssetReleaser)
    self.renderer = self.gameObject:GetComponentInChildren(Renderer)
    self.mat = self.renderer.material
end

function HomeTpose:BuildSkin()
    self.skinTex = self.assetLoader:GetAsset(self.skinPath)
    AssetLoaderProxy.Instance:AddReference(self.skinPath)
    self.autoReleaser:Add(self.skinPath)
    self.mat.mainTexture = self.skinTex
end

function HomeTpose:BuildAnim()
    if not self.animPath then
        return
    end

    self.animCtrl = self.assetLoader:GetAsset(self.animPath)
    AssetLoaderProxy.Instance:AddReference(self.animPath)
    self.autoReleaser:Add(self.animPath)
    self.animator = self.gameObject:GetComponent(Animator)
    self.animator.runtimeAnimatorController = self.animCtrl
end

function HomeTpose:TposeComplete()
    if self.callBack then
        self.callBack(self.setting.args)
    end
end

function HomeTpose:IsComplete()
    return self.isComplete
end

function HomeTpose:CancelBuildTpose()
    if not self.isCancel then return false end
    self:RemoveLoader()
    self:Delete()
    return true
end

function HomeTpose:RemoveLoader()
    if self.assetLoader then
        self.assetLoader:Destroy()
        self.assetLoader = nil
    end
end

function HomeTpose.GetSetting(config,args)
    local setting = {}
    setting.modelId = config.modelId
    setting.skinId = config.skinId
    setting.animId = config.animId
    setting.args = args
    return setting
end