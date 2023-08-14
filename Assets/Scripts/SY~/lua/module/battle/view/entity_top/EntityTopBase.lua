EntityTopBase = BaseClass("EntityTopBase",BaseView)

function EntityTopBase:__Init()
    self.clientEntity = nil
    self.isShow = nil

    self.offsetY = 0.0

    self.lastFlyTime = 0
    self.lastFrame = 0
    self.frameFlyNum = 0
    self.curPos = nil
end

function EntityTopBase:__Delete()

end

function EntityTopBase:SetClientEntity(clientEntity)
    self.clientEntity = clientEntity
end

function EntityTopBase:RefreshPos()
    self.curPos = self:GetEntityPos()
    self.curPos.y = self.curPos.y + self.offsetY
    UnityUtils.SetAnchoredPosition(self.transform,self.curPos.x,self.curPos.y)
end

function EntityTopBase:GetPos()
    return self.curPos
end

function EntityTopBase:GetEntityPos()
    local entityPos = self.clientEntity.ClientTransformComponent:GetPos()

    local conf = self.clientEntity.entity.ObjectDataComponent.unitConf
    local y = entityPos.y + (conf.model_height * 0.001 *  (conf.scale * 0.001))

    local pos = BaseUtils.WorldToUIPoint(BattleDefine.nodeObjs["main_camera"],Vector3(entityPos.x,y,entityPos.z))
    return pos
end

function EntityTopBase:GetFlyTextPos()
    local pos = self:GetEntityPos()

    if Time.frameCount - self.lastFrame > 30 or self.frameFlyNum >= 5 then
        self.lastFrame = Time.frameCount
        self.frameFlyNum = 1
    else
        self.frameFlyNum = self.frameFlyNum + 1
        local offsetY = (self.frameFlyNum - 1) * 8
        pos.y = pos.y - offsetY
    end

    return pos
end

function EntityTopBase:ResetData()
    self.isShow = nil
    self.gameObject:SetActive(true)
    self.lastFlyTime = Time.time
    self.lastFrame = 0
    self.frameFlyNum = 0
end


--虚函数
function EntityTopBase:ActiveHp() end
function EntityTopBase:ForceActiveHP() end
function EntityTopBase:ForceShowHPByLock() end
function EntityTopBase:ForceHideHPByLock() end
function EntityTopBase:RefreshHp() end
function EntityTopBase:RefreshEnergy() end
function EntityTopBase:RefreshShield() end