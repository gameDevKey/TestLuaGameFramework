AddMoneyGuideNode = BaseClass("AddMoneyGuideNode",BaseGuideNode)

function AddMoneyGuideNode:__Init()

end

function AddMoneyGuideNode:OnStart()
    local roleUid = RunWorld.BattleDataSystem.roleUid
    RunWorld.BattleMixedSystem:AddRoleMoney(roleUid,self.actionParam.money)
    mod.BattleFacade:SendEvent(BattleInfoView.Event.RefreshMoney)
end

function AddMoneyGuideNode:OnDestroy()
    
end