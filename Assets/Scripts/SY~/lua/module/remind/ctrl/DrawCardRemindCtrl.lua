DrawCardRemindCtrl = BaseClass("DrawCardRemindCtrl",Controller)

function DrawCardRemindCtrl:__Init()

end

function DrawCardRemindCtrl:__Delete()

end

function DrawCardRemindCtrl:__InitComplete()

end

function DrawCardRemindCtrl:CheckTicketEnough(info,data,protoId)
    if not mod.OpenFuncProxy:IsFuncUnlock(GDefine.FuncUnlockId.DrawCard) then
        info:SetFlag(false)
        return
    end
    local need = mod.DrawCardProxy:GetDrawCardTicketCost()
    local own = mod.RoleItemProxy:GetItemNum(GDefine.ItemId.DrawCardTicket)
    info:SetFlag(own >= need)
end