DevicesManager = SingleClass("DevicesManager")

local isIOS = false
local isAndroid = false
local devicesPerformanLevel = nil

function DevicesManager:__Init()
    if Application.platform == RuntimePlatform.IPhonePlayer then
        isIOS = true
    elseif Application.platform == RuntimePlatform.Android then
        isAndroid = true
    end

    --是否模拟器
    self.isEmulator = BaseApi.IsEmulator()

    --是否有刘海
    self.supportNotch = false

    --刘海的高度 
    self.notchHeight = 0

    --设备信息
    self.devicesInfo = {}
    self.devicesInfo.deviceName = SystemInfo.deviceName
    self.devicesInfo.deviceModel = SystemInfo.deviceModel

    self:InitNotch()
    self:InitPerformanLevel()


    LogInfof("当前设备性能等级[%s]",devicesPerformanLevel)
    LogInfof("刘海信息[是否支持刘海:%s][刘海高度:%s]",tostring(self.supportNotch),tostring(self.notchHeight))
    LogTableInfo("设备信息",self.devicesInfo)
end

function DevicesManager:__Delete()

end

--获取刘海参数
function DevicesManager:InitNotch()
    if isAndroid then
        self.supportNotch = AndroidNotchAgent.supportNotch
        self.notchHeight = AndroidNotchAgent.notchHeight
    elseif isIOS then

    end

    if self.notchHeight > 55 then self.notchHeight = 55 end
end

function DevicesManager:GetNotch()
    return self.notchHeight 
end

function DevicesManager:InitPerformanLevel()
    --默认3，例如win
    devicesPerformanLevel = PerformanceDefine.DeviceLevel.high
    if isAndroid then
        self.devicesInfo.realMemory = BaseApi.GetTotalMemory()
        self.devicesInfo.memory = math.floor(self.devicesInfo.realMemory / 1024 + 0.5) + 1

        --小于4g内存的一律当低端
        --小于6g内存的当中端
        --大于8g的当最高端
        local low = 6
        local mid = 8

        if self.devicesInfo.memory < low then
            devicesPerformanLevel = PerformanceDefine.DeviceLevel.low
        elseif self.devicesInfo.memory <= mid then
            devicesPerformanLevel = PerformanceDefine.DeviceLevel.middle
        else
            devicesPerformanLevel = PerformanceDefine.DeviceLevel.high
        end

        --再在这里确定一次
        local customVal = self:CheckAndroidLevel()
        if customVal then
            devicesPerformanLevel = customVal
        end

        if devicesPerformanLevel >= PerformanceDefine.DeviceLevel.middle then
            --如果是中端，就再分析一次
            self.devicesInfo.analyseLevel = self:Analyse()
            devicesPerformanLevel = self.devicesInfo.analyseLevel
        end
        --模型器其实是高性能的
        if self.isEmulator then
            devicesPerformanLevel = PerformanceDefine.DeviceLevel.high
        end
    elseif isIOS then
        local aryModel = StringUtils.Split(SystemInfo.deviceModel, ",")
        self.devicesInfo.aryModel = aryModel
        
        local version = tonumberEx(string.sub(aryModel[1], 7, -1))
        if version < 8 then
            --iPhone6或以下
            devicesPerformanLevel = PerformanceDefine.DeviceLevel.low
        elseif version >= 8 and version <= 9 then
            --iPhone 6S和iPhone 7
            devicesPerformanLevel = PerformanceDefine.DeviceLevel.middle
        else
            --iPhone8或以上
            devicesPerformanLevel = PerformanceDefine.DeviceLevel.high
        end
        self.devicesInfo.systemVersion = version
    end
end

-- 机型设备性能等级
-- 3高端机  2终端机  1低端机
function DevicesManager:GetDeviceLevel()
    return devicesPerformanLevel
end

function DevicesManager:IsLevel(level)
    return devicesPerformanLevel == level
end

--高于或等于某级别
function DevicesManager:HighThan(level)
    return devicesPerformanLevel >= level
end

--判断安卓手机的等级
function DevicesManager:CheckAndroidLevel()
    local deviceType = BaseApi.GetSystemModel()
    self.devicesInfo.deviceType = deviceType

    deviceType = string.gsub(deviceType, "+", "")
    deviceType = string.lower(deviceType)

    --先直接在表里找
    local finalLevel = AndroidConfig.DeviceType[deviceType]
    if not finalLevel then
        --在表里找不到，有可能有细微的不一样，匹配一下
        for key, level in pairs(AndroidConfig.DeviceType) do
            if string.find(deviceType, key) ~= nil then
                finalLevel = level
                break
            end
        end
    end

    return finalLevel
end


function DevicesManager:Analyse()
    --默认等级都是2 标准画质
    --好一点的机器开到3 最强画质
    --省电模式在设置里自己开
    local level = 2
    if GDefine.isDebug then
        level = 3
    elseif GDefine.platform == GDefine.PlatformType.Android then
        local deviceInfo = self:MatchingDevicePerformanceInfo()
        self.devicesInfo.cpuKHZ = BaseApi.GetCPUMaxFreqKHz()
        self.devicesInfo.devicesScore = deviceInfo and deviceInfo.score or 0
        if self.devicesInfo.cpuKHZ >= 2600 and self.devicesInfo.realMemory >= 6000 and (not deviceInfo or deviceInfo.score >= 105) then
            level = 3
        end
    elseif GDefine.platform == GDefine.PlatformType.IPhonePlayer then
        level = 3
    end
    return level
end

function DevicesManager:MatchingDevicePerformanceInfo()
    local cpuName = BaseApi.GetHardWare()
    local gpuName = SystemInfo.graphicsDeviceName

    self.devicesInfo.cpuName = cpuName
    self.devicesInfo.gpuName = gpuName

    local function matchingInfoByCpuFunc(firm, num)
        for _,info in ipairs(MobileGpuRanking.ranking) do
            if info.cpu == firm then --厂商匹配上了
                --匹配具体型号
                local nums = StringUtils.Split(info.num, "|")
                for _,n in pairs(nums) do
                    if n == num then
                        return info
                    end
                end
            end
        end
    end

    local function matchingInfoByGpuFunc(finalGpuName)
        for _, info in ipairs(MobileGpuRanking.ranking) do
            if info.gpu == finalGpuName or string.find(info.gpu, finalGpuName) then
                return info
            end
        end
    end

    local devicePerformanceInfo
    if cpuName ~= "" and string.find(cpuName, "Kirin") then
        --kirin芯片的gpu信息不够精确所以到cpu表查询
        local num = string.match(cpuName, "Kirin(.+)")
        local firm = "Kirin"
        devicePerformanceInfo = matchingInfoByCpuFunc(firm, num)
    elseif gpuName ~= "" then
        if string.find(gpuName, "Mali") then
            --除了华为的mali芯片，例如天玑 gpu String能完全匹配上 不用改
            devicePerformanceInfo = matchingInfoByGpuFunc(gpuName)
        elseif string.find(gpuName,"Adreno") then
             --骁龙芯片 例如 Adreno (TM) 660 string需要改下,需要去掉中间的 (TM) 再匹配
            if string.len(gpuName) > 12 then
                local num = string.sub(gpuName, 12)
                local finalGpuName = "Adreno" .. num
                devicePerformanceInfo = matchingInfoByGpuFunc(finalGpuName)
            end
        end
    end
    return devicePerformanceInfo
end
