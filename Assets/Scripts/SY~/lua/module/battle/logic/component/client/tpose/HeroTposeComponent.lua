HeroTposeComponent = BaseClass("HeroTposeComponent",BaseTposeComponent)
HeroTposeComponent.NAME = "TposeComponent"

function HeroTposeComponent:__Init()
    
end

function HeroTposeComponent:__Delete()
    if self.tpose then
        self.world.BattleAssetsSystem:CancelTpose(self.tpose)
        if self.tpose:IsComplete() then
            local key = string.format("%s_%s_%s",self.tpose.setting.modelId,self.tpose.setting.skinId,self.tpose.setting.animId)
            PoolManager.Instance:Push(PoolType.hero_tpose,key,self.tpose)
        else
            self.tpose:Delete()
        end

        self.tpose = nil
    end
end

function HeroTposeComponent:OnInit()
    local setting = {}
    setting.modelId = self.clientEntity.entity.ObjectDataComponent.unitConf.model_id
    setting.skinId = self.clientEntity.entity.ObjectDataComponent.unitConf.skin_id
    setting.animId = self.clientEntity.entity.ObjectDataComponent.unitConf.anim_id

    local key = string.format("%s_%s_%s",setting.modelId,setting.skinId,setting.animId)
    self.tpose = PoolManager.Instance:Pop(PoolType.hero_tpose,key)
    if self.tpose then
        self:OnTposeLoaded()
    else
        self.tpose = self.world.BattleAssetsSystem:AddRoleTpose(setting,self:ToFunc("OnTposeLoaded"))
        self.world.BattleAssetsSystem:LoadRoleTpose()
    end
end

function HeroTposeComponent:OnLateInit()
    local angle = self.world.BattleDataSystem.enterExtraData.selfCamp == BattleDefine.Camp.attack and 20 or -20
    self.clientEntity.ClientTransformComponent:SetRightAxis(angle)

    local radius = self.clientEntity.entity.CollistionComponent:GetRadius() * FPFloat.PrecisionFactor * 2
    local shadowTrans = self.clientEntity.ClientTransformComponent.transform:Find("shadow")
    shadowTrans.gameObject:SetActive(false)
    --shadowTrans:SetLocalScale(radius,radius,1)
end



function HeroTposeComponent:OnTposeLoaded()
    self.clientEntity.ClientAnimComponent:SetAnimator(self.tpose.animator)

    local tposeTrans = self.clientEntity.ClientTransformComponent.transform:Find("tpose")

    BaseUtils.ChangeLayers(self.tpose.gameObject,GDefine.Layer.layer6)

	self.tpose.transform:SetParent(tposeTrans)
    self.tpose.transform:Reset()

    local rotate = 0
    if self.clientEntity.entity.ObjectDataComponent.unitConf.is_rotate == 1 then
        rotate = 180
    end

    self.tpose.transform:SetLocalEulerAngles(0,rotate,0)--180是因为这个模型反了

    local scale = self.clientEntity.entity.ObjectDataComponent.unitConf.scale * 0.001
    self.tpose.transform:SetLocalScale(scale,scale,scale)
    --
    self:TposeComplete()
end