JumpFacade = BaseClass("JumpFacade",Facade)

function JumpFacade:__Init()

end

function JumpFacade:__InitFacade()
    self:BindCtrl(JumpCtrl)
end