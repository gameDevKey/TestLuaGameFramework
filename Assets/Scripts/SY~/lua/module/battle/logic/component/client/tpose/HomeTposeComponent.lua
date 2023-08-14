HomeTposeComponent = BaseClass("HomeTposeComponent",BaseTposeComponent)
HomeTposeComponent.NAME = "TposeComponent"

function HomeTposeComponent:__Init()
    
end

function HomeTposeComponent:__Delete()
    
end

function HomeTposeComponent:OnInit()
    -- local setting = {}
    -- setting.modelId = self.clientEntity.entity.ObjectDataComponent.unitConf.model_id
    -- setting.skinId = self.clientEntity.entity.ObjectDataComponent.unitConf.skin_id
    -- setting.animId = self.clientEntity.entity.ObjectDataComponent.unitConf.anim_id

    -- self.tpose = HomeTpose.New()
    -- self.tpose:Load(setting,self:ToFunc("OnTposeLoaded"))

    self:TposeComplete()
end

function HomeTposeComponent:OnTposeLoaded()
    local tposeTrans = self.clientEntity.ClientTransformComponent.transform:Find("tpose")

    BaseUtils.ChangeLayers(self.tpose.gameObject,GDefine.Layer.layer6)

	self.tpose.transform:SetParent(tposeTrans)
    self.tpose.transform:Reset()

    local scale = self.clientEntity.entity.ObjectDataComponent.unitConf.scale * 0.001
    self.tpose.transform:SetLocalScale(scale,scale,scale)
    --
    self:TposeComplete()
end