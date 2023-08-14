
TimeUtils = TimeUtils or {}

--[[
功能：生成时间格式为00:00:00的(时：分：秒)
--]]
function TimeUtils.GetTimeFormat(less_time)
    less_time = tonumber(less_time) or 0
    local hour = math.floor(less_time / 3600)
    hour = (hour < 10) and "0"..hour or hour
    local min = math.floor((less_time % 3600) / 60)
    min = (min < 10) and "0"..min or min
    local sec = less_time % 3600 % 60
    sec = (sec < 10) and "0"..sec or sec
    return hour .. ":" .. min .. ":" .. sec
end

--[[
功能：生成时间格式为00:00的(时：分：秒)
--]]
function TimeUtils.GetMinSecTime(less_time)
    less_time = tonumber(less_time) or 0
    local hour = math.floor(less_time / 3600)
    hour = (hour < 10) and "0"..hour or hour
    local min = math.floor((less_time % 3600) / 60)
    min = (min < 10) and "0"..min or min
    local sec = less_time % 3600 % 60
    sec = (sec < 10) and "0"..sec or sec
    return  min .. ":" .. sec
end

--[[
功能：生成时间格式为00:00的(时：分：秒)
--]]
function TimeUtils.GetMinSecTimeByChinese(less_time)
    less_time = tonumber(less_time) or 0
    local hour = math.floor(less_time / 3600)
    hour = (hour < 10) and "0"..hour or hour
    local min = math.floor((less_time % 3600) / 60)
    min = (min < 10) and "0"..min or min
    local sec = less_time % 3600 % 60
    sec = (sec < 10) and "0"..sec or sec
    return  min .. "分" .. sec .. "秒"
end

-- 生成分秒，偶数的时候没有冒号，有种闪烁效果
function TimeUtils.GetMinSecTime2(less_time)
    less_time = tonumber(less_time) or 0
    local hour = math.floor(less_time / 3600)
    hour = (hour < 10) and "0"..hour or hour
    local min = math.floor((less_time % 3600) / 60)
    min = (min < 10) and "0"..min or min
    local sec = less_time % 3600 % 60
    sec = (sec < 10) and "0"..sec or sec
    if sec % 2 == 0 then 
        return  min .. ":" .. sec
    else
        return min .. " " .. sec
    end
end

--[[
功能：生成时间格式为00:00:00的(时：分：秒)
--]]
function TimeUtils.GetTimeFormatII(less_time)
    less_time = tonumber(less_time) or 0
    local hour = math.floor(less_time / 3600)
    -- hour = (hour < 10) and "0"..hour or hour
    local min = math.floor((less_time % 3600) / 60)
    -- min = (min < 10) and "0"..min or min
    local sec = math.floor(less_time % 3600 % 60)
    -- sec = (sec < 10) and "0"..sec or sec

    if sec <= 0 then
        if min <= 0 then
            return hour .. "小时"
        else
            return hour .. string.format("小时%s分", min)
        end
    end
    return hour .. string.format("小时%s分%s秒", min, sec)
end


--[[
功能：生成时间格式为00:00:00的(时：分)
--]]
function TimeUtils.GetTimeFormatTwo(less_time, is_num)
    less_time = tonumber(less_time) or 0
    local hour = math.floor(less_time / 3600)
    local str_hour = (hour < 10) and "0"..hour or hour
    local min = math.floor((less_time % 3600) / 60)
    local str_min = (min < 10) and "0"..min or min
    local sec = math.floor(less_time % 3600 % 60)
    local str_sec = (sec < 10) and "0"..sec or sec

    if hour <= 0 then
        if is_num then
            return string.format("%s:%s", str_min, str_sec)
        end
        return string.format("%s分%s秒", str_min, str_sec)
    else
        if is_num then
            return string.format("%s:%s", str_hour, str_min)
        end
        return string.format("%s小时%s分", str_hour, str_min)
    end
end


--[[
功能：生成时间格式为00:00:00的(时：分：秒)
--]]
function TimeUtils.GetTimeFormatIII(less_time)
    less_time = tonumber(less_time) or 0
    local hour = math.floor(less_time / 3600)
    hour = (hour < 10) and "0"..hour or hour
    local min = math.floor((less_time % 3600) / 60)
    min = (min < 10) and "0"..min or min
    -- local sec = less_time % 3600 % 60
    -- sec = (sec < 10) and "0"..sec or sec
    return hour .. ":" .. min
end

--[[
功能：生成时间格式为00:00的(分：秒)
--]]
function TimeUtils.GetTimeMS(less_time,isNum)
    less_time = tonumber(less_time) or 0
    local hour = math.floor(less_time / 3600)
    local min = math.floor((less_time % 3600) / 60)
    local sec = math.floor(less_time % 3600 % 60)
    if isNum then
        sec = (sec < 10) and "0"..sec or sec
        local max_m = hour*60+min
        max_m = (max_m < 10) and "0".. max_m or max_m
        return  max_m .. ":" .. sec
    else
        return string.format("%s分%s秒", hour*60+min, sec)
    end
end

--[[
功能：传入时间戳，生成时间格式为(年-月-日 时：分：秒)
--]]
function TimeUtils.getYMDHMS(less_time)
   return os.date("%Y-%m-%d %X ", less_time)
end
-- 功能：传入时间戳，生成时间格式为(月-日)
function TimeUtils.getMDHMS(less_time)
   return os.date("%m-%d %X ", less_time)
end

function TimeUtils.getMD(less_time, split)
    local _split = split or "."
    local format = "%m" .. _split .. "%d"
   return os.date(format, less_time)
end

function TimeUtils.getMDHM(less_time)
   return os.date("%m-%d %H:%M", less_time)
end

function TimeUtils.getHMS(less_time)
    return os.date("%X ", less_time)
end

function TimeUtils.getYDHM(less_time)
   return os.date("%m/%d %H:%M ", less_time)
end

function TimeUtils.getMS(less_time)
    return os.date("%M:%S", less_time)
end
function TimeUtils.getHM(less_time)
    return os.date("%H:%M", less_time)
end
--年/月/日/时/分
function TimeUtils.getYMDHM(less_time)
   return os.date("%Y/%m/%d  %H:%M", less_time)
end

--[[
功能：传入时间戳，生成时间格式为(年-月-日)
--]]
function TimeUtils.getYMD(less_time)
   return os.date("%Y-%m-%d", less_time)
end


-- 获取距离第二天凌晨0点所剩下的时间
function TimeUtils.getOneDayLessTime()
    local year = tonumber(os.date("%Y"))
    local mon= tonumber(os.date("%m"))
    local day= tonumber(os.date("%d"))+1
    local last = os.time({year=year, month=mon, day=day, hour=0, min=0, sec=0, isdst=false})
    local less = os.difftime(last, os.time())
    return less
end

-- 获取距离目标时间的剩余时间
function TimeUtils.getTargetTimeLessTime(dayVariate, hour, min, sec)
    local dayVariate = dayVariate or 0
    local year = tonumber(os.date("%Y"))
    local mon = tonumber(os.date("%m"))
    local day = tonumber(os.date("%d")) + dayVariate
    local hour = hour or 0
    local min = min or 0
    local sec = sec or 0
    local last = os.time({year = year, month = mon, day = day, hour = hour, min = 0, sec = 0, isdst = false})
    local less = os.difftime(last, os.time())
    return less
end

function TimeUtils.day2s()
    return 86400
end

function TimeUtils.getDayDifference(time_tmps)
    if type(time_tmps) ~= "number" then return 0 end
    local time = os.time()
    return (time - time_tmps) / TimeUtils.day2s()
end

-- xx天xx小时xx分xx秒
function TimeUtils.GetTimeFormatDay(less_time)
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time/TimeUtils.day2s())
    local lessT = math.floor(less_time%TimeUtils.day2s())
    local hour = math.floor(lessT / 3600)
    local min = math.floor((lessT % 3600) / 60)
    local sec = math.floor(lessT % 3600 % 60)
    local dayStr = ""
    if day >= 1 then
        dayStr = day.."天"
    end
    if day >= 1 then
        if hour > 0 then
            return dayStr..hour .. "小时"
        else
            return dayStr
        end 
    else
        if sec <= 0 then
            if min <= 0 then
                if hour <=0 then
                    return ""
                end
                return dayStr..hour .. "小时"
            else
                return dayStr..hour .. string.format("小时%s分", min)
            end
        end
        return dayStr..hour .. string.format("小时%s分", min)
    end
end

-- 大于1天显示xx天 小于一天显示xx小时xx分xx秒
function TimeUtils.GetTimeDayOrTime(less_time)
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time/TimeUtils.day2s())
    local lessT = math.floor(less_time%TimeUtils.day2s())
    local hour = math.floor(lessT / 3600)
    local min = math.floor((lessT % 3600) / 60)
    local sec = math.floor(lessT % 3600 % 60)
    local dayStr = ""
    if day >= 1 then
        dayStr = day.."天"
        return dayStr
    end
    if day < 1 then
        return os.date("%X ", less_time)
    end
end

-- 显示两单位计时
function TimeUtils.GetTimeFormatDayII(less_time)
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time/86400)
    local lessT = math.floor(less_time%86400)
    local hour = math.floor(lessT / 3600)
    local min = math.floor((lessT % 3600) / 60)
    local sec = math.floor(lessT % 3600 % 60)
    local dayStr = ""
    local hourStr = ""
    local minStr = ""
    local secStr = ""
    if sec >= 1 then
        secStr = sec.."秒"
    end
    if min >= 1 then
        minStr = min.."分"
    end
    if hour >= 1 then
        hourStr = hour.."小时"
    end
    if day >= 1 then
        dayStr = day.."天"
        return dayStr..hourStr
    else
        if hour >= 1 then
            return hourStr..minStr
        else
            return minStr..secStr
        end
    end
    -- return hourStr..minStr..secStr
end
-- 显示两单位计时
function TimeUtils.GetTimeFormatDayIII(less_time)
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time/86400)
    local lessT = math.floor(less_time%86400)
    local hour = math.floor(lessT / 3600)
    local min = math.floor((lessT % 3600) / 60)
    local sec = math.floor(lessT % 3600 % 60)
    local dayStr = ""
    local hourStr = ""
    local minStr = ""
    local secStr = ""
    if day >= 1 then
        if hour >= 1 then
            hourStr = hour.."小时"
        end
        dayStr = day.."天"
        return dayStr..hourStr
    else
        hourStr = hour.."小时"
        minStr = min.."分"
        secStr = sec.."秒"
        return hourStr..minStr..secStr
    end
end

--当大于1天时，显示x天，小于一天时，显示x时x分
function TimeUtils.GetTimeFormatDayIV(less_time)
    less_time = tonumber(less_time) or 0
	local day = math.floor(less_time/86400)
	local time_str = ""
	if day >= 1 then
		time_str = day .. "天"
	else
		local lessT = math.floor(less_time%86400)
		local hour = math.floor(lessT / 3600)
        local min = math.floor((lessT % 3600) / 60)
        local sec = math.floor(lessT % 3600 % 60)
		if hour < 10 then hour = "0" .. hour end
		if min < 10 then min = "0" .. min end
        if sec < 10 then sec = "0" .. sec end
		time_str = string.format("%s:%s:%s", hour, min,sec)
	end
	return time_str
end



-- 获得天，小时，分，秒
function TimeUtils.GetTimeName(less_time)
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time/TimeUtils.day2s())
    local lessT = math.floor(less_time%TimeUtils.day2s())
    local hour = math.floor(lessT / 3600)
    local min = math.floor((lessT % 3600) / 60)
    local sec = math.floor(lessT % 3600 % 60)
    
    return day, hour, min, sec
end

--大于1天显示x天x小时，少于一天显示x小时xfen
function TimeUtils.GetTimeFormatDayIIIIII(less_time)
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time/TimeUtils.day2s())
    local lessT = math.floor(less_time%TimeUtils.day2s())
    local hour = math.floor(lessT / 3600)
    local min = math.floor((lessT % 3600) / 60)
    local sec = math.floor(lessT % 3600 % 60)
    local dayStr = ""
    if day >= 1 then
        dayStr = day.."天"
    end
    if day >= 1 then
        return dayStr..hour.. "小时"
    else
        if sec <= 0 then
            if min <= 0 then
                if hour <=0 then
                    return ""
                end
                return dayStr..hour .. "小时"
            else
                return dayStr..hour .. string.format("小时%s分", min)
            end
        end
        return dayStr..hour .. string.format("小时%s分", min)
    end
end

--当大于1天时显示x天,小于一天时显示x小时,小于1小时显示x分钟,小于1分钟显示x秒
function TimeUtils.GetTimeFormatDayVII(less_time)
    less_time = tonumber(less_time) or 0
    local day = math.floor(less_time / 86400)
    local time_str = ""
    local timeData = {}
    if day >= 1 then
        time_str = day .. "天"
        timeData.num = day
        timeData.type = "day"
    else
        local lessT = math.floor(less_time % 86400)
        local hour = math.floor(lessT / 3600)
        if hour >= 1 then
            time_str = string.format("%s小时", hour)
            timeData.num = hour
            timeData.type = "hour"
        else
            lessT = math.floor(less_time % 3600)
            local min = math.floor(lessT / 60)
            if min >= 1 then
                time_str = string.format("%s分钟", min)
                timeData.num = min
                timeData.type = "min"
            else
                time_str = string.format("%s秒", lessT)
                timeData.num = lessT
                timeData.type = "sec"
            end
        end
    end
    return time_str,timeData
end
