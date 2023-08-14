SystemDialog = StaticClass("SystemDialog")


function SystemDialog.Show(data)
    if data.notShowKey and mod.DialogProxy:HasNotShowDialogKey(data.notShowKey) then
        if data.onConfirm then
            data.onConfirm(data.args)
        end
    else
        if not mod.DialogProxy.systemDialogPanel then
            local systemDialogPanel = SystemDialogPanel.New()
            systemDialogPanel:SetParent(UIDefine.canvasRoot)
            mod.DialogProxy.systemDialogPanel = systemDialogPanel
        end
        mod.DialogProxy.systemDialogPanel:Show(data)
    end
end