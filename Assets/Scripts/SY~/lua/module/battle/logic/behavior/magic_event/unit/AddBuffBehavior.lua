AddBuffBehavior = BaseClass("AddBuffBehavior",MagicEventBehavior)

function AddBuffBehavior:__Init()
end

function AddBuffBehavior:__Delete()
end

function AddBuffBehavior:OnInit()
end

function AddBuffBehavior:OnDestroy()
end

function AddBuffBehavior:OnExecute()
    local from = self.event.from
    local actionArgs = self.event.conf.action_args
    local entity = self.world.EntitySystem:GetEntity(from.entityUid)
    if entity then
        for _,buffId in ipairs(actionArgs.buffId) do
            entity.BuffComponent:AddBuff(nil,buffId)
        end

        self.world.ClientIFacdeSystem:Call("SendEvent","BattlePveAttrView","RefreshAttr")
    end

    return true
end