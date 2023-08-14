EmailRemindCtrl = BaseClass("EmailRemindCtrl",Controller)

function EmailRemindCtrl:__Init()

end

function EmailRemindCtrl:__Delete()

end

function EmailRemindCtrl:__InitComplete()

end

function EmailRemindCtrl:CheckEmailUnread(info,data,protoId)
    if not mod.OpenFuncProxy:IsFuncUnlock(GDefine.FuncUnlockId.Email) then
        info:SetFlag(false)
        return
    end
    local num = mod.EmailProxy.unreadNum
    info:SetFlag(num > 0)
end