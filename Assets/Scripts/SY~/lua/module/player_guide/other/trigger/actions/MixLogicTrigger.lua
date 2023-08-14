--[[
    逻辑且或触发器，负责创建其他触发器和判断条件是否满足
]]--
MixLogicTrigger = BaseClass("MixLogicTrigger",BaseGuideTrigger)

function MixLogicTrigger:__Init()
    self.triggers = {}
end

function MixLogicTrigger:__Delete()
    for _, triggerList in ipairs(self.triggers or {}) do
        for _, data in ipairs(triggerList) do
            data.trigger:Delete()
        end
    end
    self.triggers = nil
end

function MixLogicTrigger:OnInit()
    local _,condList = next(self.triggerCond)
    if type(condList) == "nil" then
        LogGuide("且或触发器 无条件 直接完成")
        self.guideAction:TriggerFinish()
        return
    end
    -- 兼容填法
    if type(condList) ~= "table" then
        self.triggerCond = {{ self.triggerCond }}
    end
    LogGuide("且或触发器 创建",self.triggerCond)
    self:CreateTriggers()
end

function MixLogicTrigger:CreateTriggers()
    local andList = {}
    for _, condList in ipairs(self.triggerCond) do
        local orList = {}
        for _, cond in ipairs(condList) do
            local condType = cond.type
            if condType then
                local class  = nil
                if PlayerGuideDefine.GuideTriggerIndex[condType] then
                    class = _G[PlayerGuideDefine.GuideTriggerIndex[condType]]
                end
                if not class then
                    LogErrorAny(string.format("未实现的引导触发器[引导Id:%s][触发器类型:%s]",
                        self.guideAction.guideId,tostring(condType)))
                else
                    local guideTrigger = class.New()
                    guideTrigger:SetTriggerCondFunc(self:ToFunc("OnTriggerCond"))
                    guideTrigger:Init(self.guideAction, cond)
                    table.insert(orList, {
                        trigger = guideTrigger,
                        flag = false,
                        param = nil,
                    })
                end
            end
        end
        table.insert(andList, orList)
    end
    self.triggers = andList
end

function MixLogicTrigger:OnTriggerCond(trigger,param)
    LogGuide("且或触发器 条件其一满足 cond:",trigger.triggerCond,'param:',param)
    for _, triggerList in ipairs(self.triggers) do
        local flag = false
        for _, data in ipairs(triggerList) do
            if data.trigger == trigger then
                data.flag = true
                data.param = param
            end
            if data.flag then
                flag = true
                break
            end
        end
        if not flag then
            return
        end
    end
    self:OnTriggerFinish()
end

function MixLogicTrigger:OnTriggerFinish()
    local allArgs = {}
    for _, triggerList in ipairs(self.triggers) do
        for _, data in ipairs(triggerList) do
            for field, value in pairs(data.param or {}) do
                if field ~= "type" then
                    allArgs[field] = value
                end
            end
        end
    end
    LogGuide("且或触发器 条件满足",allArgs)
    self.guideAction:TriggerFinish(allArgs)
end