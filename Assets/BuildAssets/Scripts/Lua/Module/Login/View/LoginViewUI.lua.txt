LoginViewUI = Class("LoginViewUI",ViewUI)

function LoginViewUI:OnInit()
    self:SetAssetPath("LoginWindow")
end

function LoginViewUI:OnFindComponent()
    self.loginBtn = self:GetButton("btn")
    self.txtName = self:GetText("btn/txt")
    self.container = self:GetTransform("container")

    self.template = self:GetTransform("container/LoginCom").gameObject
    self.template:SetActive(false)

    self.serverListSR = self:GetScrollRect("serverlist")
    self.serverTemplate = self:GetGameObject("serverlist/Viewport/Content/serveritem")
    self.serverTemplate:SetActive(false)
end

function LoginViewUI:OnInitComponent()
    ButtonExt.SetClick(self.loginBtn, self:ToFunc("onLoginBtnClick"))
end

function LoginViewUI:OnEnter(data)
    self.data = data
    self:EnterComplete()
end

function LoginViewUI:OnEnterComplete()
    self:BatchCreateComUIByAmount(UIDefine.ComType.LoginCom,self.container,3,self.template)
    local testData = {}
    for i = 1, 20, 1 do
        -- table.insert(testData,{data={name="服务器"..i}})

        table.insert(testData,{data={name="测试"..i}})
    end
    self:buildServerList(testData)
end

function LoginViewUI:OnExit()
    self:destroyServerList()
end

function LoginViewUI:OnExitComplete()
end

function LoginViewUI:OnRefresh()
    self.gameObject:SetActive(true)
    self.loopScrollView:ScrollToTop(nil, 0.5, nil, ELoopScrollView.JumpType.Top)
end

function LoginViewUI:OnHide()
    self.gameObject:SetActive(false)
end

function LoginViewUI:onLoginBtnClick()
    EventDispatcher.Global:Broadcast(EGlobalEvent.Login, ELoginModule.LoginState.OK)
end

function LoginViewUI:buildServerList(testData)
    self:destroyServerList()
    self.loopScrollView = VerticalLoopScrollView.New(self.serverListSR,{
        gapY = 10,
        itemWidth = 414.13,
        itemHeight = 75.62579,
        onCreate = self:ToFunc("createServerListItem"),
        onRender = self:ToFunc("renderServerListItem"),
    })
    self.loopScrollView:SetDatas(testData)
    self.loopScrollView:Start()
end

function LoginViewUI:destroyServerList()
    if self.loopScrollView then
        self.loopScrollView:Delete()
        self.loopScrollView = nil
    end
end

function LoginViewUI:createServerListItem(index, data)
    return self:CreateComUI(UIDefine.ComType.ServerListItem,self.serverTemplate,data)
end

function LoginViewUI:renderServerListItem(item, index, data)
    item:SetData(data.data, index, self)
end

return LoginViewUI