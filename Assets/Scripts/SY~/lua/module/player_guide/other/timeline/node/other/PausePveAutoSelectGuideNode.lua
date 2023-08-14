PausePveAutoSelectGuideNode = BaseClass("PausePveAutoSelectGuideNode",BaseGuideNode)

function PausePveAutoSelectGuideNode:__Init()

end

function PausePveAutoSelectGuideNode:OnStart()
    if RunWorld and RunWorld.SelectPveItemSystem then
        RunWorld.SelectPveItemSystem:PauseSelectTimer()
    else
        error("PVE引导节点(PausePveAutoSelectGuideNode)被错误调用!")
    end
end

function PausePveAutoSelectGuideNode:OnDestroy()
    
end