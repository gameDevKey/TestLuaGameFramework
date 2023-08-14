MainuiProxy = BaseClass("MainuiProxy",Proxy)

function MainuiProxy:__Init()
    self.mainuiPanel = nil
    --self.lastLayout = nil
    --self.curLayout = MainDefine.Layout.default
end

function MainuiProxy:__Delete()
    if self.mainuiPanel then
        self.mainuiPanel:Destroy()
        self.mainuiPanel = nil
    end

    --self.lastLayout = nil
    --self.curLayout = MainDefine.Layout.default
end


function MainuiProxy:__InitProxy()
    self:BindMsg(10421) -- 创建房间
    self:BindMsg(10422) -- 加入房间
    self:BindMsg(10423) -- 取消已创建好的房间
end

function MainuiProxy:__InitComplete()
end

-- function MainuiProxy:SetLayout(layout)
--     self.lastLayout = self.curLayout
--     self.curLayout = layout
--     mod.MainFacade:SendEvent(MainPanel.Event.RefreshLayout)
-- end

-- function MainuiProxy:RecoverLayout()
--     self:SetLayout(self.lastLayout)
-- end

function MainuiProxy:Send_10421()
    return nil
end

function MainuiProxy:Recv_10421(data)
    LogTable("接收10421",data)
    mod.MainuiFacade:SendEvent(RoomModePanel.Event.CreateRoomSuccess,data)
end

function MainuiProxy:Send_10422(id)
    local data = {}
    data.room_id = id
    LogTable("发送10422",data)
    return data
end

function MainuiProxy:Recv_10422(data)
    LogTable("接收10422",data)
    mod.MainuiFacade:SendEvent(RoomModePanel.Event.EnterRoomSuccess,data)
end

function MainuiProxy:Send_10423(id)
    return nil
end