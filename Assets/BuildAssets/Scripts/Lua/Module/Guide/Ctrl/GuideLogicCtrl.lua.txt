--处理一些纯业务逻辑（不涉及界面的逻辑）
GuideLogicCtrl = SingletonClass("GuideLogicCtrl", CtrlBase)

function GuideLogicCtrl:OnInit()
    self.guideUnits = ListMap.New()
end

function GuideLogicCtrl:OnInitComplete()
    self:AddGolbalListenerWithSelfFunc(EGlobalEvent.Lanuch, "TryStartGuide", false)
end

function GuideLogicCtrl:TryStartGuide()
    if not GuideProxy.Instance:NeedGuide() then
        return
    end
    local guideId = GuideProxy.Instance:GetBeginGuideId()
    --从当前引导所属的组的首个引导开始

    --TODO debug
    self:ActiveUpdate(true)
    self:NextGuide(guideId)
end

function GuideLogicCtrl:NextGuide(guideId)
    local data = require("Data.Guide." .. guideId) --TODO 从缓存中读取
    if not data then
        PrintError("找不到引导数据", guideId)
        return
    end
    PrintGuide("执行引导", guideId)
    self.guideUnits:Add(guideId, GuideUnit.New(data, self:ToFunc("FinishGuideUnit")))
end

function GuideLogicCtrl:FinishGuideUnit(unit)
    PrintGuide("引导完成", unit.data.Id)
    self.guideUnits:Remove(unit.data.Id)
    unit:Delete()
    if unit.data.NextId then
        self:NextGuide(unit.data.NextId)
    end
    if self.guideUnits:Size() == 0 then
        self:FinishAll()
    end
end

function GuideLogicCtrl:FinishAll()
    PrintGuide("所有引导完成")
    self:ActiveUpdate(false)
end

function GuideLogicCtrl:OnUpdate(deltaTime)
    self.deltaTime = deltaTime
    self.guideUnits:Range(self.UpdateUnit, self)
end

function GuideLogicCtrl:UpdateUnit(iter)
    iter.value:Update(self.deltaTime)
end

return GuideLogicCtrl
