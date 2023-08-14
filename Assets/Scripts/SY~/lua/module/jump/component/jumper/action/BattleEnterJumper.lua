BattleEnterJumper = BaseClass("BattleEnterJumper",JumperBase)

function BattleEnterJumper:__Init()

end

function BattleEnterJumper:__Delete()

end

function BattleEnterJumper:OnStart()
    mod.MainuiFacade:SendEvent(MainuiBottomBtnPanel.Event.SwitchTab,3)

    if self.info.mode == 1 then
        local obj = UIDefine.canvasRoot:Find("MainuiPanel/view/MainuiPanel/main/enter_battle_btn").gameObject
        CustomUnityUtils.PointerClickHandler(obj,PointerEventData(EventSystem.current))
    elseif self.info.mode == 2 then
        -- local obj = UIDefine.canvasRoot:Find("MainuiPanel/view/MainuiPanel/main/enter_pve_btn").gameObject
        -- CustomUnityUtils.PointerClickHandler(obj,PointerEventData(EventSystem.current))
    end
    
    self:Destroy()
end