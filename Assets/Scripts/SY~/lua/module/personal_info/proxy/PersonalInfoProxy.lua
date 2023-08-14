PersonalInfoProxy = BaseClass("PersonalInfoProxy",Proxy)

function PersonalInfoProxy:__Init()
    self.cardsClipboard = nil
    self.roleDatas = {}
end

function PersonalInfoProxy:__InitProxy()
    self:BindMsg(10112)
end

function PersonalInfoProxy:__InitComplete()
end

function PersonalInfoProxy:Send_10112(uid)
    local data = {}
    data.role_uid = uid
    LogTable("发送10112",data)
    return data
end

function PersonalInfoProxy:Recv_10112(data)
    LogTable("接收10112",data)
    local uid = data.role_base_info.role_uid
    self.roleDatas[uid] = data

    mod.PersonalInfoFacade:SendEvent(PersonalInfoFacade.Event.ShowOtherPersonalInfo, uid)
end

function PersonalInfoProxy:GetRoleData(uid)
    return self.roleDatas[uid]
end

function PersonalInfoProxy:SaveCardsToClipboard(data)
    self.cardsClipboard = data
end

function PersonalInfoProxy:GetCardsFromClipboard()
    return self.cardsClipboard
end