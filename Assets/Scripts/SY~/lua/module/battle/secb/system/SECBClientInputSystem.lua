SECBClientInputSystem = BaseClass("SECBClientInputSystem",SECBSystem)
--客户端输入系统

--描述：
--1.inputs中保存的是一帧逻辑内渲染帧所输入的信息（比如释放技能、按下按键等）
--2.每一逻辑帧，都会调用GetInputs获取输入的信息
--3.添加输入之前，要想办法自行检测是否是重复的输入信息，以便降低最终的输入信息大小，比如极限情况下，连续两次添加释放技能操作并且释放的技能是一样的

function SECBClientInputSystem:__Init()
    self.inputs = {}
end

function SECBClientInputSystem:__Delete()
end

function SECBClientInputSystem:GetInputs()
    self:OnApplyInput()
    if not next(self.inputs) then
        return nil
    end

    local inputs = self.inputs
    self.inputs = {}
    return inputs
end

function SECBClientInputSystem:AddInput(type,data)
    table.insert(self.inputs,{type = type,data = data})
end

--
function SECBClientInputSystem:OnApplyInput()
end