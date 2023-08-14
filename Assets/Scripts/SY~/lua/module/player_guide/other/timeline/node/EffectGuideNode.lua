EffectGuideNode = BaseClass("EffectGuideNode",BaseViewGuideNode)

function EffectGuideNode:__Init()
    self.guidePrefabPath = nil
    self.position = {}
end

function EffectGuideNode:OnStar()
    self:Show()
end

function EffectGuideNode:OnInit()
    self.position = self.args.position
end

function EffectGuideNode:__Show()
    self.maskPrefab = self:SetAsset(self.guidePrefabPath,AssetType.Prefab)
    UnityUtils.SetLocalPosition(self.maskPrefab,self.position.x,self.position.y,self.position.z)
end

