BattlePreInitCtrl = BaseClass("BattlePreInitCtrl",Controller)

function BattlePreInitCtrl:__Init()
    self.isBattleNode = false
end

function BattlePreInitCtrl:__InitCtrl()

end

function BattlePreInitCtrl:__InitComplete()
    EventManager.Instance:AddEvent(EventDefine.delay_preload_complete,self:ToFunc("DelayPreloadComplete"))
end

function BattlePreInitCtrl:DelayPreloadComplete()
    self:InitCamera()
end

function BattlePreInitCtrl:InitCamera()
    local camera = GDefine.mainCamera
    local cameraData = camera.gameObject:GetComponent(Rendering.Universal.UniversalAdditionalCameraData)

    if GDefine.platform == GDefine.PlatformType.WebGLPlayer then
        cameraData.renderPostProcessing = false
        cameraData.renderShadows = false
    else
        cameraData.renderPostProcessing = true
        cameraData.renderShadows = true
    end

    local volumeLayerMaskVal = 1
    --volumeLayerMaskVal = volumeLayerMaskVal + BitUtils.LShift(1,GDefine.Layer.layer7)
    local volumeLayerMask = LayerMask()
    volumeLayerMask.value = volumeLayerMaskVal
    cameraData.volumeLayerMask = volumeLayerMask

    local cullingMask = 1
    cullingMask = cullingMask + BitUtils.LShift(1,GDefine.Layer.layer6)
    cullingMask = cullingMask + BitUtils.LShift(1,GDefine.Layer.layer7)
    cullingMask = cullingMask + BitUtils.LShift(1,GDefine.Layer.layer8)
    camera.cullingMask = cullingMask


    camera.fieldOfView = 45


    local physicsRaycaster = camera.gameObject:AddComponent(PhysicsRaycaster)
    local eventMask = LayerMask()
    eventMask.value = BitUtils.LShift(1,GDefine.Layer.layer8)
    eventMask.value = eventMask.value + BitUtils.LShift(1,GDefine.Layer.layer10)
    physicsRaycaster.eventMask = eventMask


    local volume = camera.gameObject:AddComponent(Volume)
    volume.profile = PreloadManager.Instance:GetAsset(AssetPath.volumeProfile)


    local width = 720
    local height = 1280
    local ratio = (GDefine.curScreenHeight / GDefine.curScreenWidth) / (height / width)
    local adjust = Mathf.Max(45, ratio * 45)
    camera.fieldOfView  = adjust

    local cameraCurPos = camera.transform.localPosition
    local offsetZ = (14.6 / 45) * math.abs(adjust - 45) * 0.5
    BattleDefine.cameraPos.x = 0
    BattleDefine.cameraPos.y = 22.82
    BattleDefine.cameraPos.z = -14.6 + offsetZ
    BattleDefine.cameraOffsetZ = offsetZ
end

function BattlePreInitCtrl:SetMaskCameraActive(active)
    local maskCamera = BattleDefine.nodeObjs["camera/mask_camera"]
    if maskCamera then
        if active then
            maskCamera.gameObject:SetActive(true)
        else
            maskCamera.gameObject:SetActive(false)
        end
    end
end

function BattlePreInitCtrl:SetMaskPanelActive(active)
    local mask = BattleDefine.nodeObjs["mask_panel"]
    if mask then
        mask:SetActive(active)
    end
end