CommanderJumper = BaseClass("CommanderJumper",JumperBase)

function CommanderJumper:__Init()

end

function CommanderJumper:__Delete()

end

function CommanderJumper:OnStart()
    mod.MainuiFacade:SendEvent(MainuiBottomBtnPanel.Event.SwitchTab,4)
    self:Destroy()
end