SkinComponent = Class("SkinComponent",ECSLRenderComponent)

function SkinComponent:OnInit()
    self.assetLoader = AssetLoader.New()
end

function SkinComponent:OnDelete()
    self.assetLoader:Delete()
    if self.skin then
        UnityUtil.DestroyGameObject(self.skin)
        self.skin = nil
    end
end

function SkinComponent:OnUpdate()
end

function SkinComponent:OnEnable()
    if self.skin then
        self.skin:SetActive(self.enable)
    end
end

function SkinComponent:SetSkin(skinData)
    --Test
    self.assetLoader:AddAsset(skinData.Asset,CallObject.New(self:ToFunc("OnSkinLoaded")))
    self.assetLoader:LoadAsset()
end

function SkinComponent:OnSkinLoaded(res,path)
    self.skin = UnityUtil.Instantiate(res)
    self.skin.transform:SetParent(self.entity.gameObject.transform)
    self.skin.transform.localPosition = Vector3.zero

    self.meshRenderer = self.skin.gameObject:GetComponent(typeof(UnityEngine.MeshRenderer))
end

return SkinComponent