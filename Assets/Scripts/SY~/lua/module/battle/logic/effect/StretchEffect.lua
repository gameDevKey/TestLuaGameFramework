StretchEffect = BaseClass("StretchEffect",EffectBase)
StretchEffect.poolKey = "battle_stretch_effect"

function StretchEffect:__Init()
    self.entity = nil
    self.targetEntityUid = nil
    self.waitTpose = false
    self.waitTargetTpose = false
end

function StretchEffect:__Delete()
    self:RemoveTposeListener()
    self:RemoveTargetTposeListener()
end

function StretchEffect:OnInit()
    self.entity = self.setting.entity
    if not self.entity then
        assert(self.entity,string.format("伸缩特效异常,没有设置播放实体[confId:%s][assetId:%s]",self.setting.confId,self.setting.assetId))
    end

    self.targetEntityUid = self.setting.targetEntityUid
    if not self.targetEntityUid then
        assert(self.targetEntityUid,string.format("伸缩特效异常,没有设置目标实体[confId:%s][assetId:%s]",self.setting.confId,self.setting.assetId))
    end

    local targetEntity = self.effectManager.world.EntitySystem:GetEntity(self.targetEntityUid).clientEntity

    self:SetParent(BattleDefine.nodeObjs["effect"])

    if not self.entity.TposeComponent:ExistTpose() then
        self.waitTpose = true
        self.entity.TposeComponent:AddTposeListener(self:ToFunc("BindEntityBone"))
    end

    if not targetEntity.TposeComponent:ExistTpose() then
        self.waitTargetTpose = true
        targetEntity.TposeComponent:AddTposeListener(self:ToFunc("TargetEntityBone"))
    end

    if self.waitTpose or self.waitTargetTpose then
        self:SetActive(false)
    end
    self:RefreshEffect()
end

function StretchEffect:BindEntityBone()
    self:RemoveTposeListener()
    self:CheckActiveEffect()
    self:RefreshEffect()
end

function StretchEffect:TargetEntityBone()
    self:RemoveTargetTposeListener()
    self:CheckActiveEffect()
    self:RefreshEffect()
end


function StretchEffect:CheckActiveEffect()
    if not self.waitTpose and not self.waitTargetTpose then
        self:SetActive(true)
    end
end

function StretchEffect:OnUpdate() 
    self:RefreshEffect()
end

function StretchEffect:RefreshEffect()
    if self.waitTpose or self.waitTargetTpose then
        return
    end

    local targetEntity = self.effectManager.world.EntitySystem:GetEntity(self.targetEntityUid)
    if not targetEntity then
        self:SetActive(false)
        return
    end

    local targetPos,_ = self.effectManager.world.ClientIFacdeSystem:Call("GetBoneTransInfo",targetEntity,GDefine.Bone.chest)

    local pos,_ = self.effectManager.world.ClientIFacdeSystem:Call("GetBoneTransInfo",self.entity.entity,self.conf.bone,self.conf.custom_bone,self.conf.offset_pos)

    local diff = targetPos - pos

    self:SetPos(pos.x,pos.y,pos.z)
    self.transform.forward = diff.normalized
    self.transform:SetLocalScale(1,1,diff.magnitude)
end

function StretchEffect:RemoveTposeListener()
    if self.waitTpose then
        self.waitTpose = false
        self.entity.TposeComponent:RemoveTposeListener(self:ToFunc("BindEntityBone"))
    end
end

function StretchEffect:RemoveTargetTposeListener()
    if self.waitTargetTpose then
        self.waitTargetTpose = false
        local targetEntity = self.effectManager.world.EntitySystem:GetEntity(self.targetEntityUid)
        if targetEntity and targetEntity.TposeComponent then
            targetEntity.TposeComponent:RemoveTposeListener(self:ToFunc("TargetEntityBone"))
        end
    end
end