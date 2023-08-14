HighlightGuideNode = BaseClass("HighlightGuideNode",BaseGuideNode)

function HighlightGuideNode:__Init()
    self.objs = {}
    self.maskIndex = mod.PlayerGuideProxy:GetMaskIndex()
    self.isFind = false
end

function HighlightGuideNode:OnStart()
    self.isFind = false
end

function HighlightGuideNode:FindTarget()
    local tag = self.actionParam.tag
    local id = self.actionParam.id
    local lastCount = self.actionParam.lastCount
    local args = self.actionParam
    local objs
    if tag then
        local data = PlayerGuideUtils.GetSceneUI(tag,args)
        if data and data.rootObj then
            objs = {data.rootObj}
        end
    elseif id then
        objs = PlayerGuideUtils.GetSceneObject("hero",args)
        if lastCount and lastCount > 0 then
            local tempObjs = {}
            local len = #objs
            local index = MathUtils.Clamp(len - lastCount + 1, 1, len)
            for i = index, len do
                table.insert(tempObjs, objs[i])
            end
            objs = tempObjs
        end
    end
    if objs and #objs > 0 then
        self:OnFindTargetFinish(objs)
    end
end

function HighlightGuideNode:OnFindTargetFinish(objs)
    self.isFind = true
    for _, _obj in ipairs(objs) do
        self:Highlight(_obj)
    end
    mod.PlayerGuideProxy:SetMaskActive(true,self.maskIndex)
end

function HighlightGuideNode:OnUpdate()
    if self.isFind then
        return
    end
    self:FindTarget()
end

function HighlightGuideNode:OnDestroy()
    self.isFind = false
    self:CancelHighlight()
    mod.PlayerGuideProxy:SetMaskActive(false,self.maskIndex)
end

function HighlightGuideNode:Highlight(obj)
    if not obj then return end
    BaseUtils.RangeObj(obj, function (child)
        self.objs[child] = child.layer
        BaseUtils.ChangeLayers(child, GDefine.Layer.layer10, true)
    end)
end

function HighlightGuideNode:CancelHighlight()
    for obj, layer in pairs(self.objs) do
        BaseUtils.ChangeLayers(obj, layer, true)
    end
    self.objs = {}
end