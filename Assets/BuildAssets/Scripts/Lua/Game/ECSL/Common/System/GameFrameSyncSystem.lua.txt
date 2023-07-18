GameFrameSyncSystem = Class("GameFrameSyncSystem",ECSLSystem)

function GameFrameSyncSystem:OnInit()
    self.frame = 0
end

function GameFrameSyncSystem:OnDelete()
end

function GameFrameSyncSystem:OnUpdate()
    -- TOD 客户端帧与服务端帧不同的时候，此处处理时间膨胀收缩
end

function GameFrameSyncSystem:OnEnable()
end

function GameFrameSyncSystem:SetFrame(frame)
    self.frame = frame
end

return GameFrameSyncSystem