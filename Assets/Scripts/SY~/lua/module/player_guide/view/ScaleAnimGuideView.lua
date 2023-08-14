ScaleAnimGuideView = BaseClass("ScaleAnimGuideView",BaseView)

function ScaleAnimGuideView:__Init()
    self:SetAsset("ui/prefab/player_guide/scale_anim_guide.prefab",AssetType.Prefab)
    self.tweenSpring = nil
    self.tweenScale = nil
    self.tweenFade = nil
end

function ScaleAnimGuideView:__CacheObject()
    self.image = self:Find("image",Image)
    self.canvasGroup = self.gameObject:GetComponent(CanvasGroup)
end

function ScaleAnimGuideView:__Create()
    if not self.canvasGroup then
        self.gameObject:AddComponent(CanvasGroup)
    end
end

function ScaleAnimGuideView:__Delete()
    self:StopAllTween()
    self.image = nil
end

function ScaleAnimGuideView:StopAllTween()
    local tween = {self.tweenFade, self.tweenSpring, self.tweenScale}
    for _, twn in ipairs(tween) do
        if twn then
            twn:Kill()
            twn = nil
        end
    end
end

function ScaleAnimGuideView:DoSpringAnim(rect,time,offset)
    if not rect then return end

    local startAlpha = offset > 0 and 0 or 1
    local targetAlpha = offset > 0 and 1 or 0
    self.canvasGroup.alpha = startAlpha
    self.tweenFade = self.canvasGroup:DOFade(targetAlpha,time)
    self.tweenFade:SetUpdate(true)
    self.tweenFade:SetLoops(-1,LoopType.Yoyo)

    local size = rect.sizeDelta
    local targetSize = Vector2(size.x+offset,size.y+offset)
    self.tweenSpring = rect:DOSizeDelta(targetSize,time)
    self.tweenSpring:SetUpdate(true)
    self.tweenSpring:SetLoops(-1,LoopType.Yoyo)
end

function ScaleAnimGuideView:__Show()
    self:SetImage()
end

function ScaleAnimGuideView:SetImage()
    local key = self.args.imageKey
    assert(key,"播放缩放动画前需要指定图片路径")
    local path = AssetPath.GetPlayerGuideIconPath(key)
    self:SetSprite(self.image,path,true,self:ToFunc("OnSetImageFinish"))
end

function ScaleAnimGuideView:OnSetImageFinish()
    self.canvasGroup.alpha = 1
    self.image.color = Color(255,255,255,255)
    self.image.type = Image.Type.Sliced
    local rect = self.image:GetComponent(RectTransform)
    local startSize = self.args.startSize
    startSize.x = startSize.x > 0 and startSize.x or Screen.width
    startSize.y = startSize.y > 0 and startSize.y or Screen.height
    UnityUtils.SetSizeDelata(rect,startSize.x,startSize.y)
    local targetSize = self.args.targetSize or {x=0,y=0}
    targetSize = Vector2(targetSize.x,targetSize.y)
    local time = self.args.time or 0.5
    self.tweenScale = rect:DOSizeDelta(targetSize,time)
    self.tweenScale:SetUpdate(true) --忽略Time.timeScale的影响，某些节点会控制Time.timeScale导致本节点失效

    local springInfo = self.args.springInfo
    if springInfo then
        self.tweenScale:OnComplete(function ()
            self:DoSpringAnim(rect, (springInfo.time or 1), (springInfo.offset or 10))
        end)
    end
end