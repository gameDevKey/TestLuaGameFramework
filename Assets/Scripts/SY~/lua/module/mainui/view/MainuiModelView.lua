MainuiModelView = BaseClass("MainuiModelView",ExtendView)
MainuiModelView.Event = EventEnum.New(
    "LoadModels",
    "ActiveCamera",
    "RefreshCardModels",
    "MoveCameraToNeer",
    "MoveCameraToFar"
)

function MainuiModelView:__Init()
end

function MainuiModelView:__CacheObject()
    self.camera = self:Find("model_camera",Camera)
    self.rectCamera = self.camera.gameObject:GetComponent(RectTransform)
    local cameraData = GDefine.mainCamera.gameObject:GetComponent(Rendering.Universal.UniversalAdditionalCameraData)
    cameraData.cameraStack:Insert(0,self.camera)

    self.modelParent = {}
    for i = 1, 8 do
        self.modelParent[i] = self:Find("scene/pos_"..i)
    end
    self.modelTposes = {}
end

function MainuiModelView:__Create()
    self.rightAxis = Quaternion.AngleAxis(20, Vector3.right)

    self.farPos = Vector3(0,-343,-1622)
    self.neerPos = Vector3(0,0,-1300)

    self.cameraTween = nil
end

function MainuiModelView:__BindListener()
end

function MainuiModelView:__BindEvent()
    self:BindEvent(MainuiModelView.Event.LoadModels)
    self:BindEvent(MainuiModelView.Event.ActiveCamera)
    self:BindEvent(MainuiModelView.Event.RefreshCardModels)
    self:BindEvent(MainuiModelView.Event.MoveCameraToNeer)
    self:BindEvent(MainuiModelView.Event.MoveCameraToFar)
end

function MainuiModelView:__Hide()
    if self.cameraTween then
        self.cameraTween:Delete()
        self.cameraTween = nil
    end
end

function MainuiModelView:__Show()
    self:MoveCameraTo(self.neerPos, self:ToFunc("MakeAllModelLookAtCamera"))
    self:RefreshCardModels()
end

function MainuiModelView:RefreshCardModels()
    local data = mod.CollectionProxy:GetEmbattleGroupData()
    self:LoadModels(data.embattleGroupData)
end

--[[
    data = {
        {
  	  	  	group_id = 1, 
  	  	  	slot = 1, 
  	  	  	unit_id = 10091
  	  	}, 
        ...
    }
]]--
function MainuiModelView:LoadModels(data)
    -- LogYqh("出战卡组",data)
    for _, sc in ipairs(data) do
        local parent = self.modelParent[sc.slot]
        if self.modelTposes[sc.slot] then
            self.modelTposes[sc.slot]:Delete()
            self.modelTposes[sc.slot] = nil
        end
        self.modelTposes[sc.slot] = ViewModelTpose.New()
        self.modelTposes[sc.slot]:Load({
            unitId = sc.unit_id,
            args = sc,
            parent = parent,
            onClick = self:ToFunc("OnModelClick"),
            onDrag = self:ToFunc("OnModelDrag"),
            layer = GDefine.Layer.layer10,
            -- eulerAngles = Vector3(0,0,0),
            scale = Vector3(100,100,100),
        }
        ,self:ToFunc("OnModelLoaded"))
    end
end

function MainuiModelView:MoveCameraTo(vec3,callback)
    if self.cameraTween then
        self.cameraTween:Delete()
    end
    self.cameraTween = MoveAnchor3dAnim.New(self.rectCamera, vec3, 0.3)
    self.cameraTween:SetComplete(self:ToFunc("OnMoveCameraFinish"),{
        callback = callback
    })
    self.cameraTween:Play()
end

function MainuiModelView:MoveCameraToNeer(callback)
    self:MoveCameraTo(self.neerPos,callback)
end

function MainuiModelView:MoveCameraToFar(callback)
    self:MoveCameraTo(self.farPos,callback)
end

function MainuiModelView:OnMoveCameraFinish(args)
    self.cameraTween = nil
    if args and args.callback then
        args.callback()
    end
end

function MainuiModelView:MakeAllModelLookAtCamera()
    for _, tpose in pairs(self.modelTposes) do
        if tpose:IsComplete() then
            self:ModelLookAtCamera(tpose)
        end
    end
end

function MainuiModelView:ModelLookAtCamera(tpose)
    tpose.transform:LookAt(self.camera.transform)
    local angle = tpose.transform.localEulerAngles
    UnityUtils.SetLocalEulerAngles(tpose.transform,angle.x+10,angle.y,angle.z)
end

function MainuiModelView:FixModelTransform(tpose)
    local unitData = Config.UnitData.data_unit_info[tpose.setting.unitId]
    local showScale = unitData.show_scale or 1
    UnityUtils.SetLocalScale(tpose.transform,showScale,showScale,showScale)
    local offsetY = unitData.offset_y
    local pos = tpose.transform.localPosition
    UnityUtils.SetLocalPosition(tpose.transform,pos.x,pos.y+offsetY,pos.z)
    -- tpose:SetBoxSize(Vector3(showScale,showScale,showScale), Vector3(0,offsetY,0))
    tpose:SetBoxSize(Vector3(1.2,1.2,1.2), Vector3(0,0.3,0))
end

function MainuiModelView:OnModelLoaded(tpose,args)
    -- LogYqh("模型加载成功",args)
    self:FixModelTransform(tpose)
    self:ModelLookAtCamera(tpose)

    -- local renderRotation = self.rightAxis and self.rightAxis * self.rotation or self.rotation
    -- self.tposeTrans:SetRotation(renderRotation.x, renderRotation.y, renderRotation.z,renderRotation.w)

    -- self.rotate = Quaternion.LookRotation(0,0,-1000)
    -- local renderRotation = self.rightAxis * self.rotate
    -- tpose.transform:SetRotation(renderRotation.x, renderRotation.y, renderRotation.z,renderRotation.w)
end

function MainuiModelView:OnModelClick(eventData,args)
    -- LogYqh("模型被点击",args)
    local tpose = self.modelTposes[args.args.slot]
    local viewData = {
        data = args.args,
        camera = self.camera,
        tpose = tpose
    }
    if ViewManager.Instance:IsOpenWindow(FastConfigCardPanel) then
        mod.MainuiFacade:SendEvent(FastConfigCardPanel.Event.ReOpen, viewData)
    else
        ViewManager.Instance:OpenWindow(FastConfigCardPanel, viewData)
    end
end

function MainuiModelView:OnModelDrag(eventData,args)
    -- LogYqh("模型被拖拽",eventData,args)

    --暂时屏蔽
    -- local tpose = self.modelTposes[args.args.slot]
    -- local delta = -eventData.deltaPos.x * 5
    -- tpose.transform:Rotate(0,delta,0)

    -- self.rotate = Quaternion.LookRotation(0,0,-1000)
    -- local renderRotation = self.rightAxis * self.rotate
    -- tpose.transform:SetRotation(renderRotation.x, renderRotation.y, renderRotation.z,renderRotation.w)
end

function MainuiModelView:ActiveCamera(active)
    self.camera.enabled = active
end