CollectionWindow = BaseClass("CollectionWindow",BaseWindow)
CollectionWindow.__topInfo = true
CollectionWindow.__bottomTab = true
CollectionWindow.__adaptive = true

CollectionWindow.Event = EventEnum.New(
    "PlayEnterAnim"
)

function CollectionWindow:__Init()
    self:SetAsset("ui/prefab/collection/collection_window.prefab",AssetType.Prefab)
    self:AddAsset(AssetPath.collectionItemCtrl,AssetType.Object)
end

function CollectionWindow:__Delete()
end

function CollectionWindow:__ExtendView()
    self.embattleView = self:ExtendView(CollectionEmbattleView)
    self.libraryView = self:ExtendView(CollectionLibraryView)
end

function CollectionWindow:__CacheObject()
    self.scrollRect = self:Find("main/scroll_view",ScrollRect)
    self.scrollViewContent = self:Find("main/scroll_view/view_port/content")
    self.scrollCanvasGroup = self:Find("main/scroll_view",CanvasGroup)
    self.bgs = self:Find("bgs")
    self.bg2 = self:Find("adaptation")
end

function CollectionWindow:__Create()
    self.collectionItemCtrl = self:GetAsset(AssetPath.collectionItemCtrl)
    AssetLoaderProxy.Instance:AddReference(AssetPath.collectionItemCtrl)
    self.autoReleaser:Remove(AssetPath.collectionItemCtrl)
    self.autoReleaser:Add(AssetPath.collectionItemCtrl)
end

function CollectionWindow:__BindEvent()
    self:BindEvent(CollectionWindow.Event.PlayEnterAnim)
end

function CollectionWindow:__BindListener()
    self.scrollRect:SetValueChanged(self:ToFunc("OnScrollRectValueChanged"))
end

function CollectionWindow:__Show()
    self:PlayEnterAnim()
end

function CollectionWindow:OnScrollRectValueChanged()
    local posY = self.scrollViewContent.anchoredPosition.y
    local anchoredX = 0
    local anchoredY = math.floor(276 + posY + 0.5)
    if anchoredY < 171 then
        anchoredY = 171
    elseif anchoredY > 276 then
        anchoredY = 276
    end
    if (anchoredY ~= 171 or self.bgs.anchoredPosition.y ~= 171) and (anchoredY ~= 276 or self.bgs.anchoredPosition.y ~= 276) then
        UnityUtils.SetAnchoredPosition(self.bgs, anchoredX, anchoredY)
        UnityUtils.SetAnchoredPosition(self.bg2, anchoredX, anchoredY - 276)
    end
end

function CollectionWindow:LayoutGroupEnable(flag)
    local trans = self:Find("main/scroll_view/view_port/content")
    UIUtils.ForceRebuildLayoutImmediate(trans)
    UIUtils.SetLayoutComponentEnable(trans, flag)
end

function CollectionWindow:OnEnterAnimCompleted()
    self:EnableAnimator(false)
    self.scrollCanvasGroup.interactable = true
    self.scrollCanvasGroup.blocksRaycasts = true
end

function CollectionWindow:OnTurnAnimCompleted(args)
    self:EnableAnimator(false)
    if ViewManager.Instance:IsOpenWindow(CollectionDetailsWindow) then
        mod.CollectionFacade:SendEvent(CollectionDetailsWindow.Event.ResetDetailsData, args.unitId)
    else
        ViewManager.Instance:OpenWindow(CollectionDetailsWindow, { id = args.unitId })
    end
end

function CollectionWindow:PlayEnterAnim()
    self:EnableAnimator(true)
    self.scrollCanvasGroup.interactable = false
    self.scrollCanvasGroup.blocksRaycasts = false
    self:PlayAnim("collection_window_enter",nil,self:ToFunc("OnEnterAnimCompleted"))
end

function CollectionWindow:ShowDetails(unitId)
    if not unitId then
        return
    end
    self:EnableAnimator(true)
    self.scrollCanvasGroup.interactable = false
    self.scrollCanvasGroup.blocksRaycasts = false
    self:PlayAnim("collection_window_turn",nil,self:ToFunc("OnTurnAnimCompleted"),{unitId = unitId})
end

function CollectionWindow:EnableAnimator(flag)
    if self.animator and self.animator.enabled ~= flag then
        self.animator.enabled = flag
    end
end