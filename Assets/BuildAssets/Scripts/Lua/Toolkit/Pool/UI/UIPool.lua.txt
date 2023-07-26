UIPool = Class("UIPool",ComplexPoolBase)

function UIPool:OnInit()
end

function UIPool:OnDelete()
end

function UIPool:OnBeforeGet(obj)
end

function UIPool:OnAfterGet(obj)
end

function UIPool:OnBeforeRecycle(obj)
end

function UIPool:OnAfterRecycle(obj)
end

return UIPool