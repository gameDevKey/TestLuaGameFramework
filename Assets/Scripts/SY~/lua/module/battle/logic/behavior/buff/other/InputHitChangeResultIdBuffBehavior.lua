InputHitChangeResultIdBuffBehavior = BaseClass("InputHitChangeResultIdBuffBehavior",BuffBehavior)

function InputHitChangeResultIdBuffBehavior:__Init()
    self.hitInfos = {}
end

function InputHitChangeResultIdBuffBehavior:__Delete()

end

function InputHitChangeResultIdBuffBehavior:OnInit()
    local eventParam = {}
    eventParam.entityUid = self.entity.uid
    self:AddEvent(BattleEvent.change_hit_result_id,self:ToFunc("OnEvent"),eventParam)
end

function InputHitChangeResultIdBuffBehavior:AddChangeInfo(hitResultUid,inputParam)
    self.hitInfos[hitResultUid] = inputParam
end

function InputHitChangeResultIdBuffBehavior:OnEvent(args)
    if not self.hitInfos[args.hitResultUid] then
        return
    end
    local inputParam = self.hitInfos[args.hitResultUid]
    return inputParam.changes[args.hitResultId] or inputParam.changes[0]
end

function InputHitChangeResultIdBuffBehavior:OnDestroy()

end