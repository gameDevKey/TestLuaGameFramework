ImageBubbleMsgGuideView = BaseClass("ImageBubbleMsgGuideView",BaseView)
ImageBubbleMsgGuideView.Event = EventEnum.New(

)

function ImageBubbleMsgGuideView:__Init()
    self:SetAsset("ui/prefab/player_guide/guide_image_bubble_box.prefab",AssetType.Prefab)
end

function ImageBubbleMsgGuideView:__CacheObject()
    self.arrowNode = self:Find("arrow").gameObject
    self.msgNode = self:Find("msg").gameObject
    self.imgNode = self:Find("image").gameObject
    self.imgBG = self:Find("img_bg",Image)

    self.arrowChilds = {}
    local childNum = self.arrowNode.transform.childCount
    for i = 0, childNum-1 do
        local child = self.arrowNode.transform:GetChild(i)
        self.arrowChilds[tonumber(child.gameObject.name)] = child.gameObject
    end

    self.msgChilds = {}
    local childNum = self.msgNode.transform.childCount
    for i = 0, childNum-1 do
        local child = self.msgNode.transform:GetChild(i)
        local comp = child.gameObject:GetComponent(Text)
        comp.alignment = TextAnchor.UpperLeft
        table.insert(self.msgChilds, comp)
    end

    self.imgChilds = {}
    local childNum = self.imgNode.transform.childCount
    for i = 0, childNum-1 do
        local child = self.imgNode.transform:GetChild(i)
        table.insert(self.imgChilds, child.gameObject:GetComponent(Image))
    end
end

function ImageBubbleMsgGuideView:__Show()
    self:SetArrow()
    self:SetImageBG()
    self:SetImages()
    self:SetTexts()
    self:SetSize()
end

function ImageBubbleMsgGuideView:SetSize()
    if self.args.width and self.args.height then
        self.rectTrans:SetSizeDelata(self.args.width,self.args.height)
    else
        --没有配置宽高，让宽高等于图片原尺寸
        self.imgBG:SetNativeSize()
        UnityUtils.SetAnchorMinAndMax(self.imgBG.transform, 0.5,0.5,0.5,0.5)
        UnityUtils.SetPivot(self.imgBG.transform, 0.5,0.5)
    end
end

function ImageBubbleMsgGuideView:SetImageBG()
    if self.args.imageKey then
        self.imgBG.gameObject:SetActive(true)
        self:SetSprite(self.imgBG, AssetPath.GetPlayerGuideIconPath(self.args.imageKey),false)
    else
        self.imgBG.gameObject:SetActive(false)
    end
end

function ImageBubbleMsgGuideView:SetArrow()
    local arrowDir = self.args.arrowDir
    if not arrowDir or arrowDir == 0 then
        self.arrowNode:SetActive(false)
    else
        for k,v in pairs(self.arrowChilds) do
            v:SetActive(k == arrowDir)
        end
    end
end

local function GetComponentsFromCache(cacheTable, num)
    local list = {}
    local overnum = num
    for i, comp in ipairs(cacheTable or {}) do
        if i <= num then
            table.insert(list, comp)
            overnum = overnum - 1
            comp.gameObject:SetActive(true)
        else
            comp.gameObject:SetActive(false)
        end
    end
    -- TODO 组件不够用，是否需要实例化？
    -- for i = 1, overnum do
    -- end
    return list
end

function ImageBubbleMsgGuideView:SetImages()
    local images = self.args.images or {}
    local len = #images
    if len <= 0 then
        self.imgNode:SetActive(false)
        return
    end
    self.imgNode:SetActive(true)

    local comps = GetComponentsFromCache(self.imgChilds, len)
    for i, info in ipairs(images) do
        local img = info.name
        assert(img,string.format("气泡消息引导界面在设置第%d个图片时未指定图片路径",i))
        local pos = info.pos or {x=0,y=0}
        local width = info.width or 0
        local height = info.height or 0
        local com = comps[i]
        if com then
            local path = AssetPath.GetPlayerGuideIconPath(img)
            if width <= 0 or height <= 0 then
                self:SetSprite(com,path,true)
            else
                self:SetSprite(com,path,false)
                UnityUtils.SetSizeDelata(com.transform, width, height)
            end
            UnityUtils.SetAnchoredPosition(com.transform, pos.x, pos.y)
        end
    end
end

function ImageBubbleMsgGuideView:SetTexts()
    local texts = self.args.texts or {}
    local len = #texts
    if len <= 0 then
        self.msgNode:SetActive(false)
        return
    end
    self.msgNode:SetActive(true)

    local comps = GetComponentsFromCache(self.msgChilds, len)
    for i, info in ipairs(texts) do
        local pos = info.pos or {x=0,y=0}
        local width = info.width or 100
        local height = info.height or 100
        local com = comps[i]
        if com then
            com.text = info.msg
            com.lineSpacing = info.lineSpacing or 1
            UnityUtils.SetSizeDelata(com.transform, width, height)
            UnityUtils.SetAnchoredPosition(com.transform, pos.x, pos.y)
            if info.textAlignCenter then
                com.alignment = TextAnchor.MiddleCenter
            else
                com.alignment = TextAnchor.MiddleLeft
            end
        end
    end
end

function ImageBubbleMsgGuideView:SetPos(pos)
    if self:IsValid() then
        self.gameObject.transform.localPosition = pos
    end
end