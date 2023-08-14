TipsView = BaseClass("TipsView",BaseWindow)

function TipsView:__Init()
    self:SetAsset("ui/prefab/tips/tips_window.prefab", AssetType.Prefab)

    self.groupitem = {}
end

function TipsView:__CacheObject()
    self.destext = self:Find("main/des_text",Text)
end

function TipsView:__BindListener()
    self:Find("main/enter_btn",Button):SetClick(self:ToFunc("EnterClick"))
    self:Find("main/cancel_btn",Button):SetClick(self:ToFunc("CloseClick"))
end

function TipsView:__Show()
    self:SetOther()
end

function TipsView:SetOther()
    self.destext.text = "这里是。。。。。。"
end

function TipsView:EnterClick()
    mod.TipsProxy.tipsFlag = true
    ViewManager.Instance:CloseWindow(TipsView)
end

function TipsView:CloseClick()
    mod.TipsProxy.tipsFlag = false
    ViewManager.Instance:CloseWindow(TipsView)
end