BattleResultPerformView = BaseClass("BattleResultPerformView",ExtendView)

BattleResultPerformView.Event = EventEnum.New(
    "PlayResultPerform"
)

function BattleResultPerformView:__Init()
end

function BattleResultPerformView:__CacheObject()
    self.animRoot = self:Find("main/tips_node")
end

function BattleResultPerformView:__BindEvent()
    self:BindEvent(BattleResultPerformView.Event.PlayResultPerform)
end

function BattleResultPerformView:__Hide()
end

function BattleResultPerformView:PlayResultPerform()
    local winCamp = RunWorld.BattleStateSystem.winCamp

    local loseCamp = winCamp == BattleDefine.Camp.attack and BattleDefine.Camp.defence or BattleDefine.Camp.attack

    RunWorld.BattleMixedSystem:ShakeCamera(500 * 0.001, 400 * 0.001, 15, 90)
    --local roleData = self.world.BattleDataSystem:GetRoleData(self.world.BattleDataSystem.roleUid)

    local commanderEntity = RunWorld.EntitySystem:GetCommanderByCamp(loseCamp)
    commanderEntity.clientEntity.ClientAnimComponent:PlayAnim(BattleDefine.Anim.die)

    local pos = commanderEntity.TransformComponent:GetPos()
    RunWorld.BattleAssetsSystem:PlaySceneEffect(100007,pos.x,pos.y,pos.z)

    local effectId
    local isWin = RunWorld.BattleStateSystem:IsBattleResult(BattleDefine.BattleResult.win)
    if isWin then
        effectId = 10029
    else
        effectId = 10030
    end

    self:LoadUIEffect({
        confId = effectId,
        parent = self.animRoot,
        order = self:GetOrder() + 1,
        onComplete = self:ToFunc("PlayAnimFinish"),
    },true)
end

function BattleResultPerformView:PlayAnimFinish()
    RunWorld.BattleResultSystem:ResultPerformFinish()
end