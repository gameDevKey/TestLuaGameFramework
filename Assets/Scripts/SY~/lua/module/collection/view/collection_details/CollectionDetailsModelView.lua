CollectionDetailsModelView = BaseClass("CollectionDetailsModelView",ExtendView)

function CollectionDetailsModelView:__Init()
    self.modelTpose = nil
end

function CollectionDetailsModelView:__Delete()
    if self.modelTpose then
        self.modelTpose:Delete()
    end
end

function CollectionDetailsModelView:__CacheObject()
    self.modelCamera = self:Find("model_camera",Camera)
    self.modelParent = self:Find("main/stand_model_adaptation/stand_model")
end

function CollectionDetailsModelView:__Create()
    local cameraData = GDefine.mainCamera.gameObject:GetComponent(Rendering.Universal.UniversalAdditionalCameraData)
    cameraData.cameraStack:Insert(0, self.modelCamera)

    self.rightAxis = Quaternion.AngleAxis(20, Vector3.right)
    self.offsetRatio = 2

    local width = 720
    local height = 1280
    local scaleRatio = (GDefine.curScreenHeight / GDefine.curScreenWidth) / (height / width)
    self.modelScale = Mathf.Floor((200 / scaleRatio) + 0.5)

    local distance2Camera = 1000
    local fov = Mathf.Atan(Mathf.Abs(width / self.modelCamera.aspect * 0.5 / distance2Camera)) * Mathf.Rad2Deg * 2
    fov = Mathf.Floor(fov * 100+ 0.5) / 100
    self.modelCamera.fieldOfView = fov
end

function CollectionDetailsModelView:__BindListener()
end

function CollectionDetailsModelView:__BindEvent()
end

function CollectionDetailsModelView:__Hide()
end

function CollectionDetailsModelView:__Show()
end

function CollectionDetailsModelView:LoadModel(unitId)
    if self.modelTpose then
        self.modelTpose:Delete()
        self.modelTpose = nil
    end
    self.modelTpose = ViewModelTpose.New()
    self.modelTpose:Load({
        unitId = unitId,
        args = nil,
        parent = self.modelParent,
        onClick = self:ToFunc("OnModelClick"),
        onDrag = self:ToFunc("OnModelDrag"),
        layer = GDefine.Layer.layer10,
        -- eulerAngles = Vector3(0,0,0),
        scale = Vector3(self.modelScale,self.modelScale,self.modelScale),
    }
    ,self:ToFunc("OnModelLoaded"))
end

function CollectionDetailsModelView:OnModelLoaded()
    self:FixModelTransform()
    self:ModelLookAtCamera()

end

function CollectionDetailsModelView:FixModelTransform()
    local unitData = Config.UnitData.data_unit_info[self.modelTpose.setting.unitId]
    local showScale = unitData.show_scale or 1
    UnityUtils.SetLocalScale(self.modelTpose.transform,showScale,showScale,showScale)
    local offsetY = unitData.offset_y * self.offsetRatio
    local pos = self.modelTpose.transform.localPosition
    UnityUtils.SetLocalPosition(self.modelTpose.transform,pos.x,pos.y+offsetY,pos.z)
    -- self.modelTpose:SetBoxSize(Vector3(showScale,showScale,showScale), Vector3(0,offsetY,0))
    self.modelTpose:SetBoxSize(Vector3(1.2,1.2,1.2), Vector3(0,0.3,0))
end

function CollectionDetailsModelView:ModelLookAtCamera()
    self.modelTpose.transform:LookAt(self.modelCamera.transform)
    local angle = self.modelTpose.transform.localEulerAngles
    UnityUtils.SetLocalEulerAngles(self.modelTpose.transform,angle.x+10,angle.y,angle.z)
end

function CollectionDetailsModelView:OnModelClick(eventData,args)

end

function CollectionDetailsModelView:OnModelDrag(eventData,args)
    local delta = -eventData.deltaPos.x * 0.5
    self.modelTpose.transform:Rotate(0,delta,0)

    -- self.rotate = Quaternion.LookRotation(Vector3(0,0,-1000))
    -- local renderRotation = self.rightAxis * self.rotate
    -- self.modelTpose.transform:SetRotation(renderRotation.x, renderRotation.y, renderRotation.z,renderRotation.w)
end