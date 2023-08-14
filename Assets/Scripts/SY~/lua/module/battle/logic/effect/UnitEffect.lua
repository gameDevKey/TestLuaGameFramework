UnitEffect = BaseClass("UnitEffect",EffectBase)
UnitEffect.poolKey = "battle_unit_effect"

function UnitEffect:__Init()
    self.entity = nil
    self.waitTpose = false
    self.boneName = nil
end

function UnitEffect:__Delete()
    self:RemoveTposeListener()
end

function UnitEffect:OnInit()
    self.entity = self.setting.entity
    if not self.entity then
        assert(false,string.format("单位特效异常,没有设置播放单位[confId:%s][assetId:%s]",self.setting.confId,self.setting.assetId))
    end

    local bone = self.conf.bone
    self.boneName = BaseUtils.GetBoneName(bone,self.conf.custom_bone)

    --root,forward不用等加载tpose
    if bone == GDefine.Bone.root or bone == GDefine.Bone.origin then
        self:BindBone()
    elseif self.entity.TposeComponent:ExistTpose() then
        self:BindBone()
    else
        self.waitTpose = true
        self:SetParent(BattleDefine.nodeObjs["effect"])
        self:SetActive(false)
        self.entity.TposeComponent:AddTposeListener(self:ToFunc("BindBone"))
    end
end

function UnitEffect:BindBone()
    self:SetActive(true)
    
    self:RemoveTposeListener()
    
    local boneTrans,_ = self.entity.TposeComponent:GetBone(self.boneName)
    self:SetParent(boneTrans)

    if self.conf.break_bone == 1 then
        self.transform:SetParent(self.entity.ClientTransformComponent.transform)
    end

    --BaseTposeComponent:RemoveTposeListener(callBack)
    --if self.notEffectRotate then UnityUtils.SetLocalEulerAngles(self.transform,0,self.transform.localEulerAngles.y,0) end
    -- if self.entity.configScale ~= 1 then
    --     local scale = 1 / self.entity.configScale
    --     UnityUtils.SetLocalScale(self.transform,scale,scale,scale)
    -- end
end

function UnitEffect:RemoveTposeListener()
    if self.waitTpose then
        self.waitTpose = false
        self.entity.TposeComponent:RemoveTposeListener(self:ToFunc("BindBone"))
    end
end