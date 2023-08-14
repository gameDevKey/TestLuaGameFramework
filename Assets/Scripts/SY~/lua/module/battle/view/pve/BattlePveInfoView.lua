BattlePveInfoView = BaseClass("BattlePveInfoView",ExtendView)

BattlePveInfoView.Event = EventEnum.New(
    "RefreshGroupShow",
    "RefreshTimeShow"
)

function BattlePveInfoView:__Init()
    self.enableSurrender = true
    self.onSurrender = nil
end

function BattlePveInfoView:__Delete()
    self.enableSurrender = true
    self.onSurrender = nil
end

function BattlePveInfoView:__CacheObject()
    self.txtGroup = self:Find("main/top_node/wave_bg/wave_text",Text)
    self.txtTime = self:Find("main/top_node/count_down_bg/count_down",Text)
    self.txtSync = self:Find("main/top_node/debug/sync_info",Text)
    self.btnExit = self:Find("main/top_node/wave_bg/return_btn/return_click",Button)
    self.txtName = self:Find("main/top_node/txt_lv_name",Text)
    self.txtTarget = self:Find("main/top_node/txt_lv_tips",Text)
end

function BattlePveInfoView:__BindListener()
    self.btnExit:SetClick(self:ToFunc("OnExitButtonClick"))
end

function BattlePveInfoView:__BindEvent()
    self:BindEvent(BattlePveInfoView.Event.RefreshGroupShow)
    self:BindEvent(BattlePveInfoView.Event.RefreshTimeShow)
    self:BindEvent(BattleFacade.Event.EnableSurrender)
    self:BindEvent(BattleFacade.Event.AddSurrenderCallback)
end

function BattlePveInfoView:__Create()
    self.txtSync.text = ""
end

function BattlePveInfoView:__Show()
    self.txtName.text = RunWorld.BattleGroupSystem.conf.name
    self.txtTarget.text = TI18N("获胜条件：杀死所有怪物")
end

function BattlePveInfoView:__Hide()
    self.enableSurrender = true
    self.onSurrender = nil
end

function BattlePveInfoView:Update()
   self:ShowDebugInfo()
end

function BattlePveInfoView:ShowDebugInfo()
    if not IS_DEBUG then
        return
    end
    local infos = {}
    table.insert(infos,string.format("[frame:%s, fps:%s]",RunWorld.frame,DevicesFpsManager.Instance.curFps))

    local sys = RunWorld.BattleGroupSystem
    if sys then
        local totalGen = 0
        for _, num in pairs(sys.genRecord) do
            totalGen = totalGen + num
        end
        if sys.groupConf then
            table.insert(infos, string.format("本波出怪数:%d/%d\t\t总出怪数:%d\t\t下一次出怪:%d/%d",
                totalGen,sys.groupConf.max_gen,sys.totalGen,sys.genTimer,sys.groupConf.gen_delta))
            table.insert(infos, string.format("本波击杀数:%d/%d\t总击杀数:%d",
                sys.killCounter,sys.groupConf.need_kill or -1,(sys.totalGen - sys.existCounter)))
            table.insert(infos, string.format("本波最多存活数:%d\t\t总存活数:%d",sys.groupConf.max_exist,sys.existCounter))
            -- table.insert(infos, string.format("本次生成:%d 本波最多生成:%d 本次可生成:%d",sys.groupConf.per_gen,sys.groupConf.max_gen,sys:CalcPerGenNum()))
            local exTips = ""
            if sys.isWaitForSkillSelect then
                exTips = "正在技能三选一, 暂停计时"
            elseif sys.isSpeicalTipsShowing then
                exTips = "正在显示特殊波数提示, 暂停计时"
            end
            table.insert(infos, string.format("距离下一波:%d/%d\t\t%s",sys.groupTimer,sys.groupConf.max_time,exTips))
        end
    end

    self.txtSync.text = table.concat(infos,"\n")
end

function BattlePveInfoView:RefreshGroupShow(group,maxGroup)
    self.txtGroup.text = string.format("%s:%d/%d",TI18N("当前波数"),group,maxGroup)
end

function BattlePveInfoView:RefreshTimeShow(frame)
    local sec = math.floor(frame / 1000)
    self.txtTime.text = TimeUtils.GetMinSecTime(sec)
end

function BattlePveInfoView:OnExitButtonClick()
    if self.enableSurrender then
        RunWorld.BattleResultSystem:Surrender()
    end
    if self.onSurrender then
        self.onSurrender(self.enableSurrender)
    end
end

function BattlePveInfoView:EnableSurrender(flag)
    self.enableSurrender = flag
end

function BattlePveInfoView:AddSurrenderCallback(callback)
    self.onSurrender = callback
end