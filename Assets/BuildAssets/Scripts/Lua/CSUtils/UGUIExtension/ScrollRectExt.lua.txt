ScrollRectExt = StaticClass("ScrollRectExt")

function ScrollRectExt.SetScroll(sr,callback)
    sr.onValueChanged:RemoveAllListeners()
    sr.onValueChanged:AddListener(callback)
end

return ScrollRectExt