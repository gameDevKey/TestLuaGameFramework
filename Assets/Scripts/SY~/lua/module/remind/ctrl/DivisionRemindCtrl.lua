DivisionRemindCtrl = BaseClass("DivisionRemindCtrl",Controller)

function DivisionRemindCtrl:__Init()
    self.lastDivision = -1
end

function DivisionRemindCtrl:__Delete()

end

function DivisionRemindCtrl:__InitComplete()

end

function DivisionRemindCtrl:CheckDivisionUp(info,data,protoId)
    local flag = false
    local current = mod.RoleProxy:GetRoleData()
    local lastDivision = self.lastDivision
    if current.division > lastDivision then
        flag = true
        self.lastDivision = current.division
    end
    info:SetFlag(flag)
end

function DivisionRemindCtrl:CheckDivisionReward(info,data,protoId)
    local rewardIndex,rewardId = mod.DivisionProxy:GetUnclaimedRewardItemIndex()
    info:SetFlag(rewardIndex > 0)
end