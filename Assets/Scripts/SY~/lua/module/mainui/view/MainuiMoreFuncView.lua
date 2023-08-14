MainuiMoreFuncView = BaseClass("MainuiMoreFuncView",ExtendView)
MainuiMoreFuncView.Event = EventEnum.New(
    "ActiveMoreFuncView"
)

function MainuiMoreFuncView:__Init()
    self.tbItem = {}
    self.confs = {
        {
            name = TI18N("邮件"),
            onClick = self:ToFunc("OpenEmail"),
        },
        {
            name = TI18N("排行榜"),
            onClick = self:ToFunc("OpenRankList"),
        },
    }
end

function MainuiMoreFuncView:__Create()
end

function MainuiMoreFuncView:__CacheObject()
    self.view = self:Find("main/more_func_panel").gameObject
    self.btnBgClose = self:Find("main/more_func_panel/btn_bg_close",Button)
    self.content = self:Find("main/more_func_panel/content")
    self.template = self:Find("main/more_func_panel/content/more_func_item").gameObject
    self.template:SetActive(false)
end

function MainuiMoreFuncView:__BindListener()
    self.btnBgClose:SetClick(self:ToFunc("ActiveMoreFuncView"),false)
end

function MainuiMoreFuncView:__BindEvent()
    self:BindEvent(MainuiMoreFuncView.Event.ActiveMoreFuncView)
end

function MainuiMoreFuncView:__Hide()
    self:ClearAllItem()
    self.view:SetActive(false)
end

function MainuiMoreFuncView:__Show()
    self.view:SetActive(false)
    self:LoadAllItem()
end

function MainuiMoreFuncView:ActiveMoreFuncView(active)
    self.view:SetActive(active)
end

function MainuiMoreFuncView:ClearAllItem()
    for _, item in ipairs(self.tbItem) do
        GameObject.Destroy(item)
    end
    self.tbItem = {}
end

function MainuiMoreFuncView:LoadAllItem()
    self:ClearAllItem()
    for _, conf in ipairs(self.confs) do
        local item = GameObject.Instantiate(self.template)
        item:SetActive(true)
        item.transform:SetParent(self.content)
        item.transform:Reset()
        local txtName = item.transform:Find("name"):GetComponent(Text)
        txtName.text = conf.name
        local btn = item:GetComponent(Button)
        btn:SetClick(self:ToFunc("HandleClick"),conf)
        table.insert(self.tbItem, item)
    end
end

function MainuiMoreFuncView:HandleClick(conf)
    if conf.onClick then
        conf.onClick()
    end
    self.view:SetActive(false)
end

function MainuiMoreFuncView:OpenEmail()
    mod.EmailCtrl:OpenEmail()
end

function MainuiMoreFuncView:OpenRankList()
    mod.RankListCtrl:OpenRankList()
end