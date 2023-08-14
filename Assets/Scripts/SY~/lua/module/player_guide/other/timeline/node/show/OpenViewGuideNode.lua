OpenViewGuideNode = BaseClass("OpenViewGuideNode",BaseGuideNode)

function OpenViewGuideNode:__Init()

end

function OpenViewGuideNode:OnStart()
    local name = self.actionParam.name
    if name == "open_func" then
        local id = self.actionParam.id
        local showList = {}
        local conf = Config.FuncOpenData.data_func_open_info[id]
        if conf then
            table.insert(showList,{funcName = conf.name, funcIcon = conf.icon, content = conf.desc})
        else
            LogErrorAny("无法打开功能解锁窗口:",id)
        end
        ViewManager.Instance:OpenWindow(OpenFuncWindow,{showList = showList})
    end
end

function OpenViewGuideNode:OnDestroy()

end