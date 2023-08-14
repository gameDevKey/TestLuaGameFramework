TaskJumper = BaseClass("TaskJumper",JumperBase)

function TaskJumper:__Init()

end

function TaskJumper:__Delete()

end

function TaskJumper:OnStart()
    ViewManager.Instance:OpenWindow(DailyTaskWindow)
    self:Destroy()
end