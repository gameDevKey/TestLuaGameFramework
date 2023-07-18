RangeComponent = Class("RangeComponent",ECSLRenderComponent)

function RangeComponent:OnInit()
    self.assetLoader = AssetLoader.New()
end

function RangeComponent:OnDelete()
    self.assetLoader:Delete()
    if self.rangeRes then
        UnityUtil.DestroyGameObject(self.rangeRes)
        self.rangeRes = nil
    end
end

function RangeComponent:OnUpdate()
end

function RangeComponent:OnEnable()
    if self.rangeRes then
        self.rangeRes:SetActive(self.enable)
    end
end

function RangeComponent:SetRange(range)
    self.range = range
    if self.rangeRes then
        self:AfterResLoad()
    else
        self:LoadRes()
    end
end

function RangeComponent:LoadRes()
    local res = RangeConfig.Type2Res[self.range.type]
    self.assetLoader:AddAsset(res,CallObject.New(self:ToFunc("OnResLoaded")))
    self.assetLoader:LoadAsset()
end

function RangeComponent:OnResLoaded(res,path)
    self.rangeRes = UnityUtil.Instantiate(res)
    self.rangeRes.transform:SetParent(self.entity.gameObject.transform)
    self.rangeRes.transform.localPosition = Vector3.zero

    self:AfterResLoad()
end

function RangeComponent:AfterResLoad()
    if self.range.type == RangeConfig.Type.Circle then
        --内切圆 x^2 + y^2 = r^2 因为正方形 x=y 所以 x = 根号(r^2 / 2)
        --总宽度 w = 2 * x
        local r = self.range.radius
        local x = math.sqrt(r * r / 2)
        local w = x * 2
        self.rangeRes.transform.localScale = Vector3(w,w,1)
    end
end

return RangeComponent