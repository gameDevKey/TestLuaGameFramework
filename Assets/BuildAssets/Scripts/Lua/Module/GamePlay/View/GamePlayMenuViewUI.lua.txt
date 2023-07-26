GamePlayMenuViewUI = Class("GamePlayMenuViewUI",ViewUI)

function GamePlayMenuViewUI:OnInit()
    self:SetAssetPath("GameMenuWindow")
end

function GamePlayMenuViewUI:OnFindComponent()
    self.startBtn = self:GetButton("btn_start")
    self.returnBtn = self:GetButton("btn_return")
    self.container = self:GetTransform("container")

    self.listSR = self:GetScrollRect("list")
    self.template = self:GetGameObject("list/Viewport/Content/item")
    self.template:SetActive(false)
end

function GamePlayMenuViewUI:OnInitComponent()
    ButtonExt.SetClick(self.startBtn, self:ToFunc("OnStartBtnClick"))
    ButtonExt.SetClick(self.returnBtn, self:ToFunc("OnReturnBtnClick"))
end

function GamePlayMenuViewUI:OnEnter(data)
    self.data = data
    self:EnterComplete()
end

function GamePlayMenuViewUI:OnEnterComplete()

    local testData = {}
    for i = 1, 20, 1 do
        table.insert(testData,{data={name="按钮"..i}})
    end
    self:buildScrollView(self.listSR,testData)
end

function GamePlayMenuViewUI:OnExit()
    self:destroyScrollView()
end

function GamePlayMenuViewUI:OnExitComplete()
end

function GamePlayMenuViewUI:OnRefresh()
    self.gameObject:SetActive(true)
end

function GamePlayMenuViewUI:OnHide()
    self.gameObject:SetActive(false)
end

function GamePlayMenuViewUI:OnStartBtnClick()
    self:Broadcast(EGamePlayModule.LogicEvent.StartGame)
end

function GamePlayMenuViewUI:OnReturnBtnClick()
    self:Exit()
end

function GamePlayMenuViewUI:buildScrollView(scrollRect,data)
    self:destroyScrollView()
    self.loopScrollView = HorizontalLoopScrollView.New(scrollRect,{
        gapX = 20,
        itemWidth = 100,
        itemHeight = 100,
        onCreate = self:ToFunc("createItem"),
        onRender = self:ToFunc("renderItem"),
    })
    self.loopScrollView:SetDatas(data)
    self.loopScrollView:Start()
end

function GamePlayMenuViewUI:destroyScrollView()
    if self.loopScrollView then
        self.loopScrollView:Delete()
        self.loopScrollView = nil
    end
end

function GamePlayMenuViewUI:createItem(index, data)
    return self:CreateComUI(UIDefine.ComType.GamePlayMenuItem,self.template,data)
end

function GamePlayMenuViewUI:renderItem(item, index, data)
    item:SetData(data.data, index, self)
end

return GamePlayMenuViewUI