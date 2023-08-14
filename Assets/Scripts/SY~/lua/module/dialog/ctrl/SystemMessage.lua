SystemMessage = StaticClass("SystemMessage")


function SystemMessage.Show(msg)
    mod.DialogFacade:SendEvent(SystemMessagePanel.Event.ShowSystemMessage,msg)
end