FriendCtrl = BaseClass("FriendCtrl",Controller)

function FriendCtrl:__Init()
end

function FriendCtrl:OpenFriend()
    if not mod.OpenFuncProxy:JudgeFuncUnlockAndMsg(GDefine.FuncUnlockId.Friend) then
        return
    end
    ViewManager.Instance:OpenWindow(FriendMainPanel)
end

function FriendCtrl:ReqDelFriendByDialog(uid)
    local data = {}
    data.content = "好友删除后，聊天记录将被清空，是否删除好友？"
    data.notShowKey = "friend_delete"
    data.onConfirm = self:ToFunc("OnConfirmDeleteFriend")
    data.args = uid
    SystemDialog.Show(data)
end

function FriendCtrl:OnConfirmDeleteFriend(uid)
    mod.FriendProxy:SendMsg(11904,uid)
    --TODO 清除好友聊天记录
end

function FriendCtrl:ReqDelBlackAndAddFriendByDialog(uid)
    local friend = mod.FriendProxy.tbBlack[uid]
    local name = friend and friend.name or ""
    local data = {}
    data.content = name .. "当前处于黑名单中，是否移除黑名单并添加好友?"
    data.notShowKey = "friend_del_black_and_add"
    data.onConfirm = self:ToFunc("OnConfirmDelBlackAndAddFriend")
    data.confirmStr = "移除黑名单并添加"
    data.cancelStr = "取消添加"
    data.args = uid
    SystemDialog.Show(data)
end

function FriendCtrl:OnConfirmDelBlackAndAddFriend(uid)
    --TODO 按顺序发送就行了吗? 服务端说取消拉黑是不会失败的，先这样吧
    mod.FriendProxy:SendMsg(11911,uid)
    mod.FriendProxy:SendMsg(11902,uid)
end

function FriendCtrl:ReqAddBlackByDialog(uid)
    local data = {}
    data.content = "加入黑名单后将无法收到对方消息，是否继续？"
    data.notShowKey = "friend_add_balck"
    data.onConfirm = self:ToFunc("OnConfirmAddBlack")
    data.args = uid
    SystemDialog.Show(data)
end

function FriendCtrl:OnConfirmAddBlack(uid)
    mod.FriendProxy:SendMsg(11907, uid)
end