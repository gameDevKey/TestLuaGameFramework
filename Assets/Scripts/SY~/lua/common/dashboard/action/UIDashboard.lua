UIDashboard = BaseClass("UIDashboard")

function UIDashboard:__Init()
    self.showTimes = {}
end

function UIDashboard:__Delete()
    
end

function UIDashboard:AddUIShowTime(viewName,time)
    local lastTime = self.showTimes[viewName] or 0
    if time > lastTime then
        self.showTimes[viewName] = time
    end
end

function UIDashboard:GetUIInfos()
    local infos = {}
    for k,v in pairs(self.showTimes) do
        table.insert(infos,{viewName = k,time = v})
    end
    table.sort(infos,self:ToFunc("UIInfoSort"))
    return infos
end

function UIDashboard:UIInfoSort(a,b)
    return a.time > b.time
end