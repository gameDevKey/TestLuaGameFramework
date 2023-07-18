GameInputSystem = Class("GameInputSystem", ECSLSystem)

function GameInputSystem:OnInit()
    self.inputs = {} --TODO 改成链表比较好
end

function GameInputSystem:OnDelete()
end

function GameInputSystem:OnUpdate()
    --Test
    local h = CS.UnityEngine.Input.GetAxisRaw("Horizontal")
    local v = CS.UnityEngine.Input.GetAxisRaw("Vertical")
    if h ~= 0 or v ~= 0 then
        self.world.GameEventSystem:Broadcast(EventConfig.Type.MoveInput, h, v)
    end
end

function GameInputSystem:OnEnable()
end

function GameInputSystem:AddInput(type, data)
    --收集当前帧输入
    local frame = self.world.GameFrameSyncSystem.frame
    if not self.inputs[frame] then
        self.inputs[frame] = {}
    end
    table.insert(self.inputs[frame], {
        frame = frame,
        type = type,
        data = data,
    })
end

function GameInputSystem:ApplyInput()
    --TODO 获取一帧内所有的输入，并且应用出去
end

return GameInputSystem
