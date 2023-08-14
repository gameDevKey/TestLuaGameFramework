DebugRangeView = BaseClass("DebugRangeView")

function DebugRangeView:__Init()
    self.showInfo = {
        [BattleDefine.RangeType.circle] = {
            fn = "ShowCircleType",
            path = {file = "mixed/battle/range/circle.prefab", type = AssetType.Prefab}
        }
    }
    self.assetLoader = nil
    self.args = nil
end

function DebugRangeView:__Delete()
    self:ClearAssetLoader()
    if self.rangeView then
        GameObject.Destroy(self.rangeView)
        self.rangeView = nil
    end
end


function DebugRangeView:ShowRange(args,parent)
    self.args = args
    self.parent = parent

    if not self.assetLoader and not self.rangeView then
        local assetList = {}
        table.insert(assetList,self.showInfo[self.args.type].path)
        self.assetLoader = AssetBatchLoader.New()
        self.assetLoader:Load(assetList,self:ToFunc("OnLoaded"))
    end

    if self.rangeView then
        self.rangeView:SetActive(true)
    end
end

function DebugRangeView:OnLoaded()
    self.rangeView = self.assetLoader:GetAsset(self.showInfo[self.args.type].path.file,self.parent)
    self.rangeView.transform:SetLocalPosition(0,0.1,0)
    if not self.rangeView then
        LogError("加载出错 self.rangeView为空")
    else
        local showInfo = self.showInfo[self.args.type]
        if not showInfo then
            LogError("未知的Debug范围类型[%s]",tostring(self.args.type))
        else
            self[showInfo.fn](self)
        end
    end
    self:ClearAssetLoader()
end

function DebugRangeView:ShowCircleType()
    local radius = self.args.radius
        if radius then
            local scale = radius * 2 * 0.001
            UnityUtils.SetLocalScale(self.rangeView.transform,scale,scale,scale)
            UnityUtils.SetLocalPosition(self.rangeView.transform,0,0.1,0)
        else
            LogError("类型为圆形但参数没有半径")
        end
end

function DebugRangeView:HideRange()
    if self.rangeView then
        self.rangeView:SetActive(false)
    end
end

function DebugRangeView:ClearAssetLoader()
    if self.assetLoader then
        self.assetLoader:Destroy()
        self.assetLoader = nil
    end
end