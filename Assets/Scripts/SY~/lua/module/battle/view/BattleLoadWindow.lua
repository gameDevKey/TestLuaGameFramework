BattleLoadWindow = BaseClass("BattleLoadWindow",BaseWindow)
BattleLoadWindow.Event = EventEnum.New(
    "UpdateProgress"
)

function BattleLoadWindow:__Init()
    self:SetAsset("ui/prefab/battle/battle_load_window.prefab",AssetType.Prefab)
    self.timer = nil
    self.virtualProgress = 0
    self.progressTimer = nil
    self.waitTimer = nil
end

function BattleLoadWindow:__Delete()
end

function BattleLoadWindow:__CacheObject()
    self.progressBar = self:Find("main/progress_bar",Image)
    self.progressNum = self:Find("main/progress_num",Text)
    self.tipsText = self:Find("main/tips",Text)
end

function BattleLoadWindow:__BindListener()

end

function BattleLoadWindow:__BindBeforeEvent()

end

function BattleLoadWindow:__BindEvent()
    self:BindEvent(BattleLoadWindow.Event.UpdateProgress)
end

function BattleLoadWindow:__Create()

end

function BattleLoadWindow:__Show()
    --显示信息
    self.progressNum.text = "0%"
    self.progressBar.fillAmount = 0

    if RunWorld.worldType == BattleDefine.WorldType.pvp then
        local index = math.random(1,Config.PvpData.data_random_tips_length)
        self.tipsText.text = Config.PvpData.data_random_tips[index].tips
    elseif RunWorld.worldType == BattleDefine.WorldType.pvp then
        local index = math.random(1,Config.PveData.data_random_tips_length)
        self.tipsText.text = Config.PvpData.data_random_tips[index].tips
    end

    ViewManager.Instance:CloseWindow(MatchingWindow)
    -- mod.BattlePreLoadCtrl:PreLoadBattleAsset()
    RunWorld.BattlePreLoadSystem:PreLoadBattleAsset()
end

function BattleLoadWindow:UpdateProgress(val)
    self.virtualProgress = val
    if self.virtualProgress > 100 then
        self.virtualProgress = 100
    end

    self.progressNum.text = tostring(math.floor(self.virtualProgress)) .. "%"
    self.progressBar.fillAmount = self.virtualProgress / 100
end