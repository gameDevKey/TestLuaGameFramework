RoomModePanel = BaseClass("RoomModePanel",ExtendView)

RoomModePanel.Event = EventEnum.New(
    "CreateRoomSuccess",
    "EnterRoomSuccess"
)

function RoomModePanel:__Init()
    self.roomId = 0
end

function RoomModePanel:__CacheObject()
    self.trans = self:Find("room_mode")
    self.roomModePanel = self:Find("room_mode_panel",nil,self.trans)
    self.createRoomPanel = self:Find("create_room_panel",nil,self.trans)
    self.enterRoomPanel = self:Find("enter_room_panel",nil,self.trans)

    self.roomIdText = self:Find("bg/room_id",Text,self.createRoomPanel)

    self.enterNumInputField = self:Find("bg/input_bg/input_field",InputField,self.enterRoomPanel)
end

function RoomModePanel:__Create()
    self:Find("bg/title",Text,self.roomModePanel).text = TI18N("好友对战")
    self:Find("bg/tips",Text,self.roomModePanel).text = TI18N("创建房间与伙伴一起进行对战切磋！\n\n切磋结果不影响当前奖杯数！")
    self:Find("bg/btn_left/text",Text,self.roomModePanel).text = TI18N("创建房间")
    self:Find("bg/btn_right/text",Text,self.roomModePanel).text = TI18N("加入房间")
    self:Find("bg/tips",Text,self.createRoomPanel).text = TI18N("你的好友可以输入以下房间号加入游戏")
    self:Find("bg/btn/text",Text,self.createRoomPanel).text = TI18N("返回")
    self:Find("bg/title",Text,self.enterRoomPanel).text = TI18N("加入房间")
    self:Find("bg/tips",Text,self.enterRoomPanel).text = TI18N("输入好友的房间号即可加入游戏！")
    self:Find("bg/btn/text",Text,self.enterRoomPanel).text = TI18N("加入房间")
end

function RoomModePanel:__BindEvent()
    self:BindEvent(RoomModePanel.Event.CreateRoomSuccess)
    self:BindEvent(RoomModePanel.Event.EnterRoomSuccess)
end

function RoomModePanel:__BindListener()
    self:Find("panel_btn",Button,self.roomModePanel):SetClick(self:ToFunc("CloseRoomMode"))
    self:Find("bg/btn_left",Button,self.roomModePanel):SetClick(self:ToFunc("ShowCreateRoomPanel"))
    self:Find("bg/btn_right",Button,self.roomModePanel):SetClick(self:ToFunc("ShowEnterRoomPanel"))

    -- self:Find("panel_btn",Button,self.createRoomPanel):SetClick(self:ToFunc("CloseCreateRoomPanel"))
    self:Find("bg/btn",Button,self.createRoomPanel):SetClick(self:ToFunc("CloseCreateRoomPanel"))

    self:Find("panel_btn",Button,self.enterRoomPanel):SetClick(self:ToFunc("CloseEnterRoomPanel"))
    self:Find("bg/btn",Button,self.enterRoomPanel):SetClick(self:ToFunc("EnterRoom"))
end

function RoomModePanel:OnActive()
    self.trans.gameObject:SetActive(true)
end

function RoomModePanel:CloseRoomMode()
    self:CloseCreateRoomPanel()
    self:CloseEnterRoomPanel()
    self.trans.gameObject:SetActive(false)
    self.roomId = 0
    self.enterNumInputField.text = ""
end

function RoomModePanel:ShowCreateRoomPanel()
    -- self.roomIdText.text = TI18N("点击下方按钮创建房间")
    mod.MainuiFacade:SendMsg(10421,nil)
    self.createRoomPanel.gameObject:SetActive(true)
end

function RoomModePanel:ShowEnterRoomPanel()
    self.enterRoomPanel.gameObject:SetActive(true)
end

function RoomModePanel:CloseCreateRoomPanel()
    if self.roomId ~= 0 then
        mod.MainuiFacade:SendMsg(10423,nil)
    end
    self.createRoomPanel.gameObject:SetActive(false)
    self.roomId = 0
end

-- function RoomModePanel:CreateRoom()
--     mod.MainuiFacade:SendMsg(10421,nil)
-- end

function RoomModePanel:CloseEnterRoomPanel()
    self.enterRoomPanel.gameObject:SetActive(false)
end

function RoomModePanel:EnterRoom()
    local toEnterRoomId = self.enterNumInputField.text
    if StringUtils.IsOnlyNumber(toEnterRoomId) then
        mod.MainuiFacade:SendMsg(10422,toEnterRoomId)
    else
        SystemMessage.Show(TI18N("输入非法，请检查"))
    end
end

function RoomModePanel:CreateRoomSuccess(data)
    self.roomId = data.room_id
    self.roomIdText.text = self.roomId
end

function RoomModePanel:EnterRoomSuccess(data)
    if data.room_id == 0 then
        SystemMessage.Show(TI18N("加入了不存在的房间"))
    end
end