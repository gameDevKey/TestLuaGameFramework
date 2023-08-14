TaskFacade = BaseClass("TaskFacade",Facade)

-- TaskFacade.Event = EventEnum.New()

function TaskFacade:__Init()

end

function TaskFacade:__InitFacade()
    self:BindCtrl(TaskCtrl)

    self:BindProxy(TaskProxy)
end