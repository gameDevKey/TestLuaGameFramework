GamePlayMenuItem = Class("GamePlayMenuItem",ComUI)

function GamePlayMenuItem:OnInit()
end

function GamePlayMenuItem:OnFindComponent()
    self.txtName = self:GetText("name")
    self.btn = self:GetButton()
end

function GamePlayMenuItem:OnInitComponent()
    ButtonExt.SetClick(self.btn, self:ToFunc("onClick"))
end

function GamePlayMenuItem:OnSetData(data,index,viewUI)
    self.txtName.text = data.name
end

function GamePlayMenuItem:OnHide()

end

function GamePlayMenuItem:onClick()
    PrintLog("点击了",self.data.name)
end

return GamePlayMenuItem