ViewDefine = SingleClass("ViewDefine")




ViewDefine.Layer =
{
    ["LoginWindow"] = 0,
    ["BattleUnitDetailsPanel"] = 100,
    ["BattleHeroDetailsPanel"] = 100,
    ["BattleCommanderDetailsPanel"] = 100,
    ["BattleDragSkillTips"] = 100,
    ["BattleResultWindow"] = 101,
    ["PveResultWindow"] = 101,
    ["ObtainedNewUnitWindow"] = 102,
    ["UnitLevelUpPanel"] = 201,
    ["CommanderLevelUpPanel"] = 201,
    ["ChestOpenPanel"] = 201,
    ["RewardPanel"] = 201,
    ["ObtainSecView"]=213,
    ["ObtainView"]=213,
    ["TipsView"]=300,
    ["AwardWindow"] = 10000,
}

-- ViewDefine.AutoOpenPriority =
-- {
--     ["RankWindow"] = 1,
--     ["ObtainedNewUnitWindow"] = 2,
-- }

ViewDefine.Layer["MainuiPanel"] = 0


ViewDefine.Layer["BattleMainPanel_Lock"] = 32736


ViewDefine.Layer["MainuiPanel_Top_Bottom"] = ViewDefine.Layer["BattleMainPanel_Lock"] + 1

ViewDefine.Layer["PlayerGuideView"] = ViewDefine.Layer["MainuiPanel_Top_Bottom"] + 1
ViewDefine.Layer["PlayerGuideView_Effect"] = ViewDefine.Layer["PlayerGuideView"] + 1



ViewDefine.Layer["GmView"] = ViewDefine.Layer["PlayerGuideView_Effect"] + 1
ViewDefine.Layer["GmWindow"] = ViewDefine.Layer["GmView"] + 1


ViewDefine.Layer["SystemDialogPanel"] = ViewDefine.Layer["GmWindow"] + 1


ViewDefine.Layer["EquipTips"] = ViewDefine.Layer["SystemDialogPanel"] + 1
ViewDefine.Layer["PropTips"] = ViewDefine.Layer["EquipTips"]
ViewDefine.Layer["SkillTips"] = ViewDefine.Layer["PropTips"]

ViewDefine.Layer["DashboardWindow"] = ViewDefine.Layer["EquipTips"] + 1

ViewDefine.WindowIdToName =
{
    
}