--- ECSL生命周期:
--- OnInit --> OnInitComplete --> OnAfterInit(某些逻辑需要等所有其他模块都InitComplete)
--- OnUpdate 每帧调用
--- OnEnable 每次Enable变化时调用
ECSLBehaivor = Class("ECSLBehaivor",ECSLBase)
ECSLBehaivor.TYPE = ECSLConfig.Type.Nil

function ECSLBehaivor:OnInit()
    self.enable = true
end

function ECSLBehaivor:OnDelete()
end

-- 所有系统、实体或者组件执行OnInit后，调用OnInitComplete
function ECSLBehaivor:InitComplete()
    self:CallFuncDeeply("OnInitComplete",true)
end

-- 所有系统、实体或者组件执行OnInitComplete后，调用OnAfterInit
function ECSLBehaivor:AfterInit()
    self:CallFuncDeeply("OnAfterInit",true)
end

function ECSLBehaivor:Update(deltaTime)
    if self.enable then
        self:CallFuncDeeply("OnUpdate",true,deltaTime)
    end
end

function ECSLBehaivor:SetEnable(enable)
    if enable ~= self.enable then
        self.enable = enable
        self:CallFuncDeeply("OnEnable",true)
    end
end

function ECSLBehaivor:OnInitComplete()end
function ECSLBehaivor:OnAfterInit()end
function ECSLBehaivor:OnEnable()end
function ECSLBehaivor:OnUpdate(deltaTime)end

return ECSLBehaivor