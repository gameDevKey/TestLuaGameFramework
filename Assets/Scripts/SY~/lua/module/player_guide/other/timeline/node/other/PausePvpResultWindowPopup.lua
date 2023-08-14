PausePvpResultWindowPopup = BaseClass("PausePvpResultWindowPopup",BaseGuideNode)

function PausePvpResultWindowPopup:OnStart()
    if RunWorld and RunWorld.BattleResultSystem then
        RunWorld.BattleResultSystem:SetCanShowResultWindow(false)
    end
end