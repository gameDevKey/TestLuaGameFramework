MaskGuideView = BaseClass("MaskGuideView",BaseView)
MaskGuideView.Event = EventEnum.New(

)

function MaskGuideView:__Init()
    self:SetAsset("ui/prefab/bubbleguide/maskguide.prefab",AssetType.Prefab)
end

function MaskGuideView:__CacheObject()
    self.mask = self:Find("mask",Image)
end

function MaskGuideView:__Show()
    self.mat = self.mask.gameObject:GetComponent(Image).material
    self.mat:SetFloat("_Radius",100)
    self.mat:SetVector("_Center",Vector4(self.args.pro.x,self.args.pro.y,1,1))
end