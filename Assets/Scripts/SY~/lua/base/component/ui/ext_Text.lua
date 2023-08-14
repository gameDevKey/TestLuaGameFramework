-- 扩展Text方法
-- local base = getmetatable(Text)
-- local baseMetatable = getmetatable(base)
-- local color = {}

-- setmetatable(base, nil)

-- function base.create()
-- 	local text = GameObject():addComponent("Text")
-- 	text.raycastTarget = false
-- 	return text
-- end

-- function base.setAlign(self, textAnchor)
-- 	self.alignment = textAnchor;
-- 	self.rectTransform.pivot = Text.GetTextAnchorPivot(textAnchor);
-- end

-- function base.getColor(self)
-- 	local color = self.color
-- 	return color.r, color.g, color.b, color.a
-- end

-- function base.setColor(self, r, g, b, a)
-- 	color.r = r
-- 	color.g = g
-- 	color.b = b
-- 	color.a = a
-- 	self.color = color;
-- end

--local guiContent = GUIContent.New()
--local gstyle =  GUIStyle.New()

-- function base.calcWidthHeight(self,isSetsize)
-- 	isSetsize = isSetsize ~= false
-- 	gstyle.font = self.font;
-- 	gstyle.fontSize = self.fontSize;
-- 	gstyle.fontStyle = self.fontStyle;
-- 	guiContent.text = self.text;
-- 	local size = gstyle:CalcSize(guiContent)
-- 	if isSetsize then self:setSize(size.x, size.y + 3) end
-- 	return size.x,size.y+3
-- end

-- function base.setText(self, value, dontAutoSize, isCache)	
-- 	self.text = isCache and toStringCache(value) or value
-- 	if not dontAutoSize then
-- 		self:calcWidthHeight()
-- 	end
-- end

-- setmetatable(base, baseMetatable)


-------------------------
local base = xlua.getmetatable(Text)
local __baseindex = base.__index
local __extends = {}

--扩展
function __extends.SetColor(self,r, g, b, a)
    UnityUtils.SetTextColor(self,r,g,b,a)
end

--
base.__index = function(t,k)
	if __extends[k] then
		return __extends[k]
	else
		return __baseindex(t,k)
	end
end
xlua.setmetatable(Text, base)
