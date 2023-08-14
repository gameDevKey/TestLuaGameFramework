GmProxy = BaseClass("GmProxy",Proxy)

function GmProxy:__Init()
    self.gmView = nil
    self.worlds = {}

    self.confGmData = {}
    self.serverGmData = {}
end

function GmProxy:__Delete()
    if self.gmView then
        self.gmView:Destroy()
        self.gmView = nil
    end
end

function GmProxy:__InitProxy()
    self:BindMsg(10106)
    self:BindMsg(10105)
end

function GmProxy:__InitComplete()
    for k, v in pairs(Config.GmData.data_gm_info) do
        if not self.confGmData[v.type] then
            self.confGmData[v.type] = {}
        end
        table.insert(self.confGmData[v.type],v)
    end

    LogTable("配置gm数据",self.confGmData)
end

function GmProxy:Send_10106(gmContent)
    local data = {}
    data.cmd = gmContent
    LogTable("发送10106",data)
    return data
end

function GmProxy:Recv_10105(data)
    LogTable("接收10105",data)
    self.serverGmOrder = {}
    local order = 0
    for k, v in ipairs(data.gm_list) do
        if not self.serverGmData[v.type] then
            self.serverGmData[v.type] = {}
            self.serverGmOrder[v.type] = order
            order = order + 1
        end
        for _,cmdInfo in pairs(v.gm_cmd) do
            local cmdSceInfo = {}
            cmdSceInfo.notes = cmdInfo
            cmdSceInfo.content = _
            table.insert(self.serverGmData[v.type],cmdSceInfo)
        end
    end
    LogTable("服务器gm数据",self.serverGmData)
end