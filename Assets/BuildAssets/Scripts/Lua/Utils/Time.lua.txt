Time = StaticClass("Time")

---根据时间戳计算是星期几
---@param timeStamp int|nil 时间戳，默认是当前时间
---@return int dayOfWeek 星期几，[0 - 6 = 星期天 - 星期六]
function Time.GetDayOfWeek(timeStamp)
    timeStamp = timeStamp or os.time()
    return os.date("%w",timeStamp)
end

---根据时间戳返回数据表
---@param timeStamp int|nil 时间戳，默认是当前时间
---@return table data 返回一个包含year(4位)，month(1-12)，day (1--31)，hour (0-23)， min (0-59)，sec (0-61)，wday (星期几，星期天为1)， yday (年内天数)和isdst (是否为日光节约时间true/false)的带键名的表
function Time.GetTimeDetailInfo(timeStamp)
    timeStamp = timeStamp or os.time()
    return os.date("*t",timeStamp)
end

return Time