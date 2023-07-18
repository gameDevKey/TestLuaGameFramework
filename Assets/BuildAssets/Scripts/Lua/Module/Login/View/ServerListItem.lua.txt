ServerListItem = Class("ServerListItem",ComUI)

function ServerListItem:OnInit()
end

function ServerListItem:OnFindComponent()
    self.txtName = self:GetText("name")
end

function ServerListItem:OnInitComponent()
    
end

function ServerListItem:OnSetData(data,index,viewUI)
    self.txtName.text = data.name
end

function ServerListItem:OnHide()

end

return ServerListItem