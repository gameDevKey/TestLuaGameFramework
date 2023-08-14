BattleClientIFacdeSystem = BaseClass("BattleClientIFacdeSystem",SECBClientEntitySystem)
BattleClientIFacdeSystem.NAME = "ClientIFacdeSystem"

function BattleClientIFacdeSystem:__Init()
end

function BattleClientIFacdeSystem:__Delete()

end

function BattleClientIFacdeSystem:OnInitSystem()
    
end

function BattleClientIFacdeSystem:OnLateInitSystem()
    
end

function BattleClientIFacdeSystem:Call(fn,...)
    if self.world.opts.isClient then
        return self[fn](self,...)
    end
end

function BattleClientIFacdeSystem:SendGuideEvent(className,event,...)
    mod.PlayerGuideEventCtrl:Trigger(_G[className]["Event"][event],...)
end

--向UI系统发送事件
function BattleClientIFacdeSystem:SendEvent(className,event,...)
    mod.BattleFacade:SendEvent(_G[className]["Event"][event],...)
end

function BattleClientIFacdeSystem:PlaySkillAudio(audioId)
    AudioManager.Instance:PlaySkill(audioId)
end

--实体同步位置
function BattleClientIFacdeSystem:EntitySyncPos(entityUid)
    local entity = self.world.EntitySystem:GetEntity(entityUid)
    if entity and entity.clientEntity.ClientTransformComponent then
        entity.clientEntity.ClientTransformComponent:SyncPos()
    end
end

--帧操作刷新英雄，通知UI刷新
function BattleClientIFacdeSystem:RefreshHeroGrid(roleUid)
    if roleUid == self.world.BattleDataSystem.roleUid then
        self.world.ClientIFacdeSystem:Call("SendEvent","BattleHeroGridView","RefreshHeroGrid")
    else
        self.world.ClientIFacdeSystem:Call("SendEvent","BattleEnemyGridView","RefreshEnemyHeroGrid",roleUid)
    end

    -- for i,v in ipairs(updateList) do
    --     if v.role_uid == roleUid then
    --         -- mod.BattleFacade:SendEvent(BattleHeroGridView.Event.RefreshHeroGrid)
    --         -- break
    --     else
    --         mod.BattleFacade:SendEvent(BattleEnemyGridView.Event.RefreshEnemyHeroGrid,v.role_uid) -- 把敌方的roleUid作为参数传递，方便读取敌方英雄信息
    --     end
    -- end

    -- if updateHeros then
    --     for i,infos in ipairs(updateHeros) do
    --         for _,v in ipairs(infos) do
    --             if v.roleUid == roleUid then
                        
    --             else
    --                 mod.BattleFacade:SendEvent(BattleEnemyGridView.Event.ActiveEnemyUnitStar,v.unitId,v.starOffset)
    --             end
    --         end
    --     end
    -- end
end

--帧操作选择英雄，通知UI刷新
function BattleClientIFacdeSystem:RefreshSelectHero(roleUid,units)
    mod.BattleFacade:SendEvent(BattleSelectHeroView.Event.RefreshSelectHero,units)
end

--刷新回合剩余时间
function BattleClientIFacdeSystem:RefreshGroupTime()
    local time = math.ceil((self.world.BattleGroupSystem.groupMaxTime - self.world.BattleGroupSystem.groupTime) / 1000)
    mod.BattleFacade:SendEvent(BattleInfoView.Event.RefreshNextRoundTime,time)
end

--显隐头顶UI
function BattleClientIFacdeSystem:ActiveEntityTop(entityUid,flag)
    local entity = self.world.EntitySystem:GetEntity(entityUid)
    if entity and entity.clientEntity.UIComponent.entityTop then
        entity.clientEntity.UIComponent.entityTop:ActiveHp(flag)
    end
end

--强制显隐头顶UI
function BattleClientIFacdeSystem:ForceActiveEntityTop(entityUid,flag)
    local entity = self.world.EntitySystem:GetEntity(entityUid)
    if entity and entity.clientEntity.UIComponent.entityTop then
        entity.clientEntity.UIComponent.entityTop:ForceActiveHP(flag)
    end
end

--强制显示头顶UI（锁）
function BattleClientIFacdeSystem:ForceShowHPByLock(entityUid,uid)
    local entity = self.world.EntitySystem:GetEntity(entityUid)
    if entity and entity.clientEntity.UIComponent.entityTop then
        entity.clientEntity.UIComponent.entityTop:ForceShowHPByLock(uid)
    end
end

--强制隐藏头顶UI（锁）
function BattleClientIFacdeSystem:ForceHideHPByLock(entityUid)
    local entity = self.world.EntitySystem:GetEntity(entityUid)
    if entity and entity.clientEntity.UIComponent.entityTop then
        return entity.clientEntity.UIComponent.entityTop:ForceHideHPByLock()
    end
end

--显隐头顶UI
function BattleClientIFacdeSystem:RefreshHp(entityUid)
    local entity = self.world.EntitySystem:GetEntity(entityUid)
    if entity and entity.clientEntity.UIComponent.entityTop then
        entity.clientEntity.UIComponent.entityTop:RefreshHp()
    end
end

--刷新能量
function BattleClientIFacdeSystem:RefreshEnergy(entityUid)
    local entity = self.world.EntitySystem:GetEntity(entityUid)
    if entity and entity.clientEntity.UIComponent.entityTop then
        entity.clientEntity.UIComponent.entityTop:RefreshEnergy()
    end
end

--刷新护盾
function BattleClientIFacdeSystem:RefreshShield(entityUid,val)
    local entity = self.world.EntitySystem:GetEntity(entityUid)
    if entity and entity.clientEntity.UIComponent.entityTop then
        entity.clientEntity.UIComponent.entityTop:RefreshShield(val)
    end
end

--设置动画时间缩放
function BattleClientIFacdeSystem:SetAnimTimeScale(entityUid,timeScale)
    local entity = self.world.EntitySystem:GetEntity(entityUid)
    if entity and entity.clientEntity.ClientAnimComponent then
        entity.clientEntity.ClientAnimComponent:SetTimeScale(timeScale)
    end
end

--动画添加暂停锁
function BattleClientIFacdeSystem:AnimAddPauseLockNum(entityUid,val)
    local entity = self.world.EntitySystem:GetEntity(entityUid)
    if entity and entity.clientEntity.ClientAnimComponent then
        entity.clientEntity.ClientAnimComponent:AddPauseLockNum(val)
    end
end


--设置动画时间缩放
function BattleClientIFacdeSystem:GetBoneTransInfo(entity,bone,customBone,offsetPos)
    local boneTrans,offsetY = nil,0
    if not entity.clientEntity.TposeComponent:ExistTpose() then
        boneTrans,_ = entity.clientEntity.TposeComponent:GetBone(GDefine.BoneName.origin)
        offsetY = 1
    else
        local bone = BaseUtils.GetBoneName(bone,customBone)
        boneTrans,flag = entity.clientEntity.TposeComponent:GetBone(bone)
        if not flag then offsetY = 1 end
    end

    local tempObj = BaseUtils.GetEmptyObject()

    tempObj.transform:SetParent(boneTrans)
    tempObj.transform:Reset()

    if offsetPos then
        local offsetX = offsetPos.x or 0
        local offsetY = offsetPos.y or 0
        local offsetZ = offsetPos.z or 0
        tempObj.transform:SetLocalPosition(offsetX * 0.001,offsetY * 0.001,offsetZ * 0.001)
    end

    tempObj.transform:SetParent(BattleDefine.nodeObjs["entity"],true)

    local pos = tempObj.transform.position
    local rotate = tempObj.transform.rotation

    BaseUtils.PushEmptyObject(tempObj)

    pos.y = pos.y + offsetY

    return pos,rotate
end


--显隐实体
function BattleClientIFacdeSystem:ActiveEntity(entityUid,flag)
    local entity = self.world.EntitySystem:GetEntity(entityUid)
    if entity and entity.clientEntity.ClientTransformComponent then
        entity.clientEntity.ClientTransformComponent:SetActive(flag)
    end
end

function BattleClientIFacdeSystem:SetEntityScale(entityUid,scale)
    local entity = self.world.EntitySystem:GetEntity(entityUid)
    if entity and entity.clientEntity.ClientTransformComponent then
        entity.clientEntity.ClientTransformComponent:SetScale(scale)
    end
end