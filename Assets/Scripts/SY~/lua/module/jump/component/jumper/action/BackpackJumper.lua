BackpackJumper = BaseClass("BackpackJumper",JumperBase)

function BackpackJumper:__Init()

end

function BackpackJumper:__Delete()

end

function BackpackJumper:OnStart()
    mod.MainuiFacade:SendEvent(MainuiBottomBtnPanel.Event.SwitchTab,2)
    self:Destroy()
end