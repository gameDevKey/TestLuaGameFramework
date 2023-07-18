QuadTreeUtil = StaticClass("QuadTreeUtil")

--判断两矩形是否相交或包含
function QuadTreeUtil.IsIntersect(rect1,rect2)
    return not (
        rect1.x + rect1.width < rect2.x or
        rect1.y + rect1.height < rect2.y or
        rect2.x + rect2.width < rect1.x or
        rect2.y + rect2.height < rect1.y
    )
end

--返回两矩形相交的矩形
function QuadTreeUtil.GetIntersect(rect1,rect2)
    if not QuadTreeUtil.IsIntersect(rect1,rect2) then
        return nil
    end
    local x1 = math.max(rect1.x,rect2.x)
    local y1 = math.max(rect1.y,rect2.y)
    local x2 = math.min(rect1.x+rect1.width,rect2.x+rect2.width)
    local y2 = math.min(rect1.y+rect1.height,rect2.y+rect2.height)
    return QuadTreeUtil.CreateRect(x1, y1, x2 - x1, y2 - y1)
end

--创建矩形，左上角为原点
function QuadTreeUtil.CreateRect(x, y, width, height)
    return { width = width, height = height, x = x, y = y }
end

return QuadTreeUtil