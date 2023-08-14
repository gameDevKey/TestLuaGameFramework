MainuiBottomBtnPanel = BaseClass("MainuiBottomBtnPanel",ExtendView)

MainuiBottomBtnPanel.Event = EventEnum.New(
    "SwitchTab"
)

function MainuiBottomBtnPanel:__Init()
    self.btnInfo = {
        [1] = {func = "ShowShopWindow"},
        [2] = { func = "ShowCollectionWindow" },
        [3] = { func = "ShowBattleWindow" },
        [4] = { func = "ShowCommanderWindow" },
        [5] = { func = "ShowEventsWindow" }
    }

    self.debugClickNum = 0
    self.debugLastClickTime = 0
end

function MainuiBottomBtnPanel:__CacheObject()
    self.tabs = {}
    for i = 1, 5 do
        local tab = {}
        local path = string.format("bottom_canvas/img_bg/tab_%d",i)
        tab.btn = self:Find(path.."/btn",Button)
        tab.select = self:Find(path.."/img_select_icon").gameObject
        tab.remindParent = self:Find(path.."/remind_node")
        table.insert(self.tabs,tab)
    end
end

function MainuiBottomBtnPanel:__Create()
end

function MainuiBottomBtnPanel:__BindListener ()
    for i,v in ipairs(self.tabs) do
        v.btn:SetClick(self:ToFunc("SwitchTab"),i)
    end
end

function MainuiBottomBtnPanel:__BindEvent()
    self:BindEvent(MainuiBottomBtnPanel.Event.SwitchTab)
end

function MainuiBottomBtnPanel:__Show()
    self:SwitchTab(3)
end

function MainuiBottomBtnPanel:SwitchTab(index)
    if index > 4 then
        if os.time() - self.debugLastClickTime <= 0.5 then
            self.debugClickNum = self.debugClickNum + 1
        else
            self.debugClickNum = 1
        end
    
        if self.debugClickNum >= 5 then
            self.debugClickNum = 1
            IS_DEBUG = not IS_DEBUG
            PlayerPrefsEx.SetInt("IS_DEBUG",IS_DEBUG and 1 or 0)
            mod.GmFacade:SendEvent(GmView.Event.ActiveGm,IS_DEBUG)
        end
    
        self.debugLastClickTime = os.time()

        SystemMessage.Show(TI18N("系统开发中…"))
        return
    -- elseif index == 2 then
    --     --TODO:临时代码，确保打完第一场引导战斗后才能打开背包界面，防止引导前换英雄
    --     --正式做法：1、加入外部引导，进入主界面开始引导进入战斗 or 2、接入开放系统
    --     if not mod.PlayerGuideProxy:HasGuideGroup(3) then
    --         SystemMessage.Show(TI18N("打完新手战斗后，方可进入卡牌背包"))
    --         return
    --     end
    end

    if index == 1 then
        if not mod.OpenFuncProxy:JudgeFuncUnlockAndMsg(GDefine.FuncUnlockId.Store) then
            return
        end
    end
    if index == 4 then
        if not mod.OpenFuncProxy:JudgeFuncUnlockAndMsg(GDefine.FuncUnlockId.OpenChest) then
            return
        end
    end

    ViewManager.Instance:CloseAllWindow()

    for i,v in ipairs(self.tabs) do
        v.select:SetActive(i == index)
    end

    local func = self.btnInfo[index]
    if func then
        self[func.func](self)
    end
end

function MainuiBottomBtnPanel:ShowShopWindow()
    ViewManager.Instance:OpenWindow(ShopWindow)
end

function MainuiBottomBtnPanel:ShowCollectionWindow()
    ViewManager.Instance:OpenWindow(CollectionWindow)
end

function MainuiBottomBtnPanel:ShowBattleWindow()
    ViewManager.Instance:CloseAllWindow()
end

function MainuiBottomBtnPanel:ShowCommanderWindow()
    ViewManager.Instance:OpenWindow(CommanderWindow)
end
