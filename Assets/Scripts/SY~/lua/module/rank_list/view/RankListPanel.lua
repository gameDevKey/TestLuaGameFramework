RankListPanel = BaseClass("RankListPanel",BaseWindow)
RankListPanel.__showMainui = true
RankListPanel.__topInfo = true
RankListPanel.__bottomTab = true
RankListPanel.notTempHide = true

RankListPanel.TabSelectColor = Color(90/255,116/255,160/255,1)
RankListPanel.TabUnselectColor = Color(225/255,236/255,1,1)

function RankListPanel:__Init()
    self:SetAsset("ui/prefab/rank_list/rank_list_panel.prefab",AssetType.Prefab)
end

function RankListPanel:__Delete()
end

function RankListPanel:__CacheObject()
    self.txtSeason = self:Find("main/txt_season",Text)
    self.btnBgClose = self:Find("mask",Button)
    self.btnClose = self:Find("main/btn_close",Button)
    self.tabConf = {
        [RankListDefine.TabType.Player] = {
            tab = self:Find("main/tab1",Button),
            select = self:Find("main/tab1_select").gameObject,
            txt = self:Find("main/tab1_name",Text),
            onShow = RankListFacade.Event.ShowPlayerList,
            onHide = RankListFacade.Event.HidePlayerList,
        },
        [RankListDefine.TabType.Other1] = {
            tab = self:Find("main/tab2",Button),
            txt = self:Find("main/tab2_name",Text),
            select = self:Find("main/tab2_select").gameObject,
        },
        [RankListDefine.TabType.Other2] = {
            tab = self:Find("main/tab3",Button),
            txt = self:Find("main/tab3_name",Text),
            select = self:Find("main/tab3_select").gameObject,
        },
    }
end

function RankListPanel:__ExtendView()
    self:ExtendView(RankListPlayerView)
end

function RankListPanel:__Create()
    for tpe, conf in pairs(self.tabConf) do
        conf.tab:SetClick(self:ToFunc("OnTabClick"),tpe)
    end
    self.btnBgClose:SetClick(self:ToFunc("OnCloseBtnClick"))
    self.btnClose:SetClick(self:ToFunc("OnCloseBtnClick"))
end

function RankListPanel:__BindListener()
end

function RankListPanel:__BindEvent()
end

function RankListPanel:__Show()
    self:OnTabClick(RankListDefine.TabType.Player)
    self.txtSeason.text = string.format("<color=#83E9F3>赛季结束时间：</color>%s",self:GetSeasonTimeStr())
end

function RankListPanel:__Hide()
end

function RankListPanel:OnTabClick(type)
    for tpe, conf in pairs(self.tabConf) do
        if tpe == type then
            conf.select:SetActive(true)
            conf.txt.color = RankListPanel.TabSelectColor
            if conf.onShow then
                mod.RankListFacade:SendEvent(conf.onShow)
            end
        else
            conf.select:SetActive(false)
            conf.txt.color = RankListPanel.TabUnselectColor
            if conf.onHide then
                mod.RankListFacade:SendEvent(conf.onHide)
            end
        end
    end
end

function RankListPanel:OnCloseBtnClick()
    ViewManager.Instance:CloseWindow(RankListPanel)
end

function RankListPanel:GetSeasonTimeStr()
    return "12小时12分"
end