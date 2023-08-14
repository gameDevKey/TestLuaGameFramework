OpenFuncShowCtrl = BaseClass("OpenFuncShowCtrl",Controller)

function OpenFuncShowCtrl:__Init()
end

function OpenFuncShowCtrl:__Delete()
end

function OpenFuncShowCtrl:__InitComplete()
    EventManager.Instance:AddEvent(EventDefine.active_mainui, self:ToFunc("OnMainUIActive"))
end

function OpenFuncShowCtrl:InitDataComplete()
end

function OpenFuncShowCtrl:OnMainUIActive()
    if not TableUtils.IsEmpty(mod.OpenFuncProxy.toShowList) then
        ViewManager.Instance:OpenWindow(OpenFuncWindow,{showList = mod.OpenFuncProxy.toShowList})
    end
end