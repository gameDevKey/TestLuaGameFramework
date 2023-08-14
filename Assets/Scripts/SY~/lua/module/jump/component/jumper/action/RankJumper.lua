RankJumper = BaseClass("RankJumper",JumperBase)

function RankJumper:__Init()

end

function RankJumper:__Delete()

end

function RankJumper:OnStart()
    ViewManager.Instance:OpenWindow(RankWindow)
    self:Destroy()
end