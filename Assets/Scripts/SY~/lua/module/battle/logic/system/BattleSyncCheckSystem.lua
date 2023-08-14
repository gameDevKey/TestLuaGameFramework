BattleSyncCheckSystem = BaseClass("BattleSyncCheckSystem",SECBEntitySystem)
BattleSyncCheckSystem.NAME = "SyncCheckSystem"

function BattleSyncCheckSystem:__Init()

end

function BattleSyncCheckSystem:__Delete()

end

function BattleSyncCheckSystem:OnInitSystem()

end

function BattleSyncCheckSystem:OnLateInitSystem()

end

function BattleSyncCheckSystem:Check()
    if self.world.EntitySystem.entityList.length ~= self.world.checkWorld.EntitySystem.entityList.length then
        assert(false,string.format("战斗出现差异[%s]",self.world.frame))
    end

    if not self.world.BattleStateSystem:IsBattleResult(BattleDefine.BattleResult.none) then
        return
    end

    for iter in self.world.EntitySystem.entityList:Items() do
        local uid = iter.value
        local entity = self.world.EntitySystem:GetEntity(uid)
        local checkEntity = self.world.checkWorld.EntitySystem:GetEntity(uid)
        
        if (entity and not checkEntity) or (not entity and checkEntity) then
            assert(false,string.format("战斗出现差异[%s]",self.world.frame))
        end

        self:CheckEntityTag(entity,checkEntity)
        self:CheckEntityHp(entity,checkEntity)
    end

    self:CheckCommander()
    self:CheckHome()
end

function BattleSyncCheckSystem:CheckEntityTag(entity1,entity2)
    if entity1.TagComponent.mainTag ~= entity2.TagComponent.mainTag 
        or entity1.TagComponent.subTag ~= entity2.TagComponent.subTag then
        assert(false,string.format("战斗出现差异[%s]",self.world.frame))
    end
end

function BattleSyncCheckSystem:CheckEntityHp(entity1,entity2)
    if entity1.AttrComponent then
        local hp = entity1.AttrComponent:GetValue(BattleDefine.Attr.hp)
        local checkHp = entity2.AttrComponent:GetValue(BattleDefine.Attr.hp)
        if hp ~= checkHp then
            assert(false,string.format("战斗出现差异[%s]",self.world.frame))
        end
    end
end

function BattleSyncCheckSystem:CheckCommander()
    for i,v in ipairs(self.world.BattleDataSystem.data.role_list) do
        local commanderInfo = self.world.BattleCommanderSystem:GetCommanderInfo(v.role_base.role_uid)
        local checkCommanderInfo = self.world.checkWorld.BattleCommanderSystem:GetCommanderInfo(v.role_base.role_uid)

        if commanderInfo.star ~= checkCommanderInfo.star or commanderInfo.exp ~= checkCommanderInfo.exp then
            assert(false,string.format("战斗出现差异[%s]",self.world.frame))
        end

        local money = self.world.BattleDataSystem:GetRoleMoney(v.role_base.role_uid)
        local checkMoney = self.world.checkWorld.BattleDataSystem:GetRoleMoney(v.role_base.role_uid)
        if money ~= checkMoney then
            assert(false,string.format("战斗出现差异[%s]",self.world.frame))
        end
    end
end

function BattleSyncCheckSystem:CheckHome()
    local defenceHomeUid = self.world.BattleDataSystem:GetHomeUid(BattleDefine.Camp.defence)
    local defenceHomeEntity = self.world.EntitySystem:GetEntity(defenceHomeUid)
    local defenceHomeHp = defenceHomeEntity.AttrComponent:GetValue(BattleDefine.Attr.hp)

    local checkDefenceHomeUid = self.world.checkWorld.BattleDataSystem:GetHomeUid(BattleDefine.Camp.defence)
    local checkDefenceHomeEntity = self.world.checkWorld.EntitySystem:GetEntity(checkDefenceHomeUid)
    local checkDefenceHomeHp = checkDefenceHomeEntity.AttrComponent:GetValue(BattleDefine.Attr.hp)

    if defenceHomeHp ~= checkDefenceHomeHp then
        assert(false,string.format("战斗出现差异[%s]",self.world.frame))
    end
end