FriendRemindCtrl = BaseClass("FriendRemindCtrl",Controller)

function FriendRemindCtrl:__Init()

end

function FriendRemindCtrl:__Delete()

end

function FriendRemindCtrl:__InitComplete()

end

function FriendRemindCtrl:CheckFriendApply(info,data,protoId)
    local exist = TableUtils.IsValid(mod.FriendProxy.tbApply)
    info:SetFlag(exist)
end

function FriendRemindCtrl:CheckFriendEntrance(info,data,protoId)
    local exist = TableUtils.IsValid(mod.FriendProxy.tbApply)
    info:SetFlag(exist)
end