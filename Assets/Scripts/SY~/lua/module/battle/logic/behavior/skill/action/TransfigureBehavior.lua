TransfigureBehavior = BaseClass("TransfigureBehavior",SkillBehavior)

function TransfigureBehavior:__Init()
    self.ownerEntity = nil
    self.effectUids = {}

    self.transfigureTime = 0
    self.castTime = 0
    self.castComplete = false
    self.lastTime = 0

    self.maxEnergy = 0

end

function TransfigureBehavior:__Delete()
end

function TransfigureBehavior:OnInit()
    self.skill:AddRefNum(1)

    self.ownerEntity = self.world.EntitySystem:GetEntity(self.entity.ownerUid)
    if not self.ownerEntity then
        self:SetRemove(true)
    end

    self.maxEnergy = self.ownerEntity.AttrComponent:GetValue(GDefine.Attr.max_energy)
    self:InitTimeNode()
    self:InitTempTposeSetting()
end

function TransfigureBehavior:InitTimeNode()
    self.castTime = self.actionParam.castTime
    self.lastTime = self.actionParam.lastTime
end

function TransfigureBehavior:InitTempTposeSetting()
    if not self.world.opts.isClient then
        return
    end
    local setting = {}
    setting.modelId = self.actionParam.modelId
    setting.skinId = self.actionParam.skinId
    setting.animId = self.actionParam.animId

    local key = string.format("%s_%s_%s",setting.modelId,setting.skinId,setting.animId)
    self.tempTpose = PoolManager.Instance:Pop(PoolType.hero_tpose,key)
    if self.tempTpose then
        self.ownerEntity.clientEntity.TposeComponent:SetTempTposeComplete(true)
        self:OnTposeLoaded()
    else
        self.ownerEntity.clientEntity.TposeComponent:SetTempTposeComplete(false)
        self.tempTpose = self.world.BattleAssetsSystem:AddRoleTpose(setting,self:ToFunc("OnTposeLoaded"))
        self.world.BattleAssetsSystem:LoadRoleTpose()
    end
end

function TransfigureBehavior:OnTposeLoaded()
    self.ownerEntity.clientEntity.TposeComponent:SetTempTpose(self.tempTpose)
    self.ownerEntity.clientEntity.TposeComponent:SetTempTposeComplete(true)
    self.ownerEntity.clientEntity.ClientAnimComponent:SetTempAnimator(self.tempTpose.animator)

    local tposeTrans = self.ownerEntity.clientEntity.ClientTransformComponent.transform:Find("tpose")

    BaseUtils.ChangeLayers(self.tempTpose.gameObject,GDefine.Layer.layer6)

	self.tempTpose.transform:SetParent(tposeTrans)
    self.tempTpose.transform:Reset()
    self.tempTpose.gameObject:SetActive(false)

    local rotate = 0
    if self.actionParam.isRotate == 1 then
        rotate = 180
    end

    self.tempTpose.transform:SetLocalEulerAngles(0,rotate,0)--180是因为这个模型反了

    local scale = self.actionParam.scale * 0.001
    self.tempTpose.transform:SetLocalScale(scale,scale,scale)
    --
end

function TransfigureBehavior:OnUpdate()
    local ownerEntity = self.world.EntitySystem:GetEntity(self.entity.ownerUid)

    if not ownerEntity then
        self:SetRemove(true)
        return
    end

    self.ownerEntity = ownerEntity

    if not self.castComplete and self.transfigureTime >= self.castTime then
        self:OnCastTimeComplete()
    end
    self.transfigureTime = self.transfigureTime + self.world.opts.frameDeltaTime
    self:SetEnergy()
    if self.transfigureTime >= self.lastTime then
        self:OnTransfigureEnd()
    end
end

function TransfigureBehavior:OnCastTimeComplete()
    self.castComplete = true
    self.transfigureTime = self.transfigureTime - self.castTime

    if self.ownerEntity.clientEntity then
        self.ownerEntity.clientEntity.TposeComponent:ShowTpose()
        self.ownerEntity.clientEntity.EffectComponent:SetEffectHook(self:ToFunc("OnEffectHook"))
    end

    self:SetAllSkillEnable(false)
    self:AddNewSkillList()

    self.ownerEntity.BuffComponent:RefreshBuffEffect()
end

function TransfigureBehavior:SetAllSkillEnable(flag)
    for _, skill in ipairs(self.ownerEntity.SkillComponent.actSkills) do
        skill:SetEnable(flag)
    end

    for _, skill in ipairs(self.ownerEntity.SkillComponent.pasvSkills) do
        skill:SetEnable(flag)
    end
end

function TransfigureBehavior:AddNewSkillList()
    self.newSkillList = self.actionParam.skillList
    for _, skillInfo in ipairs(self.newSkillList) do
        self.ownerEntity.SkillComponent:AddSkill(skillInfo[1],skillInfo[2])
    end
end

function TransfigureBehavior:SetEnergy()
    if not self.castComplete then
        return
    end

    local val = FPMath.Divide(self.maxEnergy * (self.lastTime - self.transfigureTime), self.lastTime)
    val = val >= 0 and val or 0
    self.ownerEntity.AttrComponent:SetValue(BattleDefine.Attr.energy,val)
end

function TransfigureBehavior:OnTransfigureEnd()
    if self.ownerEntity.clientEntity then
        self.ownerEntity.clientEntity.EffectComponent:SetEffectHook(nil)
        self:CleanEffects()
        self.ownerEntity.clientEntity.TposeComponent:SetTempTpose(nil)
        self.ownerEntity.clientEntity.TposeComponent:SetTempTposeComplete(nil)
        self.ownerEntity.clientEntity.TposeComponent:ShowTpose()

        self.ownerEntity.clientEntity.ClientAnimComponent:SetTempAnimator(nil)

    end

    self:RestoreSkillList()

    self.ownerEntity.BuffComponent:RefreshBuffEffect()


    self:SetRemove(true)
end

function TransfigureBehavior:RestoreSkillList()
    for _, skillInfo in ipairs(self.newSkillList) do
        self.ownerEntity.SkillComponent:RemoveSKillById(skillInfo[1])
    end
    self:SetAllSkillEnable(true)
end

function TransfigureBehavior:OnEffectHook(effectUid)
    table.insert(self.effectUids, effectUid)
end

function TransfigureBehavior:CleanEffects()
    for _, effectUid in ipairs(self.effectUids) do
        self.world.BattleAssetsSystem:RemoveEffect(effectUid)
    end
end