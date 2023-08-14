BattlepassJumper = BaseClass("BattlepassJumper",JumperBase)

function BattlepassJumper:__Init()

end

function BattlepassJumper:__Delete()

end

function BattlepassJumper:OnStart()
    ViewManager.Instance:OpenWindow(BattlepassWindow)
    self:Destroy()
end