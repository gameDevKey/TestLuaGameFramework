DrawCardJumper = BaseClass("DrawCardJumper",JumperBase)

function DrawCardJumper:__Init()

end

function DrawCardJumper:__Delete()

end

function DrawCardJumper:OnStart()
    ViewManager.Instance:OpenWindow(DrawCardWindow)
    self:Destroy()
end