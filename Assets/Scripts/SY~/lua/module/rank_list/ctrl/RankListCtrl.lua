RankListCtrl = BaseClass("RankListCtrl",Controller)

function RankListCtrl:__Init()
end

function RankListCtrl:OpenRankList()
    ViewManager.Instance:OpenWindow(RankListPanel)
end