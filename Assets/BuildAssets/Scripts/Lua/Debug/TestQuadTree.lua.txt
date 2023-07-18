local quadTree = QuadTree.New({ maxDepth = 100, capcity = 1, depth = 0, rect = { width = 100, height = 200, x = 0, y = 0 } })

quadTree:Insert({ width = 10, height = 10, x = 10, y = 20, data = "A1" })
quadTree:Insert({ width = 30, height = 20, x = 40, y = 60, data = "B1" })

quadTree:Log()

local targets = quadTree:Find({ width = 100, height = 100, x = 0, y = 0 })
PrintLog("查找结果", targets)

--一个角相交
local rect1 = { width = 10, height = 10, x = 0, y = 0 }
local rect2 = { width = 10, height = 10, x = 5, y = 5 }
print(QuadTreeUtil.IsIntersect(rect1, rect2))
PrintLog(QuadTreeUtil.GetIntersect(rect1, rect2))

--包含
local rect1 = { width = 10, height = 10, x = 0, y = 0 }
local rect2 = { width = 5, height = 5, x = 3, y = 2 }
print(QuadTreeUtil.IsIntersect(rect1, rect2))
PrintLog(QuadTreeUtil.GetIntersect(rect1, rect2))

--十字相交
local rect1 = { width = 10, height = 30, x = 5, y = 0 }
local rect2 = { width = 20, height = 10, x = 0, y = 10 }
print(QuadTreeUtil.IsIntersect(rect1, rect2))
PrintLog(QuadTreeUtil.GetIntersect(rect1, rect2))

--不相交
local rect1 = { width = 10, height = 30, x = 0, y = 0 }
local rect2 = { width = 20, height = 10, x = 15, y = 10 }
print(QuadTreeUtil.IsIntersect(rect1, rect2))
PrintLog(QuadTreeUtil.GetIntersect(rect1, rect2))
