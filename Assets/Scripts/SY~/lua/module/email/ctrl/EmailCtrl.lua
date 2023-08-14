EmailCtrl = BaseClass("EmailCtrl",Controller)

function EmailCtrl:__Init()
end

function EmailCtrl:OpenEmail()
    if not mod.OpenFuncProxy:JudgeFuncUnlockAndMsg(GDefine.FuncUnlockId.Email) then
        return
    end
    ViewManager.Instance:OpenWindow(EmailPanel)
end