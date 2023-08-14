PveResultPerformView = BaseClass("PveResultPerformView",ExtendView)

PveResultPerformView.Event = EventEnum.New(
    "PlayPveResultPerform"
)

function PveResultPerformView:__Init()
end

function PveResultPerformView:__CacheObject()
    self.animRoot = self:Find("main/tips_node")
end

function PveResultPerformView:__BindEvent()
    self:BindEvent(PveResultPerformView.Event.PlayPveResultPerform)
end

function PveResultPerformView:__Hide()
end

function PveResultPerformView:PlayPveResultPerform()
    local winCamp = RunWorld.BattleStateSystem.winCamp

    local isWin = winCamp == BattleDefine.Camp.defence
    local effectId

    if isWin then
        effectId = 10034
    else
        effectId = 10035
        local commanderEntity = RunWorld.EntitySystem:GetCommanderByCamp(BattleDefine.Camp.defence)
        commanderEntity.clientEntity.ClientAnimComponent:PlayAnim(BattleDefine.Anim.die)
    end

    self:LoadUIEffect({
        confId = effectId,
        parent = self.animRoot,
        order = self:GetOrder() + 1,
        onComplete = self:ToFunc("PlayAnimFinish"),
    },true)
end

function PveResultPerformView:PlayAnimFinish()
    RunWorld.BattleResultSystem:ResultPerformFinish()
end