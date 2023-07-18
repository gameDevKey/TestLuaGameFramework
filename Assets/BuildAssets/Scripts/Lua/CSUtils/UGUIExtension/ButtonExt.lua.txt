ButtonExt = StaticClass("ButtonExt")

function ButtonExt.SetClick(btn,callback)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(callback)
end

return ButtonExt