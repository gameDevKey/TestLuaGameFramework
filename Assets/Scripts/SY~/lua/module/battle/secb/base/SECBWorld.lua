SECBWorld = BaseClass("SECBWorld")

function SECBWorld:__Init(opts)
    self.worldType = nil
    self.frame = 0
    self.frameTime = 0
    self.lerpTime = 0
    self.time = 0
    self.opts = opts
    self.systems = {}
    self.clientWorld = nil
    self.uuids = {}

    self.uid = 0

    self.checkWorld = nil
    self.onCheckWorld = nil

    self.runError = false

    self:InitSystem()
    self:InitClientWorld()
end

function SECBWorld:__Delete()
end

function SECBWorld:SetUid(uid)
    self.uid = uid
end

function SECBWorld:SetWorldType(worldType)
    self.worldType = worldType
end

function SECBWorld:SetRunError(flag)
    self.runError = flag
end

function SECBWorld:InitSystem()
    self:OnInitSystem()
    for _,v in ipairs(self.systems) do
        v:OnLateInitSystem()
    end
end

function SECBWorld:InitClientWorld()
    if self.opts.isClient then
        self.clientWorld = self.opts.clientWorldType.New(self)
    end
end

function SECBWorld:AddSystem(systemType)
    local name = systemType.NAME or systemType.__className
    local system = systemType.New()
    system:SetWorld(self)
    system:OnInitSystem()
    self[name] = system
    table.insert(self.systems,system)
end

function SECBWorld:UpdateFrame(deltaTime)
    local deltaTime,flag = self:OnDeltaTime()
	self.time = self.time + deltaTime
	while flag and self:IsRunFrame() do
        self.runError = true
		self:ExclFrame()

        if self.checkWorld then
            self.checkWorld:ExclFrame()
            self.onCheckWorld()
        end
        self.runError = false
	end
    self.lerpTime = (self.time - self.frame * self.opts.deltaTime) / self.opts.deltaTime
end

function SECBWorld:IsRunFrame()
    if self.opts:IsClient() then
        return self.time >= (self.frame + 1) * self.opts.deltaTime
    else
        return self.time >= (self.frame + 1) * self.opts.deltaTime
    end
end

function SECBWorld:ExclFrame()
    self.frame = self.frame + 1
    self.frameTime = self.frame * self.opts.frameDeltaTime
    self:OnPreUpdate()
	self:OnLogicUpdate()
	self:OnLateUpdate()
end

function SECBWorld:SetCheckWorld(world,onCheckWorld)
    self.checkWorld = world
    self.onCheckWorld = onCheckWorld
end

function SECBWorld:GetUid(uidType)
    if not self.uuids[uidType] then self.uuids[uidType] = 0 end
    self.uuids[uidType] = self.uuids[uidType] + 1
    return self.uuids[uidType]
end

function SECBWorld:Update()
    self:OnUpdate()
end

function SECBWorld:Destroy()
    self:OnDestroy()
end

function SECBWorld:CleanSystem()
    for i,v in ipairs(self.systems) do
        v:Delete()
    end
    self.systems = {}
end

--初始化系统回调,用于添加系统
function SECBWorld:OnInitSystem()
end
--更新回调
function SECBWorld:OnUpdate()
end
--逻辑帧预更新
function SECBWorld:OnBeginExclFrame()
end
function SECBWorld:OnEndExclFrame()
end
--逻辑帧预更新
function SECBWorld:OnPreUpdate()
end
--逻辑帧更新
function SECBWorld:OnLogicUpdate()
end
--逻辑帧末更新
function SECBWorld:OnLateUpdate()
end
--世界销毁
function SECBWorld:OnDestroy()
end

function SECBWorld:OnDeltaTime()
    
end