BattlepassRemindCtrl = BaseClass("BattlepassRemindCtrl",Controller)

function BattlepassRemindCtrl:__Init()

end

function BattlepassRemindCtrl:__Delete()

end

function BattlepassRemindCtrl:__InitComplete()

end

function BattlepassRemindCtrl:CheckBattlepassReward(info,data,protoId)
    if not mod.OpenFuncProxy:IsFuncUnlock(GDefine.FuncUnlockId.Battlepass) then
        info:SetFlag(false)
        return
    end
    local rewardIndex,isVip = mod.BattlepassProxy:GetUnclaimedAwardLevel()
    info:SetFlag(rewardIndex > 0)
end