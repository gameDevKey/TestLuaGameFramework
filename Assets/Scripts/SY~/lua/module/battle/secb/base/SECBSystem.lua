SECBSystem = BaseClass("SECBSystem",SECBBase)

function SECBSystem:__Init()
end

function SECBSystem:__Delete()
end

function SECBSystem:PreUpdate()
    self:OnPreUpdate()
end

function SECBSystem:Update()
    self:OnUpdate()
end

function SECBSystem:LateUpdate()
    self:OnLateUpdate()
end

--初始化系统回调(world已赋值)
function SECBSystem:OnInitSystem()
end

--初始化系统完成回调,此回调会在所有系统调用完OnInitSystem之后按添加顺序执行
function SECBSystem:OnLateInitSystem()
end

function SECBSystem:OnInitComplete()
    
end

function SECBSystem:OnPreUpdate()
end

function SECBSystem:OnUpdate()
end

function SECBSystem:OnLateUpdate()
end