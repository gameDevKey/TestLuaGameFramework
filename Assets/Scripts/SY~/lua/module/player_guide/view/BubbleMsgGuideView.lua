BubbleMsgGuideView = BaseClass("BubbleMsgGuideView",BaseView)
BubbleMsgGuideView.Event = EventEnum.New(

)

function BubbleMsgGuideView:__Init()
    self:SetAsset("ui/prefab/player_guide/guide_bubble_box.prefab",AssetType.Prefab)
end

function BubbleMsgGuideView:__CacheObject()
    self.msgText = self:Find("msg",Text)
    self.imgBG = self:Find("img_bg",Image)
    self.arrowNode = self:Find("arrow").gameObject

    self.arrowChilds = {}
    local childNum = self.arrowNode.transform.childCount
    for i = 0, childNum-1 do
        local child = self.arrowNode.transform:GetChild(i)
        self.arrowChilds[tonumber(child.gameObject.name)] = child.gameObject
    end
end

function BubbleMsgGuideView:__Show()
    self:SetArrow()
    self:SetImageBG()
    self:SetText()
    self:SetSize()
end

function BubbleMsgGuideView:SetText()
    self.msgText.text = self.args.msg
    if self.args.textAlignCenter then
        self.msgText.alignment = TextAnchor.MiddleCenter
    else
        self.msgText.alignment = TextAnchor.MiddleLeft
    end
end

function BubbleMsgGuideView:SetArrow()
    local arrowDir = self.args.arrowDir
    if not arrowDir or arrowDir == 0 then
        self.arrowNode:SetActive(false)
    else
        for k,v in pairs(self.arrowChilds) do
            v:SetActive(k == arrowDir)
        end
    end
end

function BubbleMsgGuideView:SetImageBG()
    if self.args.imageKey then
        self.imgBG.gameObject:SetActive(true)
        self:SetSprite(self.imgBG, AssetPath.GetPlayerGuideIconPath(self.args.imageKey),false)
    else
        self.imgBG.gameObject:SetActive(false)
    end
end

function BubbleMsgGuideView:SetSize()
    if self.args.width and self.args.height then
        self.rectTrans:SetSizeDelata(self.args.width,self.args.height)
    else
        --没有配置宽高，让宽高等于图片原尺寸
        self.imgBG:SetNativeSize()
        UnityUtils.SetAnchorMinAndMax(self.imgBG.transform, 0.5,0.5,0.5,0.5)
        UnityUtils.SetPivot(self.imgBG.transform, 0.5,0.5)
    end
end