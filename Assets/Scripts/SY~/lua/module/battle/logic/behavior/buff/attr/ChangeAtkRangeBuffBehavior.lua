ChangeAtkRangeBuffBehavior = BaseClass("ChangeAtkRangeBuffBehavior",BuffBehavior)

function ChangeAtkRangeBuffBehavior:__Init()
    self.changeRangeUids = {}
end

function ChangeAtkRangeBuffBehavior:__Delete()

end

function ChangeAtkRangeBuffBehavior:OnInit()
end

function ChangeAtkRangeBuffBehavior:OnExecute()
    local changeUid = self.world:GetUid(BattleDefine.UidType.change_range)
    local changeInfo = self.entity.KvDataComponent:GetData(BattleDefine.EntityKvType.change_range) or {uid = 0,changes = SECBList.New()}
    changeInfo.uid = changeUid
    changeInfo.changes:Push(self.actionParam,changeUid)
    table.insert(self.changeRangeUids,changeUid)
    self.entity.KvDataComponent:SetData(BattleDefine.EntityKvType.change_range,changeInfo)
    return true
end

function ChangeAtkRangeBuffBehavior:OnDestroy()
    local changeInfo = self.entity.KvDataComponent:GetData(BattleDefine.EntityKvType.change_range)
    if changeInfo then
        changeInfo.uid = self.world:GetUid(BattleDefine.UidType.change_range)
        for i,uid in ipairs(self.changeRangeUids) do
            changeInfo.changes:RemoveByIndex(uid)
        end
    end
    self.changeRangeUids = {}
end