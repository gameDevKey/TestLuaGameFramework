HeroTpose = BaseClass("HeroTpose")
HeroTpose.NOT_CLEAR = true


HeroTpose.RenderMode =
{
    pbr = 1,
    matcap = 2,
}

HeroTpose.mode = HeroTpose.RenderMode.pbr


function HeroTpose:__Init()
    self.callBack = nil
    self.assetLoader = nil
    self.loaded = false
    self.autoReleaser = nil
    self.setting = nil
    self.poolKey = nil
    self.isComplete = false
    self.materials = nil
end

function HeroTpose:__Delete()
    if self.gameObject then
        GameObject.Destroy(self.gameObject)
        self.gameObject = nil
    end

    self:RemoveLoader()
end

function HeroTpose:Load(setting,callBack)
    self.setting = setting
    self.callBack = callBack

    self.modelFile = string.format("unit/%s/%s.prefab",setting.modelId,setting.modelId)
    self.animFile = string.format("unit/%s/%s.controller",setting.modelId,setting.animId)
    self.skinFile = string.format("unit/%s/%s_albedo.tga",setting.modelId,setting.skinId)
    self.maskFile = string.format("unit/%s/%s_mask.tga",setting.modelId,setting.skinId)
    --self.normalFile = string.format("unit/%s/%s_normal.tga",setting.modelId,setting.skinId)

    local assetList = {}
    table.insert(assetList, {file = self.modelFile,type = AssetType.Prefab })
    table.insert(assetList, {file = self.animFile,type = AssetType.Object })
    table.insert(assetList, {file = self.skinFile,type = AssetType.Object }) 
    table.insert(assetList, {file = self.maskFile,type = AssetType.Object }) 
    --table.insert(assetList, {file = self.normalFile,type = AssetType.Object }) 

    self.assetLoader = AssetBatchLoader.New()
    self.assetLoader:Load(assetList,self:ToFunc("OnLoaded"))
end


function HeroTpose:OnLoaded()
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

function HeroTpose:BuildModel()
    self.gameObject = self.assetLoader:GetAsset(self.modelFile)
    self.gameObject:SetActive(true)
    self.transform = self.gameObject.transform
    self.autoReleaser = self.gameObject:GetComponent(AssetReleaser)
    self.renderer = self.gameObject:GetComponentInChildren(Renderer)
    self.mat = self.renderer.material
    self.materials = self.renderer.materials

    self.renderer.receiveShadows = false

    if GDefine.platform == GDefine.PlatformType.WebGLPlayer then
        self.renderer.shadowCastingMode = ShadowCastingMode.Off
    else
        self.renderer.shadowCastingMode = ShadowCastingMode.On
    end

    -- local matcap = PreloadManager.Instance:GetAsset(AssetPath.model_matcap)
    -- self.mat:SetTexture("_MatcapTex",matcap)
    -- self.mat:SetFloat("_OutLineWidth",0.0035)
    -- self.mat:SetColor("_OutLineColor",Color(0,0,0,0x50/0xFF))
    -- self.mat:SetFloat("_AddIns",1.0)
-- self.mat:SetColor("_Color",Color(0,0,0,1))
end

function HeroTpose:BuildSkin()
    self.skinTex = self.assetLoader:GetAsset(self.skinFile)
    AssetLoaderProxy.Instance:AddReference(self.skinFile)
    self.autoReleaser:Add(self.skinFile)

    self.maskTex = self.assetLoader:GetAsset(self.maskFile)
    AssetLoaderProxy.Instance:AddReference(self.maskFile)
    self.autoReleaser:Add(self.maskFile)

    --self.normalTex = self.assetLoader:GetAsset(self.normalFile)
    --AssetLoaderProxy.Instance:AddReference(self.normalFile)
    --self.autoReleaser:Add(self.normalFile)

    self.mat:SetTexture("_BaseMap",self.skinTex)
    self.mat:SetTexture("_MaskMap",self.maskTex)
    --self.mat:SetTexture("_BumpTex",self.normalTex)


    --local unitCubemapTex = PreloadManager.Instance:GetAsset(AssetPath.unit_cubemap)
    --self.mat:SetTexture("_CustomCubemap",unitCubemapTex)
end

function HeroTpose:BuildAnim()
    self.animCtrl = self.assetLoader:GetAsset(self.animFile)
    AssetLoaderProxy.Instance:AddReference(self.animFile)
    self.autoReleaser:Add(self.animFile)
    self.animator = self.gameObject:GetComponent(Animator)
    self.animator.runtimeAnimatorController = self.animCtrl
end

function HeroTpose:TposeComplete()
    if self.callBack then
        self.callBack(self.setting.args)
    end
end

function HeroTpose:IsComplete()
    return self.isComplete
end

function HeroTpose:CancelBuildTpose()
    if not self.isCancel then return false end
    self:RemoveLoader()
    self:Delete()
    return true
end

function HeroTpose:RemoveLoader()
    if self.assetLoader then
        self.assetLoader:Destroy()
        self.assetLoader = nil
    end
end

function HeroTpose:OnReset()
end

function HeroTpose.GetSetting(config,args)
    local setting = {}
    setting.modelId = config.modelId
    setting.skinId = config.skinId
    setting.animId = config.animId
    setting.args = args
    return setting
end