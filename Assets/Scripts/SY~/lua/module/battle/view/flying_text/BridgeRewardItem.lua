BridgeRewardItem = BaseClass("BridgeRewardItem",BaseView)
BridgeRewardItem.poolKey = "bridge_reward_item"

function BridgeRewardItem:__Init()
    self.anim = nil
    self.imgPath = nil
    self.num = nil
end

function BridgeRewardItem:__Delete()
    self:RemoveAnim()
end

function BridgeRewardItem:__CacheObject()
    self.img = self:Find("img",Image)
    self.numText = self:Find("text",Text)
    self.canvasGroup = self:Find(nil,CanvasGroup)
end

function BridgeRewardItem:__Show()
    self:SetSprite(self.img,self.imgPath,true)
    self.numText.text = self.num
    self.canvasGroup.alpha = 0
    self.beginPos = self.rectTrans.anchoredPosition

    self:CreateAnim()
    self.anim:Play()
end

function BridgeRewardItem:__Hide()
    self:RemoveAnim()
end

function BridgeRewardItem:RemoveAnim()
    if self.anim then
        self.anim:Delete()
        self.anim = nil
    end
end

function BridgeRewardItem:CreateAnim()
    -- local anim1 = ToCanvasGroupAlphaAnim.New(self.canvasGroup,1,0.1)
    -- local anim2 = DelayAnim.New(0.5)

    -- local anim3 = ToCanvasGroupAlphaAnim.New(self.canvasGroup,0,0.5)
    -- local anim4 = MoveAnchorYAnim.New(self.transform,self.beginPos.y +20,0.1)

    -- local anim5 = ParallelAnim.New({anim3,anim4})

    -- self.anim = SequenceAnim.New({anim1,anim2,anim4})
    local anim1 = TweenCanvasGroupAlphaAnim.New(self.canvasGroup,255,0.3)
    local anim4 = TweenMoveAnchorAnim.New(self.transform,self.beginPos.y +50,0.3)
    self.anim = TweenSequenceAnim.New({anim1,anim4})

    self.anim:SetComplete(self:ToFunc("PlayAnimComplete"))
end

function BridgeRewardItem:PlayAnimComplete()
    mod.BattleFacade:SendEvent(BattleBridgeView.Event.FinishShowRewardItem,self)
end

function BridgeRewardItem:OnReset()
    self.imgPath = nil
    self.num = nil
    self:RemoveAnim()
end

function BridgeRewardItem.Create(args)
    local item = PoolManager.Instance:Pop(PoolType.base_view,BridgeRewardItem.poolKey)
    if not item then
        item = BridgeRewardItem.New()
        local template = BattleDefine.uiObjs["template/fly_text/bridge_reward"]
        item:SetObject(GameObject.Instantiate(template))
    end
    item.imgPath = args.imgPath
    item.num = args.num
    return item
end