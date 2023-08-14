JumpWindow = BaseClass("JumpWindow", BaseWindow)
JumpWindow.__topInfo = true
JumpWindow.__bottomTab = true
JumpWindow.__showMainui = true
JumpWindow.notTempHide = true

JumpWindow.Event = EventEnum.New(
    "RefreshNewEquip"
)

function JumpWindow:__Init()
    self:SetAsset("ui/prefab/common/jump_window.prefab", AssetType.Prefab)

    self.equipItems = {}
    self.sellTips = false
end

function JumpWindow:__Delete()
end

function JumpWindow:__ExtendView()
end

function JumpWindow:__CacheObject()
    self.jumpObjs = {}
    for i = 1, 5 do self:GetJumpObjs(i) end

    self.jumpListTrans = self:Find("main/jump_list",RectTransform)
    self.mainRectTrans = self:Find("main",RectTransform)
end

function JumpWindow:__BindListener()
    self:Find("bg",Button):SetClick(self:ToFunc("CloseClick"))
end

function JumpWindow:__BindEvent()
end

function JumpWindow:GetJumpObjs(index)
    local object = {}
    local root = self:Find(string.format("main/jump_list/%s",index)).gameObject
    object.gameObject = root
    object.descText = root.transform:Find("desc").gameObject:GetComponent(Text)
    object.btn = root.transform:Find("jump_btn").gameObject:GetComponent(Button)
    self.jumpObjs[index] = object
end

function JumpWindow:__Show()
    local jumpDatas = self.args
    for i,jumpId in ipairs(jumpDatas) do
        local objs = self.jumpObjs[i]
        objs.gameObject:SetActive(true)

        local conf = Config.JumpData.data_jump_info[jumpId]
    
        objs.descText.text = conf.desc

        objs.btn:SetClick(self:ToFunc("JumpClick"),jumpId)
    end
    for i = #jumpDatas + 1, #self.jumpObjs do 
        self.jumpObjs[i].gameObject:SetActive(false)
    end

    UIUtils.ForceRebuildLayoutImmediate(self.jumpListTrans.gameObject)
    self.mainRectTrans:SetSizeDelata(621,259 + self.jumpListTrans.sizeDelta.y)
end

function JumpWindow:JumpClick(jumpId)
    self:CloseClick()
    mod.JumpCtrl:JumpTo(jumpId)
end

function JumpWindow:CloseClick()
    ViewManager.Instance:CloseWindow(JumpWindow)
end