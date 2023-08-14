ResumePvpResultWindowPopup = BaseClass("ResumePvpResultWindowPopup",BaseGuideNode)

function ResumePvpResultWindowPopup:OnStart()
    if RunWorld and RunWorld.BattleResultSystem then
        RunWorld.BattleResultSystem:SetCanShowResultWindow(true)
        RunWorld.BattleResultSystem:TryShowResultWindow()
    end
end