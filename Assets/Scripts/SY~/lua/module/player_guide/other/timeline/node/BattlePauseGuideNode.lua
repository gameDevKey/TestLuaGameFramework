BattlePauseGuideNode = BaseClass("BattlePauseGuideNode",BaseGuideNode)

function BattlePauseGuideNode:__Init()

end

function BattlePauseGuideNode:OnInit()
    RunWorld.BattleMixedSystem:BattlePause(true)
end


function BattlePauseGuideNode:OnDestroy()
    RunWorld.BattleMixedSystem:BattlePause(false)
end