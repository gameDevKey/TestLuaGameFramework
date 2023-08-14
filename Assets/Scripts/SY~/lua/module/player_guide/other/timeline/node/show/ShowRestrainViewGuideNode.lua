ShowRestrainViewGuideNode = BaseClass("ShowRestrainViewGuideNode",BaseGuideNode)

function ShowRestrainViewGuideNode:__Init()

end

function ShowRestrainViewGuideNode:OnStart()
    mod.BattleFacade:SendEvent(BattleInfoView.Event.ActiveRestrain,true)
end

function ShowRestrainViewGuideNode:OnDestroy()
    mod.BattleFacade:SendEvent(BattleInfoView.Event.ActiveRestrain,false)
end