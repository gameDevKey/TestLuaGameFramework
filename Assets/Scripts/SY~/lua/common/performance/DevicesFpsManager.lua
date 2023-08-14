DevicesFpsManager = SingleClass("DevicesFpsManager")

local _Application = Application

function DevicesFpsManager:__Init()
    self.targetFps = 60


    self.curFps = 0
    self.frameStamp = Time.frameCount
    self.timeStamp = Time.unscaledDeltaTime
end

function DevicesFpsManager:__Delete()
end

function DevicesFpsManager:SetTargetFps(targetFps)
    self.targetFps = targetFps
end

function DevicesFpsManager:Update()
    if Time.realtimeSinceStartup - self.timeStamp >= 1 then
        self.curFps = Mathf.Min(Time.frameCount - self.frameStamp,self.targetFps)
        self.timeStamp = Time.realtimeSinceStartup
        self.frameStamp = Time.frameCount
    end
end