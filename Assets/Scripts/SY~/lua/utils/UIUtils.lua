UIUtils = UIUtils or {}

function UIUtils.SetFullSize(rectTrans)
    local width = Screen.width
    local height = Screen.height
    local designWidth = 1280
    local designHeight = 720
    local s1 = designWidth / designHeight
    local s2 = width / height

    if s1 < s2 then
        designWidth = math.floor(designHeight * s2)
    elseif s1 > s2 then
        designHeight =  math.floor(designWidth / s2)
    end

    UnityUtils.SetSizeDelata(rectTrans,designWidth,designHeight)
    local _, uiPos = RectTransformUtility.ScreenPointToLocalPointInRectangle(rectTrans, GDefine.screenCenter, UIDefine.uiCamera, 0)
    UnityUtils.SetAnchoredPosition(rectTrans,uiPos.x,uiPos.y)
end


function UIUtils.Adapt(root)
    if not GDefine.needAdapt then return end
    local pos = root.transform.anchoredPosition
    CustomUnityUtils.SetAnchoredPosition(root.transform,pos.x,pos.y + define.adaptOffset)
end

--设置特效的层次
--@effectObj  (GameObject)特效对象
--@sortingOrder 设置的层次
function UIUtils.SetEffectSortingOrder(effectObj, sortingOrder)
    local sortingOrder = sortingOrder or 1
    local renders = effectObj:GetComponentsInChildren(Renderer, true)
    for i = 0, renders.Length - 1 do
        renders[i].sortingOrder = sortingOrder
    end
end

function UIUtils.Grey(obj,flag)
    obj.grey = flag or false
end

function UIUtils.GetTextColorByQuality(str, quality, light)
    if light then
        -- 背景为浅色背景
        return string.format("<color=#%s>%s</color>", GDefine.QualityTextColorLight[quality], tostring(str))
    else
        return string.format("<color=#%s>%s</color>", GDefine.QualityTextColorDark[quality], tostring(str))
    end
end

-- text为文本;color为色号，带"#"
function UIUtils.GetColorText(text, color)
    return string.format("<color=%s>%s</color>",color,text)
end


function UIUtils.GetLocalPos(toTrans,fromTrans)
    local srcParent = UIDefine.calcPosNode.parent

    UIDefine.calcPosNode:SetParent(fromTrans)
    UIDefine.calcPosNode:SetAnchoredPosition(0,0)

    UIDefine.calcPosNode:SetParent(toTrans)

    local pos = UIDefine.calcPosNode.anchoredPosition

    UIDefine.calcPosNode:SetParent(srcParent)

    return pos
end

function UIUtils.ForceRebuildLayoutImmediate(root)
    local contentSizeFitters = root:GetComponentsInChildren(ContentSizeFitter,true)
    for i = 0, contentSizeFitters.Length - 1 do
        LayoutRebuilder.ForceRebuildLayoutImmediate(contentSizeFitters[i].gameObject:GetComponent(RectTransform))
    end
    Canvas.ForceUpdateCanvases()
end

function UIUtils.SetLayoutComponentEnable(root,flag)
    local layouts = root:GetComponentsInChildren(GridLayoutGroup,true)
    for i = 0, layouts.Length - 1 do
        layouts[i].enabled = flag
    end

    local layouts = root:GetComponentsInChildren(HorizontalLayoutGroup,true)
    for i = 0, layouts.Length - 1 do
        layouts[i].enabled = flag
    end

    local layouts = root:GetComponentsInChildren(VerticalLayoutGroup,true)
    for i = 0, layouts.Length - 1 do
        layouts[i].enabled = flag
    end
end

--自适应屏幕
function UIUtils.AdaptionScreen(rect)
    local minX = 0
    local maxX = GDefine.curScreenWidth - rect.rect.width
    local x = MathUtils.Clamp(rect.anchoredPosition.x, minX, maxX)

    local minY = - GDefine.curScreenHeight + rect.rect.height
    local maxY = 0
    local y = MathUtils.Clamp(rect.anchoredPosition.y, minY, maxY)

    UnityUtils.SetAnchoredPosition(rect.transform, x, y)
end

---返回胜率百分比字符串
---@param winCount integer 胜局数
---@param battleCount integer 总局数
---@param keepN integer|nil 保留多少位小数, 比如保留一位小数 0.99182 => 99.2%
---@return string rate 胜率，比如 99.2%
function UIUtils.GetWinrateText(winCount,battleCount,keepN)
    local winRate = 0
    if battleCount > 0 then
        keepN = (keepN or 0) + 2 --最终要显示百分比，默认保留位数+2
        winCount = MathUtils.Clamp(winCount, 0, battleCount)
        winRate = MathUtils.GetPreciseDecimal(winCount/battleCount, keepN) * 100
    end
    return tostring(winRate) .. "%"
end