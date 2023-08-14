RoleFacade = BaseClass("RoleFacade",Facade)

function RoleFacade:__Init()

end

function RoleFacade:__InitFacade()
    self:BindProxy(RoleProxy)
    self:BindProxy(RoleItemProxy)
end
